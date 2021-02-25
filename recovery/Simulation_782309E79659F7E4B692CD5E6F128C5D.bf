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
			rect testChunk1 = .(0, 0, 976, 976);
			rect testChunk2 = .(976, 0, 976, 976);
			chunks.Add(
				testChunk1
				);
			chunks.Add(
				testChunk2
				);
			aabb2 worldAABB = testChunk1.ToAABB();
			worldAABB.Merge(testChunk2.ToAABB());
			rect worldSize = worldAABB.ToRect();

			i = new .(worldSize.Width, worldSize.Height);

			c = new Color[1952 * 976]();
			c.Populate(Color.CornflowerBlue);
			i.SetPixels(.(0, 0, 1952, 976), c);
			texture = new Texture(i);
			texture.Filter = .Nearest;

			chunks.GenerateTerrain();
		}

		public static void Populate<T>(this T[] arr, T value)
		{
			for (int i = 0; i < arr.Count; i++)
			{
				arr[i] = value;
			}
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
			rect chunk = chunks.FindChunkAtPoint(.(x * 4, y * 4));

			Particle[,] particles = chunks[chunk];
			if (!withinBounds(chunk, x, y))
				return;

			//Get row & column relative to the chunk position. This is done because if a chunks position isn't 0,0, we need to convert x and y to a position relative to the origin of that chunk
			int chunkRow=x-(chunk.X*4);
			int chunkColumn=y-(chunk.Y*4);

			particles[chunkRow, chunkColumn] = value;
			particles[chunkRow, chunkColumn].pos = .(chunkRow, chunkColumn);
			particles[chunkRow, chunkColumn].timer = simulationClock + 1;
			particles[chunkRow, chunkColumn].stable = false;

			//Trying to set particles around the one we're setting to be not stable anymore. Causes access violation. I don't know why. Help.
			for(int i=-3; i<1; i++){
				for(int j=-3; j<1; j++){

					if(withinBounds(chunk,x+i,y+j)){
						chunkRow=x-(chunk.X*4);
						chunkColumn=y-(chunk.Y*4);
						if(particles[chunkRow+i,chunkColumn+i].id!=0){
							particles[chunkRow+i,chunkColumn+i].stable=false;
						}
					}
				}
			}
			
			i.SetPixels(.(x, y, 1, 1), scope Color[](value.particleColor));
		}

		static bool withinBounds(rect chunk, int x, int y)
		{
			return chunk.Contains(.(x + chunk.X, y + chunk.Y));
		}

		public Particle GetElement(int x, int y)
		{
			rect chunk = chunks.FindChunkAtPoint(.(x * 4, y * 4));
			if (withinBounds(chunk, x, y)){
				int chunkRow=x-chunk.X/4;
				int chunkColumn=y-chunk.Y/4;
				return chunks[chunk][chunkRow, chunkColumn];
			}
			else
			{
				return Particles[2];
			}
		}



		//Simulate a single frame
		public void Simulate(float dT)
		{
			rect viewport = Core.Window.RenderBounds;
			List<rect> chunkInView=new List<rect>();
			chunks.FindChunksInView(viewport,ref chunkInView);
			for(int i=0; i<chunkInView.Count; i++){
				chunks.Update(chunkInView[i],ref simulationClock);
			}

			simulationClock += 1;
			if (simulationClock > 254)
			{
				simulationClock = 0;
			}
			delete(chunkInView);
		}
		protected override void OnUpdate()
		{
			Simulate(0);
		}
		public void Draw()
		{
			texture.SetData(i.Pixels);
			Core.Draw.Image(texture, aabb2(0, 0, i.Width * 4, i.Height * 4), Color.White);
			chunks.Draw();
		}
	}
}
