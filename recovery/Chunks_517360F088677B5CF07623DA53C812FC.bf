using System;
using Atma;
using System.Linq;
using System.Collections;
namespace BeefSand.lib
{
	[Optimize]
	class Chunk : Entity
	{
		public int2 chunkIndex;
		public int sleepTimer = 0;
		public uint8 clock = 0;

		public Image chunkRenderImage ~ delete _;
		public Particle[] particles ~ delete _;
		public Texture chunkRenderTexture ~ delete _;

		public bool dirty = false;
		public bool updating = false;
		public bool drawing = false;

		public rect dirtyrect;
		public rect dirtyrectprev;
		public rect chunkBounds { get; private set; };
		rect cameraView;

		public this(int2 index)
		{
			chunkIndex = index;
			chunkRenderImage = new Image(chunkWidth, chunkHeight, Color.Transparent);

			chunkRenderTexture = new .(chunkRenderImage);
			chunkRenderTexture.Filter = .Nearest;

			chunkBounds = .(chunkWidth * chunkIndex.x, chunkHeight * chunkIndex.y, chunkWidth, chunkHeight);
			particles = new Particle[chunkRenderImage.Width * chunkRenderImage.Height];
			dirtyrect = .(chunkWidth * chunkIndex.x, chunkHeight * chunkIndex.y, chunkWidth, chunkHeight);
		}

		int minX = chunkWidth;
		int minY = chunkHeight;
		int maxX = 0;
		int maxY = 0;

		public void UpdateDirtyRect(int2 newPos)
		{
			dirtyrect.Merge(newPos);
			//dirtyrect.Inflate(2);
			dirtyrect = dirtyrect.Intersection(chunkBounds);
		}

		protected override void OnUpdate()
		{
			cameraView = .((int)Scene.Camera.Position.x / simulationSize, (int)Scene.Camera.Position.y / simulationSize, Scene.Camera.Width / simulationSize, Scene.Camera.Height / simulationSize);
			if (!dirty)
			{
				updating = false;
				return;
			}
			updating = true;

			minX = chunkBounds.Max.x;
			minY = chunkBounds.Max.y;
			maxX = chunkBounds.X;
			maxY = chunkBounds.Y;

			for (int x = dirtyrect.Left - chunkBounds.X; x < dirtyrect.Right - chunkBounds.X; x++)
			{
				for (int y = dirtyrect.Top - chunkBounds.Y; y < dirtyrect.Bottom - chunkBounds.Y; y++)
				{
					Particle* p = &particles[y * chunkWidth + x];
					if (p.id == 1 || p.stable == true || p.timer - clock == 1 || p.update == null || p.solid == true)
						continue;
					p.lifetimer += 1;
					
					(bool, int2) upd = p.update(&particles[y * chunkWidth + x]);
					if (upd.0)
					{
						dirty = true;
						minX = Math.Min(minX, upd.1.x);
						minY = Math.Min(minY, upd.1.y);
						maxX = Math.Max(maxX, upd.1.x);
						maxY = Math.Max(maxY, upd.1.y);
					}
				}
			}
			dirtyrect = .(.(minX, minY), .(maxX, maxY));

			//dirtyrect is being inflated by this much to stop particles from going out of bounds of the dirty rect and
			// not being updated.
			dirtyrect = dirtyrect.Inflate(20);

			//Update a neighbouring chunk dirty rect if one of this chunks particles enters it while it's updating. Doesn't really seem to work a lot of the time.
			//Tried placing this before I inflate too. Doesn't seem to change anything.
			for (var p in dirtyrect.outter)
			{
				if (!this.chunkBounds.Contains(p) && sim.GetElement(p).id != 1 && !sim.GetElement(p).solid)
				{
					Chunk n = sim.chunks.GetChunkFromPoint(p);
					//just incase.
					if (n != this)
					{
						n.UpdateDirtyRect(p);
					}
				}
			}

			dirtyrect = dirtyrect.Intersection(chunkBounds);

			if (dirtyrect == chunkBounds)
			{
				//If dirty rect is same as chunk bounds (meaning it's not updating anything, most likely), increase
				// chunk's sleep timer
				sleepTimer++;
				if (sleepTimer > 250)
				{
					//Force chunk to be not dirty once timer has reached threshold.
					sleepTimer = 0;
					dirty = false;
				}
			}
			clock += 1;
		}
		public override void Render()
		{
			if (cameraView.Intersects(chunkBounds))
			{
				drawing = true;
				chunkRenderTexture.SetData(chunkRenderImage.Pixels);
				aabb2 a = rect((chunkIndex.x * chunkWidth) * simulationSize, (chunkIndex.y * chunkHeight) * simulationSize, chunkWidth * simulationSize, chunkHeight * simulationSize).ToAABB();
				Core.Draw.Image(chunkRenderTexture, a, Color.White);
				if (debug)
				{
					if (updating)
					{
						rect worldDirtyRectBounds = .(dirtyrect.X * simulationSize, dirtyrect.Y * simulationSize, dirtyrect.Width * simulationSize, dirtyrect.Height * simulationSize);
						Core.Draw.HollowRect(worldDirtyRectBounds, 2, Color.Green);
					}
					Core.Draw.HollowRect(a, 1, Color.White);
				}
			}
			else
			{
				drawing = false;
			}
		}
	}

	public class Chunks
	{
		public readonly Chunk[,] chunkStorage ~ delete ;
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
					chunkStorage[x, y] = c;
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
		public Chunk GetChunkFromPoint(int2 pos)
		{
			int2 roundedPos = .(
				pos.x - pos.x % chunkWidth,
				pos.y - pos.y % chunkHeight
				);
			return chunkStorage[roundedPos.x / chunkWidth, roundedPos.y / chunkHeight];
		}
	}
}