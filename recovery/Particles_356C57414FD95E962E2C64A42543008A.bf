using System;
using System.Collections;
using Atma;
namespace BeefSand
{
	/*
	Class for defining particles and their update.

	Very bad code ahead. Continue with caution.
	*/
	public static class Particles
	{
		public static String[?] particleNames = .(
			"Sand",
			"Air",
			"Wall",
			"Water",
			"Oil",
			"Steam"
			);


		public static Particle[?] particles = .(//Color, timer, update, position, ID, density, max velocity, simulation reference
			.(.(219, 209, 180, 255), 0, => Sand, .(10, 10), 0, 5, 4, null),
			.(.Transparent, 0, => Air, .(0, 0), 1, 0, 0, null),
			.(.(100, 100, 100, 255), 0, => Air, .(0, 0), 2, 100, 0, null, true),
			.(.(200, 200, 255, 255), 0, => GenericFluid, .(0, 0), 3, 4, 8, null),
			.(.(50, 50, 50, 255), 0, => GenericFluid, .(0, 0), 4, 3, 2, null),
			.(.(200, 200, 200, 100), 0, => Steam, .(0, 0), 5, 1, 1, null)
			);

		public static Particle this[int ind] => particles[ind];


		public static (bool,int2) GenericFluid(Particle* p)
		{
			return default;
		}

		public static (bool,int2) Steam(Particle* p)
		{
			return default;	
		}


		public static (bool,int2) Sand(Particle* p)
		{
			int randNumber = r.Next(1, 10);
			int xMovement = randNumber > 5 ? -1 : 1;

			Particle below = sim.GetElement(p.pos.x, p.pos.y + 1);
			Particle diagleftright = sim.GetElement(p.pos.x + xMovement, p.pos.y + 1);
			Particle diagleft = sim.GetElement(p.pos.x - 1, p.pos.y + 1);
			Particle diagright = sim.GetElement(p.pos.x + 1, p.pos.y + 1);

			int2 prevPos = .Zero;

			//If we can still move, don't go to sleep. Diagleftright is unreliable due to the random movement.
			bool shouldSleep = diagleft.id != 1 && diagright.id != 1;

			Particle replacing = particles[0];

			if (below.density < p.density)
			{
				replacing = below;
				prevPos = p.pos;
				sim.SetElement(replacing.pos, *p);
				sim.SetElement(prevPos, replacing);
				return (true,replacing.pos);
			}
			else if (diagleftright.density < p.density)
			{
				replacing = diagleftright;
				prevPos = p.pos;
				sim.SetElement(replacing.pos, *p);
				sim.SetElement(prevPos, replacing);

				return (true,replacing.pos);
			}
			return (!shouldSleep,p.pos);
		}

		public static (bool,int2) Air(Particle* p) { return default; }
	}
}
