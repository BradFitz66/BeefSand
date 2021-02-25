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

		List<Chunk> chunks ~ DeleteContainerAndItems!(_);


		public this()
		{
			sim=this;
			chunks = new List<Chunk>();
			chunks.Add(
				new Chunk(.(0,0,simulationWidth,simulationHeight))
			);
			chunks.Add(
				new Chunk(.(simulationWidth,0,simulationWidth,simulationHeight))
			);
			for(int i=0; i<244; i++){
				SetElement(i,5,Particles[0]);
			}
		}

		public ~this()
		{
		}

		public void SetElement(int x, int y, Particle value)
		{
			chunks[0].SetElement(x,y,value);
		}

		public Chunk getChunkAtPosition(int x, int y){
			Chunk c=default;
			for(Chunk ch in chunks){
				if(ch.chunkRect.Contains(.(x,y))){
					c=ch;
					break;
				}
			}

			return c;
		}

		public void chunksInView(rect Viewbounds,ref List<Chunk> outList){
			for(Chunk c in chunks){
				if(c.chunkRect.Intersects(Viewbounds)){
					outList.Add(c);
				}
			}
		}


		static bool withinBounds(rect chunk, int x, int y)
		{
			return false;
		}

		public Particle GetElement(int x, int y)
		{
			return Particles[2];
		}



		//Simulate a single frame
		public void Simulate(float dT)
		{
			chunks[0].Simulate();
		}
		protected override void OnUpdate()
		{
			Simulate(0);
		}
		public void Draw()
		{
			chunks[0].Draw();
		}
	}
}
