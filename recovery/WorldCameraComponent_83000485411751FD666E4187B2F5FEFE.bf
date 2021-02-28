using Atma;
namespace BeefSand
{
	class WorldCameraComponent : Component
	{
		public float2 worldPos;
		public this() : base(true)
		{

		}

		public override void FixedUpdate()
		{
			let camera = Scene.Camera;
			worldPos=camera.ScreenToWorld(Core.Input.MousePosition);
		}
	}
}
z