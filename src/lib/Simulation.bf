using System;
using System.Collections;
using System.Linq;
using BeefSand.lib;
using SDL2;
using Atma;

namespace BeefSand
{
	struct Vector2 : this(int x, int y) { }

	typealias ParticleUpdate = function void(ref Particle, float dT = 0);
	struct Particle
	{
		public Color particleColor;
		Color cTemp = Color.White;
		public Vector2 pos;
		public uint8 timer;
		public uint8 density;
		public uint8 velocity;
		public uint8 maxVelocity;
		public float sleepTimer = 0;
		public ParticleUpdate update;
		bool _stable = false;
		public bool stable
		{
			get { return _stable; } set mut
			{
				sleepTimer = 0;
				//_stable = value;
			}
		};
		public Simulation sim;


		public int id;
		public this(Color c, uint8 t, ParticleUpdate u, Vector2 p, int i, uint8 d, uint8 mV, Simulation simulation)
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
			stable = false;
		}

		public Particle Copy()
		{
			return this;
		}
	}

	static
	{
		public const int simulationSize = 4;
		public const int simulationWidth = 976 / simulationSize;
		public const int simulationHeight = 976 / simulationSize;
		public static uint8 simulationClock;
		public static float gravity = 9.81f;
	}

	class Simulation : Entity
	{
		//Draw pixels onto texture.
		public Texture texture;
		public Atma.Image i;
		public Chunks chunks;
		public Color[] c;


		public this()
		{
			sim = this;
			chunks = new Chunks();
			Chunk testChunk1 = Chunk(.(0, 0, simulationWidth, simulationHeight));
			Chunk testChunk2 = Chunk(.(simulationWidth, 0, simulationWidth, simulationHeight));
			chunks.Add(
				testChunk1
			);
			chunks.Add(
			testChunk2
			);
			Chunk chunk = chunks.FindChunkAtPoint(.(245, 0));
			Console.WriteLine(testChunk2.chunkBounds.Width);
			chunks.GenerateTerrain();
		}

		public ~this()
		{
			delete (i);
			delete (texture);
			delete (c);
			DeleteDictionaryAndValues!(chunks);
		}

		public void SetElement(int x, int y, Particle value)
		{
			Chunk chunk = chunks.FindChunkAtPoint(.(x, y));

			
			if (!withinBounds(chunk.chunkBounds, x, y) || (chunk.chunkBounds.Width==0 && chunk.chunkBounds.Height==0))
				return;
			Particle[,] particles = chunks[chunk];
	
			particles[x/4, y/4] = value;
			particles[x/4, y/4].pos = .(x/4, y/4);
			particles[x/4, y/4].timer = simulationClock + 1;
			particles[x/4, y/4].stable = false;
			
			chunk.chunkRenderImage.SetPixels(.(x, y, 1, 1), scope Color[](value.particleColor));
		}

		static bool withinBounds(rect chunk, int x, int y)
		{
			
			return chunk.Contains(.(x, y));
		}

		public Particle GetElement(int x, int y)
		{
			Chunk chunk = chunks.FindChunkAtPoint(.(x, y));
			if (withinBounds(chunk.chunkBounds, x, y)){
				return chunks[chunk][x, y];
			}
			else
			{
				return Particles[2];
			}
		}



		//Simulate a single frame^
		public void Simulate(float dT)
		{
			

			/*simulationClock += 1;
			if (simulationClock > 254)
			{
				simulationClock = 0;
			}
			delete(chunkInView);*/
		}
		protected override void OnUpdate()
		{
			Simulate(0);
		}
		public void Draw()
		{
			chunks.Draw();
		}
	}
}
