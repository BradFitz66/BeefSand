using System;
using System.Linq;
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
		static Particle[,] particles;
		public Color[] c;


		public this()
		{
		
			i = new .(.(976, 976));
			c = new Color[976 * 976]();
			c.Populate(Color.CornflowerBlue);
			i.SetPixels(.(0, 0, 976, 976), c);
			texture = new Texture(i);
			texture.Filter=.Nearest;

			particles = new Particle[simulationWidth, simulationHeight];

			for (int i = 0; i < simulationWidth; i++)
			{
				for (int j = 0; j < simulationHeight; j++)
				{
					particles[i, j] = Particles[1];
				}
			}
			for (int i = 0; i < simulationWidth; i++)
			{
				SetElement(i, 0, Particles[0]);
			}
		}

		public static void Populate<T>(this T[] arr, T value)
		{
			for (int i = 0; i < arr.Count; i++)
			{
				arr[i] = value;
			}
		}

		public void ExtractColor(ref Color[] array)
		{
			array=new Color[976*976]();
			array.Populate(Color.White);
			for (int i = 0; i < particles.Count; i++)
			{
				int x = i % simulationWidth;
				int y = i / simulationHeight;
				array[i] = particles[x, y].particleColor;
			}
		}


		public ~this()
		{
			delete (particles);
		}

		public void SetElement(int row, int col, Particle value)
		{
			if (!withinBounds(row, col))
				return;
			particles[row, col] = value;
			particles[row, col].pos = .(row, col);
			particles[row, col].timer = simulationClock + 1;


			//Get all pixels around this one and set them to unstable
			for (int x = -1; x < 3; x++)
			{
				for (int y = -1; y < 3; y++)
				{
					if (withinBounds(row + x, col + y) && particles[row + x, col + y].id != 0)
					{
						particles[row + x, col + y].stable = false;
					}
				}
			}


			particles[row, col].stable = false;
			i.SetPixels(.(row,col,1,1),scope Color[](value.particleColor));
		}

		static bool withinBounds(int x, int y)
		{
			return (x > -1 && x <= simulationWidth - 1 && y > -1 && y <= simulationHeight - 1);
		}

		public Particle GetElement(int row, int col)
		{
			if (withinBounds(row, col))
				return particles[row, col];
			else
			{
				return Particles[2];
			}
		}



		//Simulate a single frame
		public void Simulate(float dT)
		{
			for (int i = 0; i < simulationWidth; i++)
			{
				for (int j = 0; j < simulationHeight; j++)
				{
					if (particles[i, j].id == 0 || particles[i, j].stable)
						continue;
					if (particles[i, j].timer - simulationClock != 1)
						particles[i, j].update(ref particles[i, j], dT);
				}
			}
			simulationClock += 1;
			if (simulationClock > 254)
			{
				simulationClock = 0;
			}
		}
		protected override void OnUpdate()
		{
			Simulate(0);
		}
		public void Draw()
		{
			texture.SetData(i.Pixels);
			Core.Draw.Image(texture,aabb2(0,0,976*4,976*4),Color.White);
		}
	}
}
