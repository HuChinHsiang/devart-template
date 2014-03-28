package {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import loth.Button;
	import loth.FullStats;
	
	/**
	 * @author Ringo Blanken http://www.ringo.nl/en/
	 * @design Laurent Thillet http://perso.numericable.fr/chamaslot/
	 */
	
	[SWF(backgroundColor="#000", frameRate="60", width="600", height="600")]
	
	public class MainJiglib extends Sprite 
	{
		private var startDemo:int = 0;
		private var displayStats:Boolean=false;
		
		private var demo:Object;
		private var top:Sprite;
		private var buttons:Vector.<Button>;
		private var border:Sprite;
		private var stats:Sprite;
		
		private var sceneColor:uint
		
		public function MainJiglib()
		{
			this.addEventListener(Event.ENTER_FRAME, stageReady);
		}
		
		private function stageReady(event : Event) : void
		{
			if ( stage.stageWidth > 0 && stage.stageHeight > 0 ) {
				this.removeEventListener(Event.ENTER_FRAME, stageReady);
				init();
			}
		}
		
		private function init() : void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 60;
			stage.addEventListener(Event.RESIZE, onResize);
			
			startDemo = int( Math.random()*4 )
			sceneColor = 0xFFFFFF * Math.random();
			
			if(displayStats){
			stats = new FullStats(100,5,0,false,false,true,1);
			this.addChild(stats);
			}
			
			border = new Sprite();
			this.addChild(border);
			
			onResize(null);
			
			initInterface();
			launchDemo(null);
		}
		
		public function onResize(event:Event):void
		{
			if(demo) demo.onResize(event);
			if(stats) stats.y = stage.stageHeight-65;
			if(border) updateBorder(sceneColor, .3, stage.stageWidth, stage.stageHeight);
		}
		
		private function initInterface() : void
		{
			var colorDemo:Array = [0xc2c2c2, 0x404040, 0x404040];
			var colorPlus:Array = [0xc2c2c2, 0x2233EE, 0x2233EE];
			var bsize:int = 70;
			top = new Sprite();
			stage.quality="high";
			buttons = new Vector.<Button>();
			buttons.push(
				 new Button("grid<br>system"   , top, launchDemo, 10       , 10, bsize, 40, true, colorDemo, "0")
				,new Button("content<br>box"   , top, launchDemo, 10+80    , 10, bsize, 40, true, colorDemo, "1")
				,new Button("terrain"          , top, launchDemo, 10+(80*2), 10, bsize, 40, true, colorDemo, "2")
				,new Button("car<br>drive"     , top, launchDemo, 10+(80*3), 10, bsize, 40, true, colorDemo, "3")
			);
			stage.quality="low";
			this.addChild(top);
		}
		
		private function launchDemo(e:Event) : void
		{
			var n:int = startDemo;
			if(e) n = Number(e.target.name);
			if(demo!=null) { demo.deleteAll(); }
			switch(n){
				case 0: demo = new GridSystem(); break;
				case 1: demo = new ContentBox(); break;
				case 2: demo = new TerrainTest(); break;
				case 3: demo = new CarDrive(); break;
				//case 4: demo = new TriangleMesh(); break;
				//case 5: demo = new CollisionEventTest(); break;
			}
			sceneColor = 0xFFFFFF * Math.random();
			demo.sceneColor = sceneColor;
			demo.backgroundColor = darkenColor(sceneColor, 80);
			this.addChildAt(demo as Sprite, 0);
			onResize(null);
		}
		
		private function deleteButton(e:Event=null):void 
		{
			if(buttons.length>0){
				while(buttons.length){ buttons[buttons.length-1].remove(); buttons.pop(); };
				buttons = new Vector.<Button>();
			}
		}
		
		
		// graph
		private function updateBorder(c:int=0x881212, a:Number=1, w:int=1, h:int=1 ):void
		{ 	
			border.graphics.clear();
			border.graphics.lineStyle( 4, c , a);
			border.graphics.beginFill(0x00, 0);
			border.graphics.drawRect(0,0,w,h);
			border.graphics.endFill()
		}
		// color
		public static function darkenColor(hexColor:Number, percent:Number):Number{
			if(isNaN(percent)) percent=0; if(percent>100) percent=100; if(percent<0) percent=0;
			var factor:Number = 1-(percent/100), rgb:Object=hexToRgb(hexColor);
			rgb.r*=factor; rgb.b*=factor; rgb.g*=factor;
			return rgbToHex(Math.round(rgb.r),Math.round(rgb.g),Math.round(rgb.b));
		}
		public static function rgbToHex(r:Number, g:Number, b:Number):Number {
			return(r<<16 | g<<8 | b);
		}
		public static function hexToRgb (hex:Number):Object{
			return {r:(hex & 0xff0000) >> 16,g:(hex & 0x00ff00) >> 8,b:hex & 0x0000ff};
		}
		
		
	}
}