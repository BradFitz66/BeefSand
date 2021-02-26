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
				_stable = value;
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
		public static rect simulationBounds;
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
			simulationBounds=.(Core.Window.RenderBounds.X,Core.Window.RenderBounds.Y,Core.Window.RenderBounds.Width/simulationSize,Core.Window.RenderBounds.Height/simulationSize);

			chunks = new Chunks();
			rect testChunk1 = (.(0, 0, simulationWidth, simulationHeight));
			rect testChunk2 = (.(simulationWidth, 0, simulationWidth, simulationHeight));

			chunks.Add(
				testChunk1
			);
			chunks.Add(
				testChunk2
			);

			chunks.GenerateTerrain();
		}

		public ~this()
		{
			delete (i);
			delete (texture);
			delete (c);
		}

		public void SetElement(int x, int y, Particle value)
		{
			rect chunkBounds = chunks.FindChunkAtPoint(.(x, y));
			Chunk chunk = chunks.GetChunkFromBounds(chunkBounds);
			if (!withinBounds(chunkBounds, x, y) || (chunkBounds.Width==0 && chunkBounds.Height==0))
				return;	
			Particle[,] particles = chunk.particles;

			rect bounds=chunkBounds;
			int chunkX=x-bounds.X;
			int chunkY=y-bounds.Y;

			/*if(chunkX>particles.GetLength(0)-1 || chunkY>particles.GetLength(1)-1)
				return;*/
			for(int i=-3; i<3; i++){
				for(int j=-3; j<3; j++){
					if(chunkX+i>particles.GetLength(0)-1 || chunkY+i > particles.GetLength(0) || chunkX+i<0 || chunkY+i<0)
						continue;
					particles[chunkX+i,chunkY+j].stable=false;
				}
			}

			particles[chunkX,chunkY] = value;
			particles[chunkX,chunkY].pos = .(x, y);
			particles[chunkX,chunkY].timer = chunk.clock + 1;
			particles[chunkX,chunkY].stable = false;
			chunk.chunkRenderImage.SetPixels(.(chunkX, chunkY, 1, 1), scope Color[](value.particleColor));
		}

		static bool withinBounds(rect chunk, int x, int y)
		{
			return chunk.Contains(.(x, y));
		}

		public Particle GetElement(int x, int y)
		{
			rect chunkBounds = chunks.FindChunkAtPoint(.(x, y));
			Chunk chunk = chunks.GetChunkFromBounds(chunkBounds);
			if (withinBounds(chunkBounds, x, y)){
				return chunk.particles[x-chunkBounds.X, y-chunkBounds.Y];
			}
			else
			{
				return Particles[2];
			}
		}



		//Simulate a single frame^
		public void Simulate(float dT)
		{
			chunks.Update();
		}
		protected override void OnUpdate()
		{
			simulationBounds=.(Core.Window.RenderBounds.X,Core.Window.RenderBounds.Y,Core.Window.RenderBounds.Width/simulationSize,Core.Window.RenderBounds.Height/simulationSize);
			Simulate(0);
		}
		public void Draw()
		{
			chunks.Draw();
		}
	}
}
