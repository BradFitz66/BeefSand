using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	struct Chunk : IHashable
	{
		public rect chunkBounds;
		public Image chunkRenderImage;
		public Texture chunkRenderTexture;
		public this(rect r)
		{
			chunkBounds = r;
			chunkRenderImage = new Image(r.Width, r.Height, Color.White);
			chunkRenderTexture = new .(chunkRenderImage);
			chunkRenderTexture.Filter=.Nearest;
		}
		public int GetHashCode()
		{
			return chunkBounds.GetHashCode();
		}
		public void Draw(){
			chunkRenderTexture.SetData(chunkRenderImage.Pixels);
			aabb2 a= rect(chunkBounds.X*4,chunkBounds.Y*4,chunkBounds.Width*4,chunkBounds.Height*4).ToAABB();
			Core.Draw.Image(chunkRenderTexture, a, Color.White);
		}
	}

	class Chunks : Dictionary<Chunk, Particle[,]>
	{
		public this()
		{
		}

		public void Add(rect chunk)
		{
			if (!this.ContainsKey(chunk))
			{
				Particle[,] p=new Particle[chunk.Width, chunk.Height];
				for(int i=0; i<p.Count; i++){
					p[i]=Particles[1];
				}
				Add(Chunk(chunk),p);
			}
		}

		public void Add(Chunk chunk)
		{
			if (!this.ContainsKey(chunk))
			{
				Particle[,] p=new Particle[chunk.chunkBounds.Width, chunk.chunkBounds.Height];
				for(int i=0; i<p.Count; i++){
					p[i]=Particles[1];
				}

				Add(chunk, p);
			}
		}




		public bool ContainsKey(rect chunk)
		{
			for (Chunk c in this)
			{
				if (c.GetHashCode() == chunk.GetHashCode())
				{
					return true;
				}
			}
			return false;
		}

		public void GenerateTerrain()
		{
		}

		public void SimulateChunk(Chunk *chunk){
			Particle[,] particles = this[*chunk];
			for (int x = 0; x < chunk.chunkBounds.Width; x++)
			{
				for (int y = 0; y < chunk.chunkBounds.Height; y++)
				{

					if (particles[x, y].id == 1 || particles[x, y].stable || particles[x, y].timer - simulationClock == 1 || particles[x,y].update==null){
						continue;
					}

					particles[x, y].update(ref particles[x, y], 0);
				}
			}
		}

		public void Update()
		{
			for(Chunk c in this.Keys){

				if(simulationBounds.Inflate(simulationWidth/2).Intersects(c.chunkBounds)){
					SimulateChunk(&c);
				}
			}
		}

		public void Draw()
		{

			for(Chunk c in this.Keys){

				if(simulationBounds.Intersects(c.chunkBounds)){
					c.Draw();
				}
			}
		}

		public Chunk FindChunkAtPoint(int2 pos)
		{
			Chunk chunk = default;
			for (Chunk c in this.Keys)
			{
				if (c.chunkBounds.Contains(pos))
				{
					chunk = c;
					break;
				}
			}
			return chunk;
		}
	}
}
