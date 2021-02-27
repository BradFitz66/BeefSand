using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	class Chunk : Entity
	{
		public int2 chunkIndex;
		public Image chunkRenderImage ~ delete _;
		public Particle[,] particles = new Particle[,] ~ delete _;
		public Texture chunkRenderTexture ~ delete _;
		public uint8 clock = 0;
		rect cameraView;
		public this(int2 index)
		{
			chunkIndex = index;
			chunkRenderImage = new Image(chunkWidth, chunkHeight, Color.Transparent);
			chunkRenderTexture = new .(chunkRenderImage);
			chunkRenderTexture.Filter = .Nearest;
			particles = new Particle[chunkRenderImage.Width, chunkRenderImage.Height];
		}

		protected override void OnUpdate()
		{
			rect chunkBounds = .(chunkWidth * chunkIndex.x, chunkHeight * chunkIndex.y, chunkWidth, chunkHeight);
			cameraView=.((int)Scene.Camera.Position.x/4,(int)Scene.Camera.Position.y/4,Scene.Camera.Width/4,Scene.Camera.Height/4);
			if (!cameraView.Inflate(40).Intersects(chunkBounds))
				return;

			for (int x = 0; x < chunkWidth; x++)
			{
				//Without the -1, stuff gets REAL wacky. Not sure why.
				for (int y = 0; y < chunkHeight - 1; y++)
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
		public override void Render()
		{
			rect chunkBounds = .(chunkWidth * chunkIndex.x, chunkHeight * chunkIndex.y, chunkWidth*4, chunkHeight);
			if (cameraView.Intersects(chunkBounds))
			{
				chunkRenderTexture.SetData(chunkRenderImage.Pixels);
				aabb2 a = rect((chunkIndex.x * chunkWidth) * 4, (chunkIndex.y * chunkHeight) * 4, chunkWidth * 4, chunkHeight * 4).ToAABB();
				Core.Draw.Image(chunkRenderTexture, a, Color.White);
			}
		}
	}

	public class Chunks
	{
		public readonly Chunk[,] chunkStorage ~ DeleteContainerAndItems!(_);
		public readonly int xChunks = 0;
		public readonly int yChunks = 0;

		public this(int ChunkAmountX, int ChunkAmountY)
		{
			chunkStorage = new Chunk[ChunkAmountX, ChunkAmountY];
			for (int x = 0; x < ChunkAmountX; x++)
			{
				for (int y = 0; y < ChunkAmountY; y++)
				{
					Chunk c = new Chunk(.(x, y));
					chunkStorage[x, y] =c;
				}
			}
			xChunks = ChunkAmountX;
			yChunks = ChunkAmountY;
		}



		[Inline]
		public Chunk GetChunkFromBounds(rect bounds)
		{
			return (chunkStorage[bounds.X / chunkWidth, bounds.Y / chunkHeight]);
		}

		[Inline]
		public Chunk FindChunkAtPoint(int2 pos)
		{
			int2 roundedPos = .(
				pos.x - pos.x % chunkWidth,
				pos.y - pos.y % chunkHeight
			);
			return chunkStorage[roundedPos.x / chunkWidth, roundedPos.y / chunkHeight];
		}
	}
}