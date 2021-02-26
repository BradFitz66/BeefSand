using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	class Chunk
	{
		public Image chunkRenderImage ~ delete _;
		public Particle[,] particles ~ delete _;
		public Texture chunkRenderTexture ~ delete _;
		public uint8 clock=0;
		public this(rect r)
		{
			
			chunkRenderImage = new Image(r.Width, r.Height, Color.Transparent);
			chunkRenderTexture = new .(chunkRenderImage);
			chunkRenderTexture.Filter = .Nearest;
			particles = new Particle[chunkRenderImage.Width,chunkRenderImage.Height];
		}

		public void Update(rect chunkBounds){
			for (int x = 0; x < chunkBounds.Width; x++)
			{
				for (int y = 0; y < chunkBounds.Height; y++)
				{


					if(x>particles.GetLength(0)-1 || chunkY>particles.GetLength(1)-1)
						return;
					Particle p = particles[x,y];
					if (p.id== 1 || p.stable || p.timer - clock == 1 || p.update == null)
					{
						continue;
					}
					
					p.update(ref p, 0);
				}
			}
			clock+=1;
		}
		public void Draw(rect chunkBounds){
			chunkRenderTexture.SetData(chunkRenderImage.Pixels);
			aabb2 a = rect(chunkBounds.X * 4, chunkBounds.Y * 4, chunkBounds.Width * 4, chunkBounds.Height * 4).ToAABB();
			Core.Draw.Image(chunkRenderTexture, a, Color.White);
		}
	}

	class Chunks
	{
		Dictionary<rect, Chunk> chunkStorage = new Dictionary<rect, Chunk>() ~ DeleteDictionaryAndValues!(_);
		public this()
		{
		}

		public void GenerateTerrain()
		{
		}

		
		public void Add(rect chunkBounds){
			if(!chunkStorage.ContainsKey(chunkBounds))
				chunkStorage.Add(chunkBounds,new Chunk(chunkBounds));
		}

		public Chunk GetChunkFromBounds(rect bounds){
			Chunk c=default;
			if(chunkStorage.ContainsKey(bounds)){
			   c=chunkStorage[bounds];
			}

			return c;
		}

		public rect FindChunkAtPoint(int2 pos)
		{
			rect chunkBounds = default;
			for (rect c in chunkStorage.Keys)
			{
				if (c.Contains(pos))
				{
					chunkBounds = c;
					break;
				}
			}
			return chunkBounds;
		}

		

		public void Update()
		{
			for (rect c in chunkStorage.Keys)
			{
				if (simulationBounds.Intersects(c))
				{
					chunkStorage[c].Update(c);
				}
			}
		}

		public void Draw()
		{
			for (rect r in chunkStorage.Keys)
			{
				if (simulationBounds.Intersects(r))
				{
					Chunk c = chunkStorage[r];
					c.Draw(r);
				}
			}
		}

	}
}
