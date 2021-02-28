using System;
using System.Collections;
using System.Linq;
using BeefSand.lib;
using SDL2;
using Atma;

namespace BeefSand
{
	
	typealias ParticleUpdate = function void(ref Particle, float dT = 0);
	struct Particle
	{
		public Color particleColor;
		Color cTemp = Color.White; 

		public int2 pos;

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
		public this(Color c, uint8 t, ParticleUpdate u, int2 p, int i, uint8 d, uint8 mV, Simulation simulation)
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
	}

	static
	{
		public const int simulationSize = 8;
		public const int chunkWidth = 512 / simulationSize;
		public const int chunkHeight = 1024 / simulationSize;
	}

	public class Simulation : Entity
	{
		public Chunks chunks;


		public this()
		{
			sim=this;

			chunks = new Chunks(10,3);
			GenerateTerrain();
		}
		public void GenerateTerrain()
		{
			FastNoise noise = scope .(DateTime.Now.Millisecond);
			System.Diagnostics.Stopwatch s = scope .()..Start();
			for(int x=0; x<chunkWidth*chunks.xChunks; x++){
				for(int y=0; y<chunkHeight*chunks.yChunks; y++){
					int n = (int)(float(noise.GetPerlin(x,y)*100));
					//Console.WriteLine(n);
					if(n<10){
						SetElement(x,y,Particles[2]);
					}
					else{
						SetElement(x,y,Particles[1]);
					}
				}
			}
			s.Stop();
			Debug(scope $"Generated terrain in {s.Elapsed.TotalSeconds} seconds");
		}

		
		
		public void SetElement(int x, int y, Particle value)
		{

			//Make sure x and y aren't outside the bounds of the world 
			if(y>=chunkHeight*chunks.yChunks || x>=chunkWidth*chunks.xChunks)
				return;

			Chunk chunk = chunks.FindChunkAtPoint(.(x,y));
			rect chunkBounds=.(x - x % chunkWidth,y - y % chunkHeight,chunkWidth,chunkHeight);//Calculate bounds of a chunk
			
			if (!withinBounds(chunkBounds, x, y) || (chunkBounds.Width==0 && chunkBounds.Height==0) || chunk==null)
				return;

			Particle[,] particles = chunk.particles;

			rect bounds=chunkBounds;
			int chunkX=x-bounds.X;
			int chunkY=y-bounds.Y;

			//Set all particles around the one we're setting to be unstable. This stops particles floating in mid-air
			for(int i=-3; i<3; i++){
				for(int j=-3; j<3; j++){
					if(chunkX+i>chunkWidth-1 || chunkY+j > chunkHeight-1 || chunkX+i<0 || chunkY+j<0)
						continue;
					particles[chunkX+i,chunkY+j].stable=false;
				}
			}

			particles[chunkX,chunkY] = value;
			particles[chunkX,chunkY].pos = .(x, y);
			particles[chunkX,chunkY].timer = chunk.clock + 1;
			particles[chunkX,chunkY].stable = false;
			//Set pixel in the chunks render image.
			chunk.chunkRenderImage.SetPixels(.(chunkX, chunkY, 1, 1), scope Color[](value.particleColor));
		}

		static bool withinBounds(rect chunk, int x, int y)
		{
			return chunk.Contains(.(x, y));
		}


		public Particle GetElement(int x, int y)
		{
			if(y>=chunkHeight*chunks.yChunks || x>=chunkWidth*chunks.xChunks)
				return Particles[2];

			rect chunkBounds = .(x-x%chunkWidth,y-y%chunkHeight,chunkWidth,chunkHeight);
			Chunk chunk = chunks.GetChunkFromBounds(chunkBounds);
			int chunkX=x-chunkBounds.X;
			int chunkY=y-chunkBounds.Y;
			if (!withinBounds(chunkBounds, x, y) || chunkX<0 || chunkY<0 || (chunkBounds.Width==0 && chunkBounds.Height==0) || chunk==null)
				return Particles[2];

			return chunk.particles[chunkX, chunkY];
		}

		public override void Render()
		{
			base.Render();
			
		}
	}
}
