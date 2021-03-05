using System;
using System.Diagnostics;
using System.Threading;
using System.Collections;
using System.IO;
using Atma;
using BeefSand.lib;
namespace BeefSand
{
	static
	{
		public static GameApp app ~ delete _;
		public static Simulation sim;
		public static int64 particleCount;
		public static bool debug = false;

		public static void DebugLog(StringView message)
		{
			Console.ForegroundColor = ConsoleColor.DarkYellow;
			Console.Write("SANDSIM:DEBUG: ");
			Console.ForegroundColor = ConsoleColor.White;
			Console.Write(message);
			Console.Write("\n");
		}
	}
	public class GameApp : Scene
	{
		int isMouseDown = 0;
		int32 brushRadius = 100;
		int selectedParticle = 0;
		bool isRunning = true;
		Stopwatch t;

		int camSpeed = 5;

		TimeSpan keypress;
		float2 mouseWorldPos;
		public this() : base(.ExactFit, Screen.Size)
		{
			Core.Atlas.AddDirectory("main", "textures");
			Core.Atlas.Finalize();
			t = new Stopwatch()..Start();
			keypress = t.Elapsed;

			this.Camera.AddRenderer(new SceneRenderer(this) { BlendMode = .Normal });

			let s = new Simulation();
			Camera.SetDesignResolution(1280, 1080, .NoBorder);

			AddEntity(s);

			for (int i = 0; i < sim.chunks.chunkStorage.Count; i++)
			{
				AddEntity(sim.chunks.chunkStorage[i]);
			}
		}
		public ~this()
		{
		}



		public override void Update()
		{
			ImGuiImpl.Update();
			isMouseDown = Core.Input.MouseCheck(.Left) ? 1 : 0;

			brushRadius += (int32)Core.Input.MouseWheel.y;
			brushRadius = Math.Max(5, brushRadius);

			mouseWorldPos = Camera.ScreenToWorld(Core.Input.MousePosition);

			if ((Camera.Position.x <= 0))
			{
				//Setting the x position directly doesn't seem to do anything. This does.
				Camera.Position += .(camSpeed, 0);
			}

			if ((Camera.Position.y <= 0))
			{
				//Setting the x position directly doesn't seem to do anything. This does.
				Camera.Position += .(0, camSpeed);
			}

			if ((Camera.Position.x + Camera.Width) >= (chunkWidth * sim.chunks.xChunks) * simulationSize)
			{
				Camera.Position += .(-camSpeed, 0);
			}

			if ((Camera.Position.y + Camera.Height) >= (chunkHeight * sim.chunks.yChunks) * simulationSize)
			{
				Camera.Position += .(0, -camSpeed);
			}

			if (Core.Input.KeyCheck(.LAlt) && (t.Elapsed.TotalMilliseconds - keypress.TotalMilliseconds) > 500)
			{
				debug = !debug;
				keypress = t.Elapsed;
			}

			if (Core.Input.KeyCheck(.A))
			{
				Camera.Position += .(-camSpeed, 0);
			}
			if (Core.Input.KeyCheck(.D))
			{
				Camera.Position += .(camSpeed, 0);
			}
			if (Core.Input.KeyCheck(.W))
			{
				Camera.Position += .(0, -camSpeed);
			}
			if (Core.Input.KeyCheck(.S))
			{
				Camera.Position += .(0, camSpeed);
			}


			if (Core.Input.KeyCheck(.Left) && (t.Elapsed.TotalMilliseconds - keypress.TotalMilliseconds) > 500)
			{
				selectedParticle--;
				keypress = t.Elapsed;
			}
			else if (Core.Input.KeyCheck(.Right) && (t.Elapsed.TotalMilliseconds - keypress.TotalMilliseconds) > 500)
			{
				selectedParticle++;
				keypress = t.Elapsed;
			}




			selectedParticle = (int)Math.Max(0, Math.Min(Particles.particles.Count - 1, selectedParticle));
			if (isMouseDown != 0)
			{
				DrawFilledCircle((int)mouseWorldPos.x, (int)mouseWorldPos.y, brushRadius, Particles[selectedParticle]);
			}

			Entities.Update();
		}


		void DrawFilledCircle(int x0, int y0, int radius, Particle draw)
		{
			for (int y = (int)Math.Floor(-radius / simulationSize); y < (int)Math.Floor(radius / simulationSize); y++)
			{
				for (int x = (int)Math.Floor(-radius / simulationSize); x < (int)Math.Floor(radius / simulationSize); x++)
				{
					if ((x * x + y * y) < (radius * radius) / (simulationSize * simulationSize))
					{
						int oX = (int)Math.Floor(x0);
						int oY = (int)Math.Floor(y0);
						if (sim.GetElementReference(oX / simulationSize + x, oY / simulationSize + y).id != draw.id)
						{
							sim.SetElement(oX / simulationSize + x, oY / simulationSize + y, draw, true, true);
						}
					}
				}
			}
		}


		int counter = 0;
		public override void FixedUpdate()
		{
		}

		public override void Render()
		{
			base.Render();

			if (debug)
			{
				int drawingAmount = 0;
				int updatingAmount = 0;
				for (int i = 0; i < sim.chunks.chunkStorage.Count; i++)
				{
					if (sim.chunks.chunkStorage[i].updating)
					{
						updatingAmount++;
					}
					if (sim.chunks.chunkStorage[i].drawing)
					{
						drawingAmount++;
					}
				}
				int particleAmount = (chunkWidth * chunkHeight) * updatingAmount;

				Core.Draw.Text(Core.DefaultFont, .(0, 25), scope $"Drawing {drawingAmount} chunks", Color.White);
				Core.Draw.Text(Core.DefaultFont, .(0, 50), scope $"Updating {updatingAmount} chunks (updating a maximum of {particleAmount} particles)", Color.White);
				int2 MPos = Camera.ScreenToWorld(Core.Input.MousePosition);
				int2 CorrectedMPos = .(MPos.x / simulationSize, MPos.y / simulationSize);
				Particle hoveredParticle = sim.GetElement(CorrectedMPos);
				Core.Draw.Text(Core.DefaultFont, Core.Input.MousePosition + .(30, 30), scope $" {Particles.particleNames[hoveredParticle.id]} {Camera.ScreenToWorld(Core.Input.MousePosition)} "..Append(hoveredParticle.stable ? "Stable" : "Unstable"), Color.White, .(0.5f, 0.5f));
			}

			Core.Draw.Text(Core.DefaultFont, .(0, 0), scope $"Drawing particle {Particles.particleNames[selectedParticle]}", Color.White);
			Core.Draw.HollowCircle(.(Core.Input.MousePosition.x, Core.Input.MousePosition.y), brushRadius, 2, 32, Color.Gray);
			Core.Draw.Render(Core.Window, Screen.Matrix);
		}
	}
}
