package  
{
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import jiglib.cof.JConfig;
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.math.JMatrix3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3d4.Away3D4Mesh;
	import jiglib.plugin.away3d4.Away3D4Physics;
	import jiglib.vehicles.JCar;
	
	public class CarDrive extends Sprite
	{
		public var view:View3D;
		
		private var container:ObjectContainer3D;
		private var steerFR:ObjectContainer3D;
		private var steerFL:ObjectContainer3D;
		private var wheelFR:Mesh;
		private var wheelFL:Mesh;
		private var wheelBR:Mesh;
		private var wheelBL:Mesh;
		
		private var carBody:JCar;
		private var physics:Away3D4Physics;
		private var boxBody:Vector.<RigidBody>;
		private var ground:RigidBody;
		
		private var _mesh:Vector.<Mesh>;
		private var _rigid:Vector.<RigidBody>;
		// materials
		private var groundMat				: ColorMaterial;
		private var carMat				: ColorMaterial;
		private var wheelMat				: ColorMaterial;
		//light fog shadow
		private var lightPicker             : StaticLightPicker;
		private var shadowMap               : SoftShadowMapMethod;
		private var fogMethod               : FogMethod;
		// scene colors
		private var _sceneColor             : uint;
		private var _backgroundColor        : uint;
		private var SWheels:Mesh
		private var SWheels0:Mesh
		private var carMesh:Mesh
		
		public function CarDrive() 
		{
			super();		
			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		
		private function init(event:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			
			_mesh = new Vector.<Mesh>();
			_rigid = new Vector.<RigidBody>();
			
			init3D();
		}
		
		//_______________________________________________________
		//    AWAY3D 4.0
		//_______________________________________________________
		private function init3D():void {
			
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
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.removeEventListener( KeyboardEvent.KEY_UP, keyUpHandler);
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			// clean material
			groundMat.dispose();
			wheelMat.dispose();
			wheelMat.dispose();
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
			
			carMat = new ColorMaterial(0xeeeeee);
			carMat.lightPicker = lightPicker;
			carMat.addMethod(new RimLightMethod(_sceneColor, .6, 2 , RimLightMethod.ADD));
			carMat.bothSides=true;
			addFog(carMat);
			
			wheelMat = new ColorMaterial(0x333333);
			wheelMat.lightPicker = lightPicker;
			wheelMat.addMethod(new RimLightMethod(_sceneColor, .6, 2 , RimLightMethod.ADD));
			//wheelMat.bothSides=true;
			addFog(wheelMat);
		}
		private function addShadows():void 
		{
			groundMat.shadowMethod = shadowMap as ShadingMethodBase;
			wheelMat.shadowMethod = shadowMap as ShadingMethodBase;
			wheelMat.shadowMethod = shadowMap as ShadingMethodBase;
		}
		
		//_______________________________________________________
		//    JIGLIB PHYSICS
		//_______________________________________________________
		private function setup3DPhysicEngine():void
		{
			physics = new Away3D4Physics(view, 12);
			// ground
			ground = physics.createGround(groundMat, 10000, 10000, 1, 1,true,0);
			ground.movable = false;
			ground.friction = 0.0;
			ground.restitution = 0.6;
			
			initCarMesh();
			addCar();
		}
		
		
		private function addBox() : void
		{
			var material:ColorMaterial = new ColorMaterial(0xeeee00);
			material.lightPicker = lightPicker;
			
			boxBody = new Vector.<RigidBody>();
			for (var i:int = 0; i < 5; i++)
			{
				boxBody[i] = physics.createCube(material, 50, 50, 50 );
				boxBody[i].moveTo(new Vector3D(0, 10 + (60 * i + 50), 0));
			}
		}
		private function initCarMesh() : void
		{
			var Q:int=30
			SWheels = new Mesh()
			SWheels0 = new Mesh(new CylinderGeometry(60, 60, 40, Q, 1, false, false ),wheelMat);
			var axe:Mesh = new Mesh(new CubeGeometry(10, 60, 10 ),carMat);
			var SWheels2:Mesh = new Mesh(new CylinderGeometry(53, 60, 6, Q, 1, false, false ),wheelMat);
			var SWheels3:Mesh = new Mesh(new CylinderGeometry(53, 45, 3, Q, 1, false, false ),carMat);
			var SWheels2b:Mesh = new Mesh(new CylinderGeometry( 60, 53, 6, Q, 1, false, false ),wheelMat);
			var SWheels3b:Mesh = new Mesh(new CylinderGeometry(45, 53, 3, Q, 1, false, false ),carMat);
			var SWheels4:Mesh =new Mesh(new CylinderGeometry(45, 45, 46, Q, 1, false, false ),carMat);
			
			SWheels2.y=23;
			SWheels3.y=24.5;
			SWheels2b.y=-23;
			SWheels3b.y=-24.5;
			
			SWheels4.y=0;
			SWheels0.addChild(axe);
			SWheels0.addChild(SWheels2);
			SWheels0.addChild(SWheels3);
			SWheels0.addChild(SWheels2b);
			SWheels0.addChild(SWheels3b);
			SWheels0.addChild(SWheels4);
			//SWheels0.rotationZ = -90;
			SWheels.addChild(SWheels0)
			SWheels.scale(0.34);
			
			carMesh = new Mesh(new CubeGeometry(60, 10, 180 ),carMat);
			
		}
		private function addCar() : void
		{
			container = new ObjectContainer3D();
			view.scene.addChild(container);
			
			var material:TextureMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64,64,false,0xff0000)));
			material.lightPicker = lightPicker;
			
			var mesh : Mesh;
			for (var i:int = 0; i < 5; ++i) {
				if(i==0 || i==4){ SWheels0.rotationZ = -90;}
				else {SWheels0.rotationZ = 90;}
				
				if(i==1){ mesh = carMesh; mesh.y=-15}
			    else mesh = Mesh(SWheels.clone());
					container.addChild(mesh)
               ;
               // mesh.material = material;
            }
			
			carBody = new JCar(null);
			carBody.setCar(40, 1, 5000);
			carBody.chassis.moveTo(new Vector3D(-300, 200, 0));
			carBody.chassis.rotationY = 90;
			carBody.chassis.mass = 20;
			carBody.chassis.sideLengths = new Vector3D(105, 40, 220);
			//carBody.chassis.y = -40;
			physics.addBody(carBody.chassis);
			
			carBody.setupWheel("WheelFL", new Vector3D(-48, -20, 84), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);
			carBody.setupWheel("WheelFR", new Vector3D(48, -20, 84), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);
			carBody.setupWheel("WheelBL", new Vector3D(-48, -20, -84), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);
			carBody.setupWheel("WheelBR", new Vector3D(48, -20, -84), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);
			
			wheelFL = Mesh(container.getChildAt(0));
			wheelFR = Mesh(container.getChildAt(3));
			wheelBL = Mesh(container.getChildAt(4));
			wheelBL.position = new Vector3D( -48, -20, -84);
			wheelBR = Mesh(container.getChildAt(2));
			wheelBR.position = new Vector3D(48, -20, -84);
			
			steerFL = new ObjectContainer3D();
			steerFL.position = new Vector3D(-48,-20,84);
			steerFL.addChild(wheelFL);
			container.addChild(steerFL);
			
			steerFR = new ObjectContainer3D();
			steerFR.position = new Vector3D(48,-20,84);
			steerFR.addChild(wheelFR);
			container.addChild(steerFR);
			
			addBox();
		}
		
		private function keyDownHandler(event :KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP:
					carBody.setAccelerate(1);
					break;
				case Keyboard.DOWN:
					carBody.setAccelerate(-1);
					break;
				case Keyboard.LEFT:
					carBody.setSteer(["WheelFL", "WheelFR"], -1);
					break;
				case Keyboard.RIGHT:
					carBody.setSteer(["WheelFL", "WheelFR"], 1);
					break;
				case Keyboard.SPACE:
					carBody.setHBrake(1);
					break;
			}
		}
		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP:
					carBody.setAccelerate(0);
					break;
					
				case Keyboard.DOWN:
					carBody.setAccelerate(0);
					break;
					
				case Keyboard.LEFT:
					carBody.setSteer(["WheelFL", "WheelFR"], 0);
					break;
					
				case Keyboard.RIGHT:
					carBody.setSteer(["WheelFL", "WheelFR"], 0);
					break;
				case Keyboard.SPACE:
				   carBody.setHBrake(0);
			}
		}
		
		private function updateCarSkin():void
		{
			if (!carBody)
				return;
				
			container.transform = JMatrix3D.getAppendMatrix3D(carBody.chassis.currentState.orientation, JMatrix3D.getTranslationMatrix(carBody.chassis.currentState.position.x, carBody.chassis.currentState.position.y, carBody.chassis.currentState.position.z));
			
			wheelFL.pitch(carBody.wheels["WheelFL"].getRollAngle());
			wheelFR.pitch(carBody.wheels["WheelFR"].getRollAngle());
			wheelBL.pitch(carBody.wheels["WheelBL"].getRollAngle());
			wheelBR.pitch(carBody.wheels["WheelBR"].getRollAngle());
			
			steerFL.rotationY = carBody.wheels["WheelFL"].getSteerAngle();
			steerFR.rotationY = carBody.wheels["WheelFR"].getSteerAngle();
			
			steerFL.y = carBody.wheels["WheelFL"].getActualPos().y;
			steerFR.y = carBody.wheels["WheelFR"].getActualPos().y;
			wheelBL.y = carBody.wheels["WheelBL"].getActualPos().y;
			wheelBR.y = carBody.wheels["WheelBR"].getActualPos().y;
			
			view.camera.position=container.position.add(new Vector3D(0,100,-200));
			view.camera.lookAt(container.position);
		}
		
		//_______________________________________________________
		//    LOOP
		//_______________________________________________________
		private function onEnterFrame(event:Event):void
        {
			view.render();
			updateCarSkin();
			physics.step(0.1);
		}
		
		//_______________________________________________________
		//    VIEW OPTION
		//_______________________________________________________
		public function onResize(event:Event):void
		{
			view.width  = stage.stageWidth;
			view.height = stage.stageHeight;
			view.render();
		}
		
		private function addFog(m:DefaultMaterialBase):void
		{
			var fog:FogMethod = new FogMethod(1000, 2000, _backgroundColor);
			m.addMethod(fog);
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
			
			lightPicker = new StaticLightPicker([sunLight, moonLight]);
			shadowMap = new SoftShadowMapMethod(sunLight as DirectionalLight);
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