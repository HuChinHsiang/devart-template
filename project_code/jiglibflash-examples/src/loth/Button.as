package loth{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.ui.Mouse;
	
	public class Button {
		private var _font:String="Trebuchet MS";
		private var _name:String;
		private var _button:SimpleButton;
		private var _target:Object;
		private var _fonction:Function;
		private var ty:int=0;
		
		private var _colText:Array;
		private var _colCont:Array;
		private var _colBg:Array;
		
		private var format00:String;
		private var format01:String;
		private var format02:String;
		private var _n:int;
		private var _border:Boolean;
		private var _icon:Bitmap=null;
		
		// special intro
		private var _cursor:Object;
		private var _bg:Object;
			
		public function Button ( T:String, target:Object, F:Function, x:int=0, y:int=0, w:int=60, h:int=26,  select:Boolean=true, colors:Array=null, name:String="", border:Boolean=true):void
		{
			_border = border;
		
			_fonction = F || new Function();
			_colBg= colors || [ 0x000000, 0x1f2125, 0x1f2125];
			_colText = [ 0xDDDDDD, 0xFFFFFF, 0xFFFFFF];
			_colCont = [ 0xc2c2c2, _colBg[1], _colBg[1]];
			
			format00=  "<p align='center'><font size='11' letterspacing='1' color='#"+_colText[0].toString(16)+"'face='"+_font+"'>";
			format01=  "<p align='center'><font size='11' letterspacing='1' color='#"+_colText[1].toString(16)+"'face='"+_font+"'>";
			format02=  "<p align='center'><font size='11' letterspacing='1' color='#"+_colText[2].toString(16)+"'face='"+_font+"'>";
			
			_button = new SimpleButton();
			if(border)_button.upState = ButtonState( _colBg[0], _colCont[0], T, 1 , w, h,0, 0.05, 0.2, 1);
			else _button.upState = ButtonState( _colBg[0], _colCont[0], T, 1 , w, h,0, 0.1, 0.2, 1);
			if(select){
			_button.name = name;
			_button.overState = ButtonState( _colBg[1], _colCont[1], T, 2 , w, h,10, 0.3, 0.4, 2);
			_button.downState = ButtonState( _colBg[2], _colCont[2], T, 3 ,w, h, 0, 0.1, 0.6, 2);
			_button.hitTestState = _button.upState;
			_button.addEventListener( MouseEvent.CLICK, _fonction );
			_button.addEventListener( MouseEvent.MOUSE_OVER, rollOver )
			_button.addEventListener( MouseEvent.MOUSE_OUT, rollOut )
			}
			_button.x = x
			_button.y = y;
			_target=target;
			_target.addChild( _button ); 
		}
		public function click(e:MouseEvent):void
		{
			_fonction(_n || null);
		}
		private function rollOver(e:MouseEvent):void{
			if(cursor){cursor.mouseCursor("button", 1, _colBg[1])}
			if(_bg){_bg.color(_colBg[1])}
			
			Mouse.cursor = "button";
		}
		private function rollOut(e:MouseEvent):void{
			//if(_bg){_bg.colorOff()}
			Mouse.cursor = "arrow";
		}
		
		public function get bg():Object{return _bg;}
		public function set bg(b:Object):void{_bg = b;}
		
		public function get cursor():Object{return _cursor;}
		public function set cursor(b:Object):void{_cursor = b;}
		
		
		public function get button():SimpleButton{return _button;}
		public function set button(b:SimpleButton):void{_button = b;}
		
		public function get name():String{return _name;}
		public function set name(b:String):void{_name = b;}
		
		
		public function remove():void 
		{
			_button.removeEventListener(MouseEvent.CLICK, _fonction)
			_button.removeEventListener( MouseEvent.MOUSE_OVER, rollOver )
			_button.removeEventListener( MouseEvent.MOUSE_OUT, rollOut )
			clean();	
		//	TweenNano.to(_button, .1, { alpha:0, y:_button.y-50,  delay:.1*_n,ease:Expo.easeOut, onComplete:clean});
		}
		public function clean():void 
		{
			_target.removeChild( _button ); 
		}
		private function ButtonState(color:uint, color2:uint, T:String, N:uint, w:int=80, h:int=30, z:int=0, a:Number=1, a2:Number=1, line:int=2):Sprite 
		{
			var state:Sprite = new Sprite();
			var background:Sprite = Rcarre( color, color2, a, a2, w, h, 20 ,line)
			background.filters=[new BevelFilter(6, 50,0xffffff,1,0xFFFFFF,.5,14,14,4,3)]//,  new BlurFilter(1.5, 1.5, 3)]
			var label:TextField=text(0,ty,w,h);
			background.x=background.y=2
			if (N==1)	label.htmlText =  format00+T;
			if (N==2)	label.htmlText =  format01+T;  
			if (N==3)	label.htmlText =  format02+T;
			label.y=((h+4)-label.height)/2;
			label.x=2;
			state.addChild( background );
			if(_icon!=null){
				var b:Bitmap =new Bitmap(_icon.bitmapData); state.addChild(b); 
				b.x=(w/2)-b.width/2
				if(h>48)b.y=20
				b.filters = [new DropShadowFilter(1,45,0,1,3,3,1,3)];
			}
			state.addChild( label );
			label.filters = [new DropShadowFilter(1,45,0,1,3,3,1,3)];
			
			var bitm:BitmapData = new BitmapData(w+4,h+4,true,0x000000);
			
				bitm.draw(state)
					var bit:Bitmap = new Bitmap(bitm)
					
					var newState:Sprite=new Sprite();
						newState.addChild(bit);
						bit.x=bit.y=-2;
						
						background.filters = null; state.removeChild( background );
						if(b!=null){b.filters=null; state.removeChild(b);  	}
						label.filters =null; state.removeChild( label );
						label=null; background=null;
						state=null; b=null;
						
			return newState;
		}
		
		public function showLoader():void
		{
			_button.removeEventListener(MouseEvent.CLICK, _fonction)
			_button.removeEventListener( MouseEvent.MOUSE_OVER, rollOver )
			_button.removeEventListener( MouseEvent.MOUSE_OUT, rollOut )
			var g:Sprite=new Sprite()
			
			
		}
		
		
		//_______________graph
		private function Rcarre(c:int=0x881212, c2:int=0xFFFFFF, a:Number=1, a2:Number=1, w:int=1, h:int=1, r:int=5, line:int=2 ):Sprite
		{ 	
			var g:Sprite=new Sprite()
		if(_border)	g.graphics.lineStyle( line, c2 , a2);
			g.graphics.beginFill(c, a);
			g.graphics.drawRoundRect(0,0,w,h,r,r);
			g.graphics.endFill()
			return g  
		}
		private function text(x:int, y:int, w:int, h:int, c:int=0):TextField 
		{
			var txt:TextField = new TextField();
			with(txt) { x=x; y=y; height=h; width=w; selectable=false; wordWrap = true; multiline=true; autoSize = "center";}
			return txt;
		}
	}}