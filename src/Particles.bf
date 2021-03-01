using System;
using System.Collections;
using Atma;
namespace BeefSand
{
	public static class Particles
	{
		public static String[?] particleNames = .(
			"Sand",
			"Air",
			"Wall",
			"Water",
			"Oil"
			);


		public static Particle[?] particles = .(//Color, timer, update, position, ID, density, max velocity, simulation reference
			.(.(219, 209, 180, 255), 0, => Sand, .(10, 10), 0, 5, 4, null),
			.(.Transparent, 0, => Air, .(0, 0), 1, 0, 0, null),
			.(.(100, 100, 100, 255), 0, => Air, .(0, 0), 2, 100, 0, null,true),
			.(.(200, 200, 255, 255), 0, => Water, .(0, 0), 3, 4, 8, null),
			.(.(50, 50, 50, 255), 0, => Oil, .(0, 0), 4, 3, 2, null)
			);

		public static Particle this[int ind] => particles[ind];


		public static void Water(ref Particle p)
		{
			int randNumber = r.Next(1, 10);
			int xMovement = randNumber > 5 ? -1 : 1;
			Particle below = sim.GetElement(p.pos.x, p.pos.y + 1);
			Particle leftright = sim.GetElement(p.pos.x + xMovement, p.pos.y);

			Particle left = sim.GetElement(p.pos.x - 1, p.pos.y);
			Particle right = sim.GetElement(p.pos.x + 1, p.pos.y);

			bool shouldSleep = left.id != 1 && right.id != 1 && below.id != 1;
			Particle replacing = particles[3];
			int2 prevPos=.Zero;

			if (below.density < p.density)
			{
				replacing = below;
				prevPos=p.pos;
			}
			else if (leftright.density < p.density)
			{
				replacing = leftright;
				prevPos=p.pos;
			}
			else
			{
				if (p.sleepTimer < 10 && shouldSleep)
				{
					p.sleepTimer++;
				}
				else if (p.sleepTimer >= 10)
				{
					p.stable = true;
				}
				else if (!shouldSleep)
				{
					p.stable = false;
				}
			}
			sim.SetElement(replacing.pos, p);
			sim.SetElement(prevPos, replacing);
		}

		public static void Oil(ref Particle p)
		{
			int randNumber = r.Next(1, 10);
			int xMovement = randNumber > 5 ? -1 : 1;
			Particle below = sim.GetElement(p.pos.x, p.pos.y + 1);
			Particle leftright = sim.GetElement(p.pos.x + xMovement, p.pos.y);

			Particle left = sim.GetElement(p.pos.x - 1, p.pos.y);
			Particle right = sim.GetElement(p.pos.x + 1, p.pos.y);

			bool shouldSleep = left.id != 1 && right.id != 1 && below.id != 1;
			Particle replacing = particles[4];
			int2 prevPos=.Zero;

			if (below.density < p.density)
			{
				replacing = below;
				prevPos=p.pos;
			}
			else if (leftright.density < p.density)
			{
				replacing = leftright;
				prevPos=p.pos;
			}
			else
			{
				if (p.sleepTimer < 10 && shouldSleep)
				{
					p.sleepTimer++;
				}
				else if (p.sleepTimer >= 10)
				{
					p.stable = true;
				}
				else if (!shouldSleep)
				{
					p.stable = false;
				}
			}
			sim.SetElement(replacing.pos, p);
			sim.SetElement(prevPos, replacing);
		}

		public static void Sand(ref Particle p)
		{
			int randNumber = r.Next(1, 10);
			int xMovement = randNumber > 5 ? -1 : 1;

			Particle below = sim.GetElement(p.pos.x, p.pos.y + 1);
			Particle diagleftright = sim.GetElement(p.pos.x + xMovement, p.pos.y + 1);
			Particle diagleft = sim.GetElement(p.pos.x - 1, p.pos.y + 1);
			Particle diagright = sim.GetElement(p.pos.x + 1, p.pos.y + 1);
			int2 prevPos=.Zero;
			//If we can still move, don't go to sleep. Diagleftright is unreliable due to the random movement.
			bool shouldSleep = diagleft.id != 1 && diagright.id != 1;
			Particle replacing = particles[0];
			if (below.density < p.density)
			{
				replacing = below;
				prevPos=p.pos;
				//sim.SetElement(replacing.pos, p);
			}
			else if (diagleftright.density < p.density)
			{
				
				replacing = diagleftright;
				prevPos=p.pos;
			}

			else
			{

				if (p.sleepTimer < 10 && shouldSleep)
				{
					p.sleepTimer++;
				}
				else if (p.sleepTimer >= 10)
				{
					p.stable = true;
				}
				else if (!shouldSleep)
				{
					p.stable = false;
				}
			}
			sim.SetElement(replacing.pos, p);
			sim.SetElement(prevPos, replacing);
		}

		public static void Air(ref Particle p) { }
	}
}
