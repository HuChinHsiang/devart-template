package 
{
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.containers.View3D;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.CubeGeometry;
	
	import flash.display.GradientType;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.geom.Matrix;
	
	import jiglib.cof.JConfig;
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.math.JNumber3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3d4.Away3D4Mesh;
	import jiglib.plugin.away3d4.Away3D4Physics;
	
	public class GridSystem extends Sprite 
	{
		// var settings
		private var numSpheres				: uint = 60; 
		private var numBoxes				: uint = 60;
		private var boxSize                 : Vector3D = new Vector3D(500,1000,500);
		private var gridSystem				: Boolean = true; 
		// basic
		private var view 					: View3D;
		private var physics					: Away3D4Physics;
		private var ground					: RigidBody;
		private var _rigid  				: Vector.<RigidBody>;
		// materials
		private var groundMat				: ColorMaterial;
		private var sleepMat				: ColorMaterial;
		private var awakeMat				: ColorMaterial;
		//light fog shadow
		private var lightPicker             : StaticLightPicker;
		private var shadowMap               : SoftShadowMapMethod;
		private var fogMethod               : FogMethod;
		// scene colors
		private var _sceneColor             : uint;
		private var _backgroundColor        : uint;
		// base mesh
		private var sphereModel             : Mesh;
		private var boxModel                : Mesh;
		
		
		public function GridSystem() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, setGravityUP, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, setGravityDown, false, 0, true);
				
			init3D();
			onResize(null);
		}
		
		//_______________________________________________________
		//    AWAY3D 4.0
		//_______________________________________________________
		private function init3D():void 
		{
			view = new View3D();
			view.backgroundColor = _backgroundColor;
			this.addChild(view);
			
			view.camera.lens = new PerspectiveLens(75);
			view.camera.lens.near = 1;
			view.camera.lens.far = 2000;
			view.camera.y = 250;
			view.camera.z = 700;
			view.camera.rotationX = 10;
			view.camera.rotationY = 180;
			
			initLights();
			setupMaterials();
			setup3DPhysicEngine();
			addShadows();
		}
		
		//_______________________________________________________
		//    DEMO DELETE
		//_______________________________________________________
		public function deleteAll():void 
		{
			// clean physics
			physics.engine.removeAllBodies();
			physics.engine.removeAllConstraints();
			physics.engine.removeAllControllers();
			// clean listener
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, setGravityUP);
			stage.removeEventListener(MouseEvent.MOUSE_UP, setGravityDown);
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			// clean material
			groundMat.dispose();
			sleepMat.dispose();
			awakeMat.dispose();
			// clean view
			removeChild(view);
			view.dispose();
		}
		
		//_______________________________________________________
		//    MATERIAL
		//_______________________________________________________
		private function setupMaterials():void 
		{
			groundMat = new ColorMaterial(0x333333);
			groundMat.lightPicker = lightPicker;
			groundMat.addMethod(new RimLightMethod(_sceneColor, .6, 2 , RimLightMethod.ADD));
			groundMat.gloss = 50;
			addFog(groundMat);
			
			sleepMat = new ColorMaterial(0x333333);
			sleepMat.lightPicker = lightPicker;
			sleepMat.addMethod(new RimLightMethod(_sceneColor, .6, 2 , RimLightMethod.ADD));
			addFog(sleepMat);
			
			awakeMat = new ColorMaterial(0xeeeeee);
			awakeMat.lightPicker = lightPicker;
			awakeMat.addMethod(new RimLightMethod(_sceneColor, .6, 2 , RimLightMethod.ADD));
			addFog(awakeMat);
		}
		
		private function addShadows():void 
		{
			groundMat.shadowMethod = shadowMap as ShadingMethodBase;
			sleepMat.shadowMethod = shadowMap as ShadingMethodBase;
			awakeMat.shadowMethod = shadowMap as ShadingMethodBase;
		}
		
		//_______________________________________________________
		//    JIGLIB PHYSICS
		//_______________________________________________________
		private function setup3DPhysicEngine():void
		{
			JConfig.solverType = "FAST";
			JConfig.collToll = 0.5;
			JConfig.deactivationTime = 0.2;
			JConfig.numCollisionIterations = 1;
			JConfig.numContactIterations = 2;
			JConfig.numConstraintIterations = 2;
			JConfig.doShockStep = true;
			physics = new Away3D4Physics(view, 10);
			
			// setup grid system, only use it when having lots of objects otherwise it may slow down
			if (gridSystem) physics.engine.setCollisionSystem(true, -1500, 0, -1500, 30, 30, 30, 100, 100, 100);
			
			// init body list
			_rigid = new Vector.<RigidBody>;			
			
			// ground
			ground = physics.createGround(groundMat, 10000, 10000, 1, 1,true,0);
			ground.movable = false;
			ground.friction = 0.3;
			ground.restitution = 0.9;
			
			var i:int;
			
			// spawn sphere's
			for (i = 0; i<numSpheres; i++) {
				spawnNewSphere();
			}
			// spawn box
			for (i = 0; i<numBoxes; i++) {
				spawnNewCube();
			}
		}

		private function spawnNewSphere(e:Event=null):void
		{
			if(sphereModel==null) sphereModel = new Mesh(new SphereGeometry(40,30,20), awakeMat );
			// 3d object clone
			var nSphereModel:Mesh = Mesh(sphereModel.clone());
			// rigidbody
			var nextSphere:JSphere = new JSphere(new Away3D4Mesh(nSphereModel), 40);
			nextSphere.friction = .3;
			nextSphere.restitution = .9;
			nextSphere.mass = 20;
			// position
			nextSphere.x = -(boxSize.x/2)+ boxSize.x*Math.random();
			nextSphere.y = boxSize.y+(_rigid.length*50);
			nextSphere.z =  -(boxSize.z/2)+ boxSize.z * Math.random();
			// showtime
			view.scene.addChild(nSphereModel)
			physics.addBody(nextSphere);
			
			_rigid.push(nextSphere);
		}
		
		private function spawnNewCube(e:Event=null):void
		{
			if(boxModel==null) boxModel = new Mesh(new CubeGeometry(50,50,50), awakeMat );
			// 3d object clone
			var nBoxModel:Mesh = Mesh(boxModel.clone());
			// rigidbody
			var nextCube:JBox = new JBox(new Away3D4Mesh(nBoxModel), 50,50,50);
			nextCube.friction = .3;
			nextCube.restitution = .3;
			nextCube.mass = 10;
			// position
			nextCube.x = -(boxSize.x/2)+ boxSize.x*Math.random();
			nextCube.y = boxSize.y+boxSize.y*Math.random();
			nextCube.z =  -(boxSize.z/2)+ boxSize.z * Math.random();
			// showtime
			view.scene.addChild(nBoxModel)
			physics.addBody(nextCube);
			
			_rigid.push(nextCube);
		}
	
		//_______________________________________________________
		//    LOOP
		//_______________________________________________________
		private function onEnterFrame(event:Event) : void {
			physics.step();
			changeMatMeshActive(); // checks if object is active and chang
			view.render();
		}
		
		private function changeMatMeshActive():void 
		{
			for each (var rigidBody:RigidBody in _rigid) {
				if (rigidBody.isActive) {
					var meshAwake:Away3D4Mesh = rigidBody.skin as Away3D4Mesh;
					meshAwake.mesh.material = awakeMat;
				}else {
					// exclude plane types
					if (rigidBody.type != "PLANE") { 
						var meshSleep:Away3D4Mesh = rigidBody.skin as Away3D4Mesh;
						meshSleep.mesh.material = sleepMat;
					}
				}
			} 
		}
		
		private function setGravityUP(mouseEvent:MouseEvent):void 
		{
			trace("set gravity up");
			physics.engine.setGravity(JNumber3D.getScaleVector(Vector3D.Y_AXIS, 10));
		}
		
		private function setGravityDown(mouseEvent:MouseEvent):void 
		{
			trace("set gravity down");
			physics.engine.setGravity(JNumber3D.getScaleVector(Vector3D.Y_AXIS, -10));
		}
		
		//_______________________________________________________
		//    VIEW OPTION
		//_______________________________________________________
		private function addFog(m:DefaultMaterialBase):void
		{
			var fog:FogMethod = new FogMethod(1000, 2000, _backgroundColor);
			m.addMethod(fog);
		}
		
		public function onResize(event:Event):void
		{
			view.width  = stage.stageWidth;
			view.height = stage.stageHeight;
			onEnterFrame(event);
		}
		
		//_______________________________________________________
		//    LIGHTS
		//_______________________________________________________
		private function initLights():void
		{
			var sunLight:DirectionalLight = new DirectionalLight(-0.1, -1, -1);
			with(sunLight){
				castsShadows = true; 
				color = 0xFFFEEE;
				position = new Vector3D(-300,-300,0);
				ambientColor = _backgroundColor;
				ambient = 0.2;  
				diffuse = 1; 
				specular = 0.6;
			};
			
			var moonLight:PointLight = new PointLight();
			with(moonLight){
				castsShadows = false; 
				color = _sceneColor;
				position=new Vector3D(300,700,0);
				ambientColor = _backgroundColor;
				ambient = 0.2; 
				diffuse = 0.7; 
				specular = 0.5;   
				radius = 300; 
				fallOff =1000; 
			};
			
			view.scene.addChild(sunLight);
			view.scene.addChild(moonLight);
			createVisibleSun(moonLight);
			shadowMap = new SoftShadowMapMethod(sunLight as DirectionalLight);
			lightPicker = new StaticLightPicker([sunLight, moonLight]);
			
		}
		
		private function createVisibleSun(light:PointLight):void
		{
			var bTmp:BitmapData = cercle(light.color, 1, 128,128);
			var material:TextureMaterial = new TextureMaterial( new BitmapTexture(bTmp));
			var plane:Mesh = new Mesh(new PlaneGeometry( 1400, 1400,1,1,true),material);
			plane.rotationX = 90; 
			material.blendMode = "add";
			plane.castsShadows = false;
			light.lookAt(view.camera.position);
			light.addChild(plane);
		}
		
		
		// graphics
		private function cercle( c:int, a:Number=1, w:int=100, h:int=100, x:int=0, y:int=0):BitmapData{
			var g:Shape = new Shape;
			var b:BitmapData = new BitmapData(128,128,false,0x000000)
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(w,h,0,0,0);
			g.graphics.beginGradientFill(GradientType.RADIAL, [c, c, c, c], [.6,.3,.1, 0], [0,50,160,255], mtx);
			g.graphics.drawEllipse(x,y,w,h);
			g.graphics.endFill();
			b.draw(g);
			g.graphics.clear();
			return b;
		}
		// color
		public function get sceneColor():uint { return _sceneColor }
		public function set sceneColor( c:uint ):void { _sceneColor = c }
		
		public function get backgroundColor():uint { return _backgroundColor }
		public function set backgroundColor( c:uint ):void { _backgroundColor = c }

	}
} 