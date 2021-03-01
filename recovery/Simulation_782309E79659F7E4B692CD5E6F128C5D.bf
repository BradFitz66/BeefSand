using System;
using System.Collections;
using System.Linq;
using BeefSand.lib;
using SDL2;
using Atma;

namespace BeefSand
{
	//A tile is a group of particles that can be moved. This allows for stuff like a player that can interact with the
	// simulation
	struct Tile
	{
		public int2[] positions;
		public Particle particle;//Each position will have this particle
		//We'll offset each index in positions by this
		public int2 Position;
		public aabb2 aabb;

		public void Update()
		{
			for (int i = 0; i < positions.Count; i++)
			{
				positions[i] = positions[i] + Position;
			}
		}
	}


	typealias ParticleUpdate = function void(ref Particle);
	struct Particle
	{
		public Color particleColor;
		Color cTemp = Color.White;

		public int2 pos;

		public uint8 timer;
		public uint8 density;
		public uint8 velocity;
		public uint8 maxVelocity;

		public bool solid = false;

		public float sleepTimer = 0;
		public ParticleUpdate update;
		bool _stable = false;
		public bool stable
		{
			get { return _stable; }
			set mut
			{
				_stable = value;
				sleepTimer = 0;
			}
		};
		public Simulation sim;


		public int id;
		public this(Color c, uint8 t, ParticleUpdate u, int2 p, int i, uint8 d, uint8 mV, Simulation simulation, bool s = false)
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
			velocity = 0;
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
		public const int chunkWidth = 1024 / simulationSize;
		public const int chunkHeight = 768 / simulationSize;
	}

	public class Simulation : Entity
	{
		public Chunks chunks;
		public List<Tile> tiles ~ delete _;

		public this()
		{
			sim = this;
			tiles = new List<Tile>();
			chunks = new Chunks(10, 10);
			GenerateTerrain();
			DebugLog(scope $"Initialized with a simulation size of {chunkWidth*chunks.xChunks}x{chunkHeight*chunks.yChunks}");
			DebugLog(scope $"Initialized with a world size of {(chunkWidth*chunks.xChunks)*simulationSize}x{(chunkHeight*chunks.yChunks)*simulationSize}");
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
					int n = (int)(float(noise.GetPerlin(x, y) * 80));
					//Console.WriteLine(n);
					if (n < 10)
					{
						SetElement(x, y, Particles[2]);
					}
					else
					{
						SetElement(x, y, Particles[1]);
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
				for (int j = 0; j < tiles[i].positions.Count; j++)
				{
					SetElement(tiles[i].positions[j] + tiles[i].Position, tiles[i].particle);
				}
			}
		}

		public void SetElement(int2 pos, Particle value)
		{
			int x = pos.x;
			int y = pos.y;
			//Make sure x and y aren't outside the bounds of the world
			if (y >= chunkHeight * chunks.yChunks || x >= chunkWidth * chunks.xChunks)
				return;
			SetElement(x, y, value);
		}

		public void SetElement(int x, int y, Particle value)
		{

			//Make sure x and y aren't outside the bounds of the world
			if (y >= chunkHeight * chunks.yChunks || x >= chunkWidth * chunks.xChunks)
				return;

			Chunk chunk = chunks.FindChunkAtPoint(.(x, y));
			rect chunkBounds = .(x - x % chunkWidth, y - y % chunkHeight, chunkWidth, chunkHeight);//Calculate bounds of
			// a chunk

			if ((chunkBounds.Width == 0 && chunkBounds.Height == 0) || chunk == null)
				return;

			Particle[,] particles = chunk.particles;

			rect bounds = chunkBounds;
			int chunkX = x - bounds.X;
			int chunkY = y - bounds.Y;

			//Set all particles around the one we're setting to be unstable. This stops particles floating in mid-air
			for(int i=-5; i<5; i++){
				for(int j=-5; j<5; j++){
					if(chunkX+i>=chunkWidth || chunkY+j >= chunkHeight || chunkX+i<0 || chunkY+j<0 || value.solid)
						continue;
					particles[chunkX+i,chunkY+j].stable=false;
				}
			}

			particles[chunkX, chunkY] = value;
			particles[chunkX, chunkY].pos = .(x, y);
			particles[chunkX, chunkY].timer = chunk.clock + 1;
			particles[chunkX,chunkY].stable = false;
			//Set pixel in the chunks render image.
			chunk.chunkRenderImage.SetPixels(.(chunkX, chunkY, 1, 1), scope Color[](value.particleColor));
		}

		static bool withinBounds(rect chunk, int x, int y)
		{
			return chunk.Contains(.(x, y));
		}


		public Particle GetElement(int2 pos)
		{
			int x = pos.x;
			int y = pos.y;

			if (y >= chunkHeight * chunks.yChunks || x >= chunkWidth * chunks.xChunks)
				return Particles[2];

			return GetElement(x, y);
		}

		public Particle GetElement(int x, int y)|
		{
			if (y >= chunkHeight * chunks.yChunks || x >= chunkWidth * chunks.xChunks)
				return Particles[2];

			rect chunkBounds = .(x - x % chunkWidth, y - y % chunkHeight, chunkWidth, chunkHeight);
			Chunk chunk = chunks.GetChunkFromBounds(chunkBounds);
			int chunkX = x - chunkBounds.X;
			int chunkY = y - chunkBounds.Y;
			if (chunkX < 0 || chunkY < 0 || (chunkBounds.Width == 0 && chunkBounds.Height == 0) || chunk == null)
				return Particles[2];

			return chunk.particles[chunkX, chunkY];
		}

		public override void Render()
		{
			base.Render();
		}
	}
}
