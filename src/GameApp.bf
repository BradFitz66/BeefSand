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
		public static GameApp app;
		public static Simulation sim;
		public static int64 particleCount;
	}
	public class GameApp : Scene
	{
		int isMouseDown = 0;
		int32 mX;
		int32 mY;
		int32 brushRadius = 100;
		int selectedParticle=0;
		bool isRunning = true;
		Stopwatch t;

		TimeSpan keypress;
		float2 mouseWorldPos;
		public this() : base(.ExactFit, Screen.Size)
		{
			Core.Atlas.AddDirectory("main","textures");
			Core.Atlas.Finalize();
			t=new Stopwatch()..Start();
			keypress=t.Elapsed;
			this.Camera.AddRenderer(new SceneRenderer(this) { BlendMode = .Normal });
			this.Camera.SetDesignResolution(.(976,976),.ShowAllPixelPerfect);
			let s = new Simulation();
			s.Components.Add(new WorldCameraComponent());

			AddEntity(s);
			
			for(int i=0; i<sim.chunks.chunkStorage.Count; i++){
				AddEntity(sim.chunks.chunkStorage[i]);
			}
		}
		public ~this()
		{
			delete (sim);
		}

		public override void Update()
		{
			ImGuiImpl.Update();
			isMouseDown=Core.Input.MouseCheck(.Left) ? 1 : 0;
		
			brushRadius+=(int32)Core.Input.MouseWheel.y;
			brushRadius=Math.Max(5,brushRadius);

			mouseWorldPos=Camera.ScreenToWorld(Core.Input.MousePosition);

			if((Camera.Position.x<=0))
			{
				//Setting the x position directly doesn't seem to do anything. This does.
				Camera.Position=Camera.Position * .(0,1);
			}

			if(Core.Input.KeyCheck(.A)){
				Camera.Position+=.(-3,0);
			}
			if(Core.Input.KeyCheck(.D)){
				Camera.Position+=.(3,0);
			}

			if(Core.Input.KeyCheck(.Left) && (t.Elapsed.TotalMilliseconds - keypress.TotalMilliseconds)>500){
				selectedParticle--;
				keypress=t.Elapsed;
			}
			else if(Core.Input.KeyCheck(.Right) && (t.Elapsed.TotalMilliseconds - keypress.TotalMilliseconds)>500){
				selectedParticle++;
				keypress=t.Elapsed;
			}
			



			selectedParticle = (int)Math.Max(0,Math.Min(Particles.particles.Count-1,selectedParticle));
			if (isMouseDown!=0)
			{
				DrawFilledCircle((int)mouseWorldPos.x, (int)mouseWorldPos.y, brushRadius,Particles[selectedParticle]);
			}

			Entities.Update();

			

		}


		void DrawFilledCircle(int x0, int y0, int radius, Particle draw)
		{
			for(int y=(int)Math.Floor(-radius/simulationSize); y<(int)Math.Floor(radius/simulationSize); y++){
				for(int x=(int)Math.Floor(-radius/simulationSize); x<(int)Math.Floor(radius/simulationSize); x++){
					if((x*x+y*y)<(radius*radius)/(4*4)){
						int oX=(int)Math.Floor(x0);
						int oY=(int)Math.Floor(y0);
						sim.SetElement(oX/4+x,oY/4+y,draw);
					}
				}
			}
		}


		int counter=0;
		public override void FixedUpdate()
		{
		}

		public override void Render()
		{
			base.Render();
			sim.Draw();
			float2 textSize = Core.DefaultFont.MeasureString("Hello");
			Core.Draw.Text(Core.DefaultFont,.(0,0),scope $"Drawing particle {Particles.particleNames[selectedParticle]}",Color.Black);
			Core.Window.Resizable=false;
			Core.Draw.HollowCircle(.(mouseWorldPos.x,mouseWorldPos.y),brushRadius,2,32,Color.Gray);

			Core.Draw.Render(Core.Window,Screen.Matrix);
		}
	}
}
