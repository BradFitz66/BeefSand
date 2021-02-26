using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	struct Chunk : IHashable{
		public rect chunkBounds;
		public Image chunkRenderImage;
		public Texture chunkRenderTexture;
		public this(rect r){
			chunkBounds=r;
			chunkRenderImage=new Image(r.Width,r.Height,Color.White);
			chunkRenderTexture=new .(chunkRenderImage);
		}
		public int GetHashCode()
		{
			return chunkBounds.GetHashCode();
		}
	}

	class Chunks : Dictionary<Chunk, Particle[,]>
	{

		public Chunk this[rect ind]{
		
		}

		public this(){
		}

		public void Add(rect chunk){
			if(!this.ContainsKey(chunk)){
				Add(Chunk(chunk),new Particle[chunk.Width,chunk.Height]);
			}
		}

		Chunk getChunk(rect r){
			Chunk c=default;
			for(Chunk b in this){
				if(r.GetHashCode()==b.GetHashCode()){
					c=b;
				}
			}
			return c;
		}

		public bool ContainsKey(rect chunk){
			for(Chunk c in this){
				if(c.GetHashCode()==chunk.GetHashCode()){
					return true;
				}
			}
			return false;
		}

		public void FindChunksInView(rect viewport,ref List<Chunk> outList){
			outList=new List<Chunk>();
			for(Chunk r in this){
				if(r.chunkBounds.Intersects(viewport)){
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
