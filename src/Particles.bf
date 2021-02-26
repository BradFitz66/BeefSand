using System;
using Atma;
namespace BeefSand
{
	public static class Particles
	{
		public static String[5] particleNames=.(
			"Sand",
			"Air",
			"Wall",
			"Water",
			"Oil",
		);


		public static Particle[5] particles=.(
		    //Color, timer, update, position, ID, density, max velocity, simulation reference
			.(.(219,209,180,255), 0, => Sand, .(10, 10), 0,5,4,sim),
			.(.CornflowerBlue, 0, => Air, .(0, 0), 1,0,0,sim),
			.(.(100,100,100,255), 0, => Air, .(0, 0), 2,100,0,sim),
			.(.(200,200,255,255), 0, => Water, .(0, 0),3,4,8,sim),
			.(.(50,50,50,255), 0, => Oil, .(0, 0), 4,3,2,sim),

		);

		public static Particle this[int ind] => particles[ind];


		public static void Water(ref Particle p,float dT=0)
		{

		}


		public static void Oil(ref Particle p, float dT=0)
		{

		}

		public static void Sand(ref Particle p, float dT=0)
		{

			/*int randNumber = r.Next(1,10);
			int xMovement=randNumber > 5 ? -1 : 1;

			Particle below = sim.GetElement((int32)p.pos.x, (int32)p.pos.y + 1);
			Particle diagleftright = sim.GetElement((int32)p.pos.x+xMovement, (int32)p.pos.y + 1);
			Particle diagleft = sim.GetElement((int32)p.pos.x-1, (int32)p.pos.y + 1);
			Particle diagright = sim.GetElement((int32)p.pos.x+1, (int32)p.pos.y + 1);

			//If we can still move, don't go to sleep. Diagleftright is unreliable due to the random movement.
			bool shouldSleep=diagleft.id!=1 && diagright.id!=1;
			Particle replacing=particles[0];
			if (below.density<p.density)
			{
				p.stable=false;
				replacing=below;
				sim.SetElement((int32)p.pos.x, ((int32)p.pos.y) + 1, p);
			}
			else if(diagleftright.density<p.density){
				p.stable=false;
				replacing=diagleftright;

				sim.SetElement((int32)p.pos.x+xMovement, ((int32)p.pos.y) + 1, p);
			}
		
			else
			{

				if(p.sleepTimer<10 && shouldSleep){
					p.sleepTimer++;
				}
				else if(p.sleepTimer>=10){
					p.stable=true;
				}
				else if(!shouldSleep){
					p.stable=false;
				}
				return;
			}
			
			sim.SetElement((int32)p.pos.x, (int32)p.pos.y, replacing);*/
		}

		public static void Air(ref Particle p, float dT=0) { }
	}
}
