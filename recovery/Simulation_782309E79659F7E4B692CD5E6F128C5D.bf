using System;
using System.Collections;
using System.Linq;
using BeefSand.lib;
using Atma;

namespace BeefSand
{
	//A tile is a group of particles that can be moved. This allows for stuff like a player that can interact with the simulation
	struct Tile
	{
		public Texture sprite;
		public Particle particle;//Each position will have this particle
		//We'll offset each index in positions by this
		public int2 Position;


		public this(Texture s, Particle p)
		{
			sprite = s;
			Position = default;
			particle = p;
		}

		public void Draw()
		{
			Color[] data = new Color[12 * 10];
			sprite.GetData(data);

			for (int i = 0; i < data.Count; i++)
			{
				int x = int(i % sprite.Width);
				int y = int(i / sprite.Width);
				if (data[i] != Color.Transparent)
				{
					Particle p = particle;
					p.particleColor = data[i];
					sim.SetElement(x + Position.x, y + Position.x, p);
				}
			}
		}

		public void Update()
		{
		}
	}

	typealias ParticleUpdate = function (bool, int2)(Particle*);
	struct Particle
	{
		public Color particleColor;
		Color cTemp = Color.White;
		public int2 pos;
		public uint8 timer;//Used to
		// determine whether or not it has been updated this frame
		public int8 density;
		public int2 velocity;
		public uint8 maxVelocity;
		public uint32 lifetimer = 0;//How long
		// has this particle been alive

		public bool solid = false;

		public float sleepTimer = 0;
		public ParticleUpdate update;
		bool _stable = false;
		public bool stable = false;
		public Simulation sim;


		public int id = 10000;
		public this(Color c, uint8 t, ParticleUpdate u, int2 p, int i, int8 d, uint8 mV, Simulation simulation, bool s = false)
		{
			particleColor = c;
			cTemp = particleColor;
			timer = t;
			update = u;
			pos = p;
			id = i;
			sim = simulation;
			density = d;
			maxVelocity = mV;
			velocity = .(0, 0);
			solid = s;
		}
		public int64 GetHashCode()
		{
			HashCode hc = HashCode();
			hc.Add(pos);
			hc.Add(timer);
			hc.Add(id);
			return hc.ToHashCode();
		}
	}

	static
	{
		public const int simulationSize = 4;
		public const int chunkWidth = 512 / simulationSize;
		public const int chunkHeight = 512 / simulationSize;
	}

	public class Simulation : Entity
	{
		public Chunks chunks ~ delete _;
		public List<Tile> tiles ~ delete _;

		public this()
		{
			sim = this;
			tiles = new List<Tile>();
			chunks = new Chunks(10, 10);

			GenerateTerrain();

			DebugLog(scope $"Initialized with a simulation size of {chunkWidth*chunks.xChunks}x{chunkHeight*chunks.yChunks}");
			DebugLog(scope $"Initialized with a world size of {(chunkWidth*chunks.xChunks)*simulationSize}x{(chunkHeight*chunks.yChunks)*simulationSize}");

			Texture t = scope Sprite(Core.Atlas["main/chick"]).Subtexture.Texture;

			tiles.Add(
				.(t, Particles[2])
				);
			tiles[0].Position.x = 100;
			tiles[0].Position.y = 100;
			tiles[0].particle = Particles[2];
		}
		public ~this()
		{
		}
		public void GenerateTerrain()
		{
			FastNoise noise = scope .(DateTime.Now.Millisecond);

			System.Diagnostics.Stopwatch s = scope .()..Start();
			for (int x = 0; x < chunkWidth * chunks.xChunks; x++)
			{
				for (int y = 0; y < chunkHeight * chunks.yChunks; y++)
				{
					int n = (int)(float(noise.GetPerlin(x, y) * 150));
					//Console.WriteLine(n);
					if (n < 10)
					{
						SetElement(x, y, Particles[2], false);
					}
					else
					{
						SetElement(x, y, Particles[1], false);
					}
				}
			}
			s.Stop();
			DebugLog(scope $"Generated terrain in {s.Elapsed.TotalSeconds} seconds");
		}

		protected override void OnUpdate()
		{
			base.OnUpdate();
			//Add tiles to simulation
			for (int i = 0; i < tiles.Count; i++)
			{
				//tiles[i].Draw();
			}
		}

		public void SetElement(int2 pos, Particle value)
		{
			SetElement(pos.x, pos.y, value);
		}

		public void SetElement(int x, int y, Particle value, bool awakeOther = true, bool newParticle = false)
		{

			//Make sure x and y aren't outside the bounds of the world
			if (!withinWorldBounds(x, y))
				return;
			if (awakeOther)
			{
				for (int i = -3; i < 3; i++)
				{
					for (int j = -3; j < 3; j++)
					{
						if (!withinWorldBounds(x + i, y + j))
							continue;
						Particle* p = GetElementReference(x + i, y + j);
						if (p.solid || p.id == 1)
							continue;
						p.stable = false;
					}
				}
			}

			Chunk chunk = chunks.GetChunkFromPoint(.(x, y));

			bool shouldDirtyChunk = (value.id != 1 && value.stable != true && awakeOther);
			bool shouldUpdDirtyRect = (value.id != 1 && value.stable != true && awakeOther && newParticle);

			Particle[] particles = chunk.particles;

			rect bounds = chunk.chunkBounds;

			int chunkX = (x - bounds.X);
			int chunkY = (y - bounds.Y);

			if (shouldDirtyChunk)
			{
				chunk.dirty = true;
				chunk.sleepTimer = 0;
			}
			if (shouldUpdDirtyRect)
			{
				chunk.dirty = true;
				chunk.UpdateDirtyRect(.(chunkX, chunkY));
			}

			particles[chunkY * chunkWidth + chunkX] = value;
			particles[chunkY * chunkWidth + chunkX].timer = chunk.clock + 1;
			particles[chunkY * chunkWidth + chunkX].pos = .(x, y);
			particles[chunkY * chunkWidth + chunkX].stable = false;

			chunk.chunkRenderImage.SetPixels(.(chunkX, chunkY, 1, 1), scope Color[](value.particleColor));
		}

		public bool withinWorldBounds(int x, int y)
		{
			return x < chunkWidth * chunks.xChunks && y < chunkHeight * chunks.yChunks && x > 0 && y > 0;
		}


		public Particle GetElement(int2 pos)
		{
			return GetElement(pos.x, pos.y);
		}

		//Should only be used if you want to modify a particle at a position.
		public Particle* GetElementReference(int x, int y)
		{
			if (!withinWorldBounds(x, y))
				return &Particles.particles[2];

			rect chunkBounds = .(x - x % chunkWidth, y - y % chunkHeight, chunkWidth, chunkHeight);
			Chunk chunk = chunks.GetChunkFromBounds(chunkBounds);
			int chunkX = x - chunkBounds.X;
			int chunkY = y - chunkBounds.Y;

			return &chunk.particles[chunkY * chunkWidth + chunkX];
		}

		//Should only be used for if you need to check if a certain particle exists at a position
		public Particle GetElement(int x, int y)
		{
			if (!withinWorldBounds(x, y))
				return Particles[2];

			rect chunkBounds = .(x - x % chunkWidth, y - y % chunkHeight, chunkWidth, chunkHeight);
			Chunk chunk = chunks.GetChunkFromBounds(chunkBounds);
			int chunkX = x - chunkBounds.X;
			int chunkY = y - chunkBounds.Y;

			return chunk.particles[chunkY * chunkWidth + chunkX];
		}

		public override void Render()
		{
			base.Render();
		}
	}
}
