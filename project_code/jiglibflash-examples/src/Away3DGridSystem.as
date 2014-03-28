package 
{
	import away3d.materials.methods.FogMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.lights.DirectionalLight;
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.debug.Stats;
	import jiglib.math.JNumber3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3d4.Away3D4Mesh;
	import jiglib.plugin.away3d4.Away3D4Physics;

	/**
	 * Example	:	Grid system 
	 * Author	:	Ringo Blanken (http://www.ringo.nl/en)
	 */
	
	[SWF(width="970", height="560",backgroundColor="#000000", frameRate="60")]
	public class Away3DGridSystem extends Sprite 
	{
		// var settings
		private var numSpheres				: uint = 50; // how many sphere's to spawn at start, total objects max is 163 (164 total) due flash limits
		private var numBoxes				: uint = 50;// how many box's to spawn at start
		private var gridSystem				: Boolean = true; // use grid system for physics, otherwise bruteforce is used
		
		// 3d engine
		private var view 					: View3D;
		private var camera					: Camera3D;
		
		// physics
		private var physics					: Away3D4Physics;
		private var ground					: RigidBody;
		private var rigidBodies				: Vector.<RigidBody>;
		
		// materials
		private var sleepMat				: ColorMaterial;
		private var awakeMat				: ColorMaterial;		

		//light objects
		private var sunLight:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		private var fogMethod:FogMethod;

		// =================================================
		// Constructor
		// =================================================
		public function Away3DGridSystem():void {
			this.addEventListener(Event.ENTER_FRAME, tempLoop );
		}
		
		// Make sure the stage is ready
		private function tempLoop(event:Event):void {
			if ( stage.stageWidth > 0 && stage.stageHeight > 0 ) {
				this.removeEventListener( Event.ENTER_FRAME, tempLoop );
				init();
			}
		}

		private function init(event:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			setup();
		}
		
		private function setup():void {
			setupStage();
			setup3DEngine();
			setup3DPhysicEngine();
			setupMaterials();
			setup3DObjectsAndPhysics();
			
			this.addChild(new Stats(view,physics,gridSystem)); // new jiglib stats
			startEventListeners();
		}

		private function setup3DPhysicEngine():void {
			
			JConfig.solverType = "FAST";
			physics = new Away3D4Physics(view, 8);
			
			// setup grid system, only use it when having lots of objects otherwise it may slow down
			if (gridSystem) {
				physics.engine.setCollisionSystem(true, -1500, 0, -1500, 30, 30, 30, 100, 100, 100);
			}
		}

		private function setupMaterials():void {
			sleepMat = new ColorMaterial(0xFF0000);
			sleepMat.ambientColor = 0xadadad;
			sleepMat.specular = .25;
			sleepMat.lightPicker = lightPicker;
			
		
			awakeMat = new ColorMaterial(0xeeee00);		
			//awakeMat.lights = [light];
			awakeMat.ambientColor = 0xadadad;
			awakeMat.specular = .25;
			awakeMat.lightPicker = lightPicker;

		}

		private function setup3DObjectsAndPhysics():void
		{
			rigidBodies = new Vector.<RigidBody>;			

			// ground
			var groundMaterial:ColorMaterial = new ColorMaterial(0x00ff00);
			groundMaterial.lightPicker = lightPicker;
			groundMaterial.ambientColor = 0x303040;
			groundMaterial.ambient = 1;
			groundMaterial.specular = .2;
			groundMaterial.addMethod(fogMethod);

			ground = physics.createGround(groundMaterial, 10000, 10000, 1, 1,true,0);
			ground.movable = false;
			ground.friction = 0.2;
			ground.restitution = 0.9;
			//var groundMesh:Mesh = Away3D4Mesh(ground.skin).mesh; // get ref. to mesh
			rigidBodies.push(ground);
			
			// spawn sphere's
			for (var i:int = 0;i<numSpheres;i++) {
				spawnNewSphere();
			}
			// spawn box
			for (i = 0;i<numBoxes;i++) {
				spawnNewCube();
			}
		}
		
		private function spawnNewSphere(evt:Event=null):void
		{
			// physics and 3d object
			var radius:Number = 25;
			var nextSphere:RigidBody = physics.createSphere(awakeMat,radius,10,10,true);
			nextSphere.friction = .1;
			nextSphere.restitution = .9;

			// position
			nextSphere.x = -1000+2000*Math.random();
			nextSphere.y = 1000+1000*Math.random();
			nextSphere.z = -1000+2000*Math.random();

			// enable mouseevents on mesh
			var meshSphere:Away3D4Mesh = nextSphere.skin as Away3D4Mesh;
			meshSphere.mesh.mouseEnabled = true;
			meshSphere.mesh.extra = { indexrigid: rigidBodies.length };
			meshSphere.mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseClickSphere);
			
			rigidBodies.push(nextSphere);
		}
		
		private function onMouseClickSphere(mouseEvent:MouseEvent3D):void {
			//trace("Click on Sphere with index: ", mouseEvent.target.extra.indexrigid);
			//var rigidBodyClick:RigidBody = rigidBodies[mouseEvent.target.extra.indexrigid];
			//trace("Is the 3D object active ?:", rigidBodyClick.isActive);
		}
		
		private function spawnNewCube(evt:Event=null):void
		{
			var width:Number = (Math.random() * 40) + 20;
			var depth:Number = (Math.random() * 40) + 20;
			var height:Number = (Math.random() * 40) + 20;
			//var color:uint = 0xFFFFFF * Math.random();
			//var mat:ColorMaterial = new ColorMaterial(color);
			//mat.specular = .25;
			var nextCube:RigidBody = physics.createCube(awakeMat, width, height, depth);
			nextCube.x = -1000+2000*Math.random();
			nextCube.y = 1000+1000*Math.random();
			nextCube.z = -1000 + 2000 * Math.random();
			
			rigidBodies.push(nextCube);
		}

		// loop
		private function handleEnterFrame(evt: Event) : void {
			physics.step();
			//changeMatMeshActive(); // checks if object is active and chang
			view.render();
		}
		
		/*
		// Switch skins for active and not active state in the physic engine
		private function changeMatMeshActive():void {
			for each (var rigidBody:RigidBody in rigidBodies) {
				if (rigidBody.isActive) {
					var meshAwake:Away3D4Mesh = rigidBody.skin as Away3D4Mesh;
					meshAwake.mesh.material = awakeMat;
				}
				else {
					// exclude plane types
					if (rigidBody.type != "PLANE") { 
						var meshSleep:Away3D4Mesh = rigidBody.skin as Away3D4Mesh;
						meshSleep.mesh.material = sleepMat;
					}
				}
			} 
		}
		*/
		
		private function startEventListeners():void {
			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, setGravityUP, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, setGravityDown, false, 0, true);
		}			
		
		private function setGravityUP(mouseEvent:MouseEvent):void {
			trace("set gravity up");
			physics.engine.setGravity(JNumber3D.getScaleVector(Vector3D.Y_AXIS, 10));
		}
		
		private function setGravityDown(mouseEvent:MouseEvent):void {
			trace("set gravity down");
			physics.engine.setGravity(JNumber3D.getScaleVector(Vector3D.Y_AXIS, -10));
		}
		
		private function setup3DEngine():void {
			// camera
			camera = new Camera3D();
			camera.x = 0;
			camera.y = 500;
			camera.z = -2000;
			camera.rotationX = 10;
			
			view = new View3D(null,camera);
			view.backgroundColor = 0x0c00ff;
			
			//if (Capabilities.os.toLowerCase().indexOf("windows") != -1)
			view.antiAlias = 4; // set aa

			initLights();
			
			this.addChild(view);
		}

		private function initLights():void
		{
			sunLight = new DirectionalLight(-300, -300, -500);
			sunLight.color = 0xfffdc5;
			sunLight.ambient = 1;
			view.scene.addChild(sunLight);
			
			lightPicker = new StaticLightPicker([sunLight]);
			
			//create a global fog method
			fogMethod = new FogMethod(0, 8000, 0xcfd9de);
		}
		
		
		private function setupStage():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 60;
		}
		
	}
} // eof