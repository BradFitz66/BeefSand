using System;
using System.Collections;
using System.Diagnostics;

using SDL2;
namespace BeefSand
{
	//Globals
	static
	{
		public static GameApp gameapp;
		public static Random r ~ delete _;
	}

	class Program
	{
		public static int Main()
		{
			r = new Random();
			return Atma.Core.RunInitialScene<GameApp>("Falling Sand", 976, 976);
		}

	}
}
namespace Atma
{

	public extension Core
	{
		static this()
		{
			Core.Emitter.AddObserver<CoreEvents.Initialize>(new => Initialize);
		}

		static ~this()
		{
			Core.Emitter.RemoveObserver<CoreEvents.Initialize>(scope => Initialize);
		}
		 	
		static void Initialize(CoreEvents.Initialize e)
		{
			Console.WriteLine("Loading font..");
			DefaultFont = Core.Assets.LoadFont(@"fonts/PressStart2P.ttf", 16);
		}
	}
	public extension rect : IHashable{
		public int GetHashCode()
		{
			return ((int)((UInt32)X ^
				(((UInt32)Y << (UInt32)13) | ((UInt32)Y >> (UInt32)19)) ^
				(((UInt32)Width << (UInt32)26) | ((UInt32)Width >>  (UInt32)6)) ^
				(((UInt32)Height <<  (UInt32)7) | ((UInt32)Height >> (UInt32)25))));
		}
		static new public bool operator==(rect a, rect b)
		{
			return a.GetHashCode()==b.GetHashCode();
		}
	}
}