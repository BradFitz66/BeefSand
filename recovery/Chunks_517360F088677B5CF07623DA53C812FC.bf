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

		public this(){
			
		}

		public void Add(rect chunk){
			if(!this.ContainsKey(chunk)){
				Add(Chunk(chunk),new Particle[chunk.Width,chunk.Height]);
			}
		}



		public bool ContainsKey(rect chunk){
			for(Chunk c in this){
				if(c.GetHashCode()==chunk.GetHashCode()){
					return true;
				}
			}
			return false;
		}

		public void GenerateTerrain(){
		}

		public void Update(Chunk chunk, ref uint8 simulationClock){
			Particle[,] particles=this[chunk];

			
		}

		public void Draw(){
			
		}
	}
}
