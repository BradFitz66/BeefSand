using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	class Chunk
	{
		public int2 chunkIndex;
		public Image chunkRenderImage ~ delete _;
		public Particle[,] particles=new Particle[,] ~ delete _;
		public Texture chunkRenderTexture ~ delete _;
		public uint8 clock = 0;
		public this(int2 index)
		{
			chunkIndex = index;
			chunkRenderImage = new Image(simulationWidth, simulationHeight, Color.Transparent);
			chunkRenderTexture = new .(chunkRenderImage);
			chunkRenderTexture.Filter = .Nearest;
			particles = new Particle[chunkRenderImage.Width, chunkRenderImage.Height];
		}

		public void Update()
		{


			for (int x = 0; x < simulationWidth; x++)
			{
				for (int y = 0; y < simulationHeight-1; y++)
				{
					Particle p = particles[x, y];
					if (p.id == 1 || p.stable || p.timer - clock == 1 || p.update == null)
					{
						continue;
					}
					p.update(ref p, 0);
				}
			}
			clock += 1;
		}
		public void Draw()
		{
			chunkRenderTexture.SetData(chunkRenderImage.Pixels);
			aabb2 a = rect((chunkIndex.x * simulationWidth) * 4, (chunkIndex.y * simulationHeight) * 4, simulationWidth * 4, simulationHeight * 4).ToAABB();
			Core.Draw.Image(chunkRenderTexture, a, Color.White);
		}
	}

	class Chunks
	{
		Chunk[,] chunkStorage;
		int xChunks=0;
		int yChunks=0;

		public this(int ChunkAmountX, int ChunkAmountY)
		{
			chunkStorage = new Chunk[ChunkAmountX, ChunkAmountY];
			for (int x = 0; x < ChunkAmountX; x++)
			{
				for (int y = 0; y < ChunkAmountY; y++)
				{
					chunkStorage[x, y] = new Chunk(.(x, y));
				}
			}
			xChunks=ChunkAmountX;
			yChunks=ChunkAmountY;
		}

		public void GenerateTerrain()
		{
		}

		[Inline]
		public Chunk GetChunkFromBounds(rect bounds)
		{
			return (chunkStorage[bounds.X / simulationWidth, bounds.Y / simulationHeight]);
		}

		[Inline]
		public Chunk FindChunkAtPoint(int2 pos)
		{
			int2 roundedPos = .(
				pos.x - pos.x % simulationWidth,
				pos.y - pos.y % simulationHeight
				);
			return chunkStorage[roundedPos.x / simulationWidth, roundedPos.y / simulationHeight];
		}



		public void Update()
		{for (int x = 0; x < xChunks; x++)
			{
				for (int y = 0; y < yChunks; y++)
				{

					chunkStorage[x,y].Update();
				}
			}
		}

		public void Draw()
		{
			for (int x = 0; x < xChunks; x++)
			{
				for (int y = 0; y < yChunks; y++)
				{

					chunkStorage[x,y].Draw();
				}
			}
		}
	}
}