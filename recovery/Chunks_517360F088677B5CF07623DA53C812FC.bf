using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	class Chunks : Dictionary<rect, Particle[,]>
	{

		public this(){
		}

		public void Add(rect chunk){
			if(!this.ContainsKey(chunk)){
				Add(chunk,new Particle[chunk.Width/simulationSize,chunk.Height/simulationSize]);
			}
		}

		public void FindChunksInView(rect viewport,ref List<rect> outList){
			outList=new List<rect>();
			for(rect r in this){
				if(r.Intersects(viewport)){
					outList.Add(r);
				}
			}
		}

		public rect FindChunkAtPoint(int2 point){
			rect chunk=.(0,0,0,0);
			
			for(rect r in this.Keys){
				if(r.Contains(point)){
					chunk=r;
					break;
				}
			}
			return chunk;
		}

		public void GenerateTerrain(){
			FastNoise noise = new .();

			aabb2 worldAABB=.(0,0,0,0);

			for (rect r in this){
				worldAABB.Merge(r.ToAABB());
			}
			System.Diagnostics.Stopwatch t=new .()..Start();
			for(int i=0; i<worldAABB.Width; i++){
				for(int j=0; j<worldAABB.Height; j++){
					//Console.WriteLine(noise.GetCellular(i,j));
					sim.SetElement(i/4,j/4,Particles[2]);
				}
			}
			t.Stop();
			Console.WriteLine($"Generated terrain in {t.Elapsed.TotalSeconds} seconds");
		}

		public void Update(rect chunk, ref uint8 simulationClock){
			if(!this.ContainsKey(chunk))
				return;
			Particle[,] particles=this[chunk];
			for (int i = 0; i < chunk.Width/simulationSize; i++)
			{
				/*for (int j = 0; j < chunk.Height/simulationSize; j++)
				{
					if (particles[i, j].id == 1 || particles[i, j].stable)
						continue;
					if (particles[i, j].timer - simulationClock != 1)
						particles[i, j].update(ref particles[i, j], 0);
				}*/
			}
			simulationClock += 1;
			if (simulationClock > 254)
			{
				simulationClock = 0;
			}
		}

		public void Draw(){
			for(rect r in this){
				Core.Draw.HollowRect(r.ToAABB(),4,.(0,0,0,100));
			}
		}
	}
}
