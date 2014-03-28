package  
{
	import jiglib.plugin.away3d4.Away3D4Physics;
	import jiglib.physics.RigidBody;
	import away3d.materials.ColorMaterial;
	import away3d.containers.View3D;
	import away3d.lights.PointLight;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import jiglib.cof.JConfig;
	import jiglib.debug.Stats;
	
	[SWF(width="800", height="600", frameRate="60")]
	public class Away3DStackingTest extends Sprite
	{
		private var view:View3D;
		private var mylight:PointLight;
		private var material:ColorMaterial;
		
		private var ground:RigidBody;
		private var ballBody:Vector.<RigidBody>;
		private var boxBody:Vector.<RigidBody>;
		
		private var physics:Away3D4Physics;
		
		private var keyRight   :Boolean = false;
		private var keyLeft    :Boolean = false;
		private var keyForward :Boolean = false;
		private var keyReverse :Boolean = false;
		private var keyUp:Boolean = false;
		
		public function Away3DStackingTest() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			init3D();
			
			this.addChild(new Stats(view, physics));
		}
		
		private function init3D():void
		{
			view = new View3D();
			addChild(view);
			
			mylight = new PointLight();
			view.scene.addChild(mylight);
			
			
			mylight.color = 0xffffff;
			mylight.diffuse = 1;
			mylight.y = 0;
			mylight.z = -700;
			
			view.camera.y = 300;
			view.camera.z = mylight.z;
			view.camera.rotationX = 20;
			
			JConfig.solverType = "FAST";
			JConfig.doShockStep = true;
			physics = new Away3D4Physics(view, 8);
			
			material = new ColorMaterial(0x77ee77,1);
		//	material.lights = [mylight];
			
			ground = physics.createCube(material, 500, 20, 500);
			ground.movable = false;
			ground.friction = 0.1;
			ground.restitution = 0.9;
			
			material = new ColorMaterial(0xeeee00,1);
		//	material.lights = [mylight];
			
			ballBody = new Vector.<RigidBody>();
			//var color:uint;
			for (var i:int = 0; i < 10; i++)
			{
				ballBody[i] = physics.createSphere(material, 22);
				ballBody[i].moveTo(new Vector3D( -100, 50 * i + 50, -200));
			}
			ballBody[0].mass = 10;
			physics.getMesh(ballBody[0]).material= new ColorMaterial(0xff8888,1);
			//physics.getMesh(ballBody[0]).material.lights=[mylight];
			
			boxBody=new Vector.<RigidBody>();
			var xNum:int = 1;
			var yNum:int = 15;
			var zNum:int = 1;
			var num:int = 0;
			var boxSize:Vector3D = new Vector3D(50, 50, 50);
			var xstart:Number = -xNum * boxSize.x / 2;
			var ystart:Number = ground.currentState.position.y + boxSize.y / 2;
			var zstart:Number = -zNum * boxSize.z / 2;
			for (i = 0; i < xNum; i++ )
			{
				for (var j:int = 0; j < yNum; j++ )
				{
					for (var k:int = 0; k < zNum; k++ )
					{
						boxBody[num] = physics.createCube(material, boxSize.x, boxSize.y,  boxSize.z );
						boxBody[num].mass = 0.1;
						boxBody[num].moveTo(new Vector3D(xstart + (boxSize.x + 2) * i, ystart + boxSize.y * j, zstart + (boxSize.z + 2) * k));
						num++;
					}
				}
			}
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP:
					keyForward = true;
					keyReverse = false;
					break;
				
				case Keyboard.DOWN:
					keyReverse = true;
					keyForward = false;
					break;
				
				case Keyboard.LEFT:
					keyLeft = true;
					keyRight = false;
					break;
				
				case Keyboard.RIGHT:
					keyRight = true;
					keyLeft = false;
					break;
				case Keyboard.SPACE:
					keyUp = true;
					break;
				break;
			}
		}
		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP:
					keyForward = false;
					break;
				
				case Keyboard.DOWN:
					keyReverse = false;
					break;
				
				case Keyboard.LEFT:
					keyLeft = false;
					break;
				
				case Keyboard.RIGHT:
					keyRight = false;
					break;
				case Keyboard.SPACE:
					keyUp=false;
			}
		}
		
		private function resetBody():void
		{
			var i:int=0;
			for each(var body:RigidBody in ballBody)
			{
				if (body.currentState.position.y < -200)
				{
					body.moveTo(new Vector3D( 0, 1000 + (50 * i + 50), 0));
				}
				i++;
			}
			i=0;
			for each(body in boxBody)
			{
				if (body.currentState.position.y < -200)
				{
					body.moveTo(new Vector3D(0, 1000 + (50 * i + 50), 0));
				}
				i++;
			}
		}
		
		private function onEnterFrame(event:Event):void
        {
			if(keyLeft)
			{
				ballBody[0].addWorldForce(new Vector3D(-150,0,0),ballBody[0].currentState.position);
			}
			if(keyRight)
			{
				ballBody[0].addWorldForce(new Vector3D(150,0,0),ballBody[0].currentState.position);
			}
			if(keyForward)
			{
				ballBody[0].addWorldForce(new Vector3D(0,0,150),ballBody[0].currentState.position);
			}
			if(keyReverse)
			{
				ballBody[0].addWorldForce(new Vector3D(0,0,-150),ballBody[0].currentState.position);
			}
			if(keyUp)
			{
				ballBody[0].addWorldForce(new Vector3D(0, 150, 0), ballBody[0].currentState.position);
			}
			
			physics.step(0.1);
			
			resetBody();
            view.render();
        }
	}
}