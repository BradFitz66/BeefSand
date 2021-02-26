using System;
using Atma;
using System.Collections;
namespace BeefSand.lib
{
	struct Chunk{
		public rect chunkRect{get;};
		Particle[,] particles;
		Image renderImage;
		Texture renderTexture;
		uint8 chunkTimer=0;
		public bool isInView=> Core.Window.RenderBounds.Intersects(chunkRect);


		public this(rect r){
			chunkRect=r;
			particles=new Particle[chunkRect.Width,chunkRect.Height];
			renderImage=new .(chunkRect.Width*simulationSize,chunkRect.Height*simulationSize);
			renderTexture=new .(renderImage);
			renderTexture.Filter=.Nearest;
		}

		public void Simulate() mut{
			for(int x=0; x<chunkRect.Width; x++){
				for(int y=0; y<chunkRect.Height; y++){
					Particle upd=particles[x,y];
					if(upd.timer-chunkTimer!=1 && upd.id!=0){
						upd.update(ref upd,0);
					}
				}
			}
			chunkTimer++;
			if(chunkTimer>254){
				chunkTimer=0;
			}
		}

		public Particle GetElement(int x, int y){
			if(WithinBounds(x,y)){
				return particles[x,y];
			}
			else{
				return Particles[2];
			}
		}

		public void SetElement(int x, int y, Particle p) mut{
			if(WithinBounds(x,y)){
				Console.WriteLine("!");
				particles[x,y]=p;
				particles[x,y].pos=.(x,y);
				particles[x,y].timer=chunkTimer;
				particles[x,y].stable=false;

				renderImage.SetPixels(.(x,y,1,1),scope Color[](p.particleColor));
			}
		}


		public bool WithinBounds(int x, int y){
			return chunkRect.Contains(.(x,y));

		}

		public void Draw() {
			renderTexture.SetData(renderImage.Pixels);
			//Scale image to world size
			Core.Draw.Image(renderTexture,aabb2(0,0,chunkRect.Width*16,chunkRect.Height*16));
		}
	}
}
