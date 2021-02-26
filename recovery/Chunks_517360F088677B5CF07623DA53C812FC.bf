using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	struct Chunk : IHashable
	{
		public rect chunkBounds;
		public Image chunkRenderImage;
		public uint8 chunkClock = 0;
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
				Add(Chunk(chunk), new Particle[chunk.Width, chunk.Height]);
			}
		}

		public void Add(Chunk chunk)
		{
			if (!this.ContainsKey(chunk))
			{
				Add(chunk, new Particle[chunk.chunkBounds.Width, chunk.chunkBounds.Height]);
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

		public void Update(Chunk chunk, ref uint8 simulationClock)
		{
			Particle[,] particles = this[chunk];
			for (int x = 0; x < chunk.chunkBounds.Width; x++)
			{
				for (int y = 0; y < chunk.chunkBounds.Height; y++)
				{
					if (particles[x, y].id == 1 || particles[x, y].stable || particles[x, y].timer - chunk.chunkClock == 1)
						continue;

					particles[x, y].update(ref particles[x, y], 0);
				}
			}
		}

		public void Draw()
		{
			Console.WriteLine(simu);
			for(Chunk c in this){

				if(Core.Window.RenderBounds.Intersects(c.chunkBounds)){
					c.Draw();
				}
			}
		}

		public Chunk FindChunkAtPoint(int2 pos)
		{
			Chunk chunk = default;
			for (Chunk c in this)
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
