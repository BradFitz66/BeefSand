using static opengl_beef.GL;
using SDL2;

using System;
namespace BeefSand
{
	static class GLHelpers
	{
		static uint compileShader(char8* source, uint shaderType)
		{

			// Create ID for shader
			uint result = glCreateShader(shaderType);
			// Define shader text
			glShaderSource(result, 1, &source, null);
			// Compile shader
			glCompileShader(result);

			//Check vertex shader for errors
			int32 shaderCompiled = GL_FALSE;
			glGetShaderiv(result, GL_COMPILE_STATUS, &shaderCompiled);
			if (shaderCompiled != GL_TRUE)
			{
				int32 logLength = 0;
				glGetShaderiv(result, GL_INFO_LOG_LENGTH, &logLength);
				if (logLength > 0)
				{
					String log = new String();
					glGetShaderInfoLog(result, logLength, &logLength, log);
					delete (log);
				}
				glDeleteShader(result);
				result = 0;
			} else
			{
			}
			return result;
		}
		static void presentBackBuffer(SDL.Renderer *renderer, SDL.Window* win, SDL.Texture* backBuffer, uint programId) {
			int32 oldProgramId=0;
			// Guarrada para obtener el textureid (en driverdata->texture)
			//Detach the texture
			SDL.SetRenderTarget(renderer, null);
			SDL.RenderClear(renderer);
			float tw;
			float th;

			SDL.SDL_GL_BindTexture(backBuffer, out tw, out th);
			if(programId != 0) {
				glGetIntegerv(GL_CURRENT_PROGRAM,&oldProgramId);
				glUseProgram(programId);
			}

			float minx, miny, maxx, maxy;
			float minu, maxu, minv, maxv;

			// Coordenadas de la ventana donde pintar.
			minx = 0.0f;
			miny = 0.0f;
			maxx = 976/4;
			maxy = 976/4;

			minu = 0.0f;
			maxu = 1.0f;
			minv = 0.0f;
			maxv = 1.0f;
			glDrawElements(0,1,1,backBuffer);
			
			SDL.GL_SwapWindow(win);
			
			if(programId != 0) {
				glUseProgram((uint8)oldProgramId);
			}
		}

	}
}
