using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	class Chunk : Entity
	{
		public int2 chunkIndex;
		public Image chunkRenderImage ~ delete _;
		public Particle[,] particles ~ delete _;
		public Texture chunkRenderTexture ~ delete _;
		public uint8 clock = 0;

		public bool updating=false;
		public bool drawing=false;

		public rect chunkBounds{get; private set;};

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
			chunkBounds = .(chunkWidth * chunkIndex.x, chunkHeight * chunkIndex.y, chunkWidth, chunkHeight);
			cameraView=.((int)Scene.Camera.Position.x/simulationSize,(int)Scene.Camera.Position.y/simulationSize,Scene.Camera.Width/simulationSize,Scene.Camera.Height/simulationSize);
			if (!cameraView.Inflate(20).Intersects(chunkBounds)){
				updating=false;
				return;
			}
			updating=true;
			for (int x = 0; x < chunkWidth; x++)
			{
				for (int y = 0; y < chunkHeight; y++)
				{

					if (particles[x, y].id == 1 || particles[x, y].stable==true || particles[x, y].timer - clock == 1 || particles[x, y].update == null || particles[x, y].solid==true)
					{
						
						continue;
					}
					if(particles[x,y].id==0){
					}
					particles[x, y].update(refparticles[x,y]);

				}
			}
			clock += 1;
		}
		public override void Render()
		{
			if (cameraView.Intersects(chunkBounds))
			{
				drawing=true;
				chunkRenderTexture.SetData(chunkRenderImage.Pixels);
				aabb2 a = rect((chunkIndex.x * chunkWidth) * simulationSize, (chunkIndex.y * chunkHeight) * simulationSize, chunkWidth * simulationSize, chunkHeight * simulationSize).ToAABB();
				Core.Draw.Image(chunkRenderTexture, a, Color.White);
				if(debug){
					rect worldChunkBounds=.(chunkBounds.X*simulationSize,chunkBounds.Y*simulationSize,chunkBounds.Width*simulationSize,chunkBounds.Height*simulationSize);
					Core.Draw.HollowRect(worldChunkBounds,4,Color.Red);
				}
			}
			else{
				drawing=false;
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