using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	class Chunk : Dictionary<rect, Particle[,]>
	{

		public this(){
		}

		public void Add(rect chunk){
			if(!this.ContainsKey(chunk)){

			}
		}

		public void GenerateTerrain(){
		}

		public void Update(rect chunk, ref uint8 simulationClock){
			if(!this.ContainsKey(chunk))
				return;
			Particle[,] particles=this[chunk];
			for (int i = 0; i < simulationWidth; i++)
			{
				for (int j = 0; j < simulationHeight; j++)
				{
					if (particles[i, j].id == 1 || particles[i, j].stable)
						continue;
					if (particles[i, j].timer - simulationClock != 1)
						particles[i, j].update(ref particles[i, j], 0);
				}
			}
			simulationClock += 1;
			if (simulationClock > 254)
			{
				simulationClock = 0;
			}
		}
	}
}
