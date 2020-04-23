package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	public class Button extends Sprite
	{
		private var text:TextField;
		private var whenClicked:Function;
		
		public function Button(name:String,whenClicked:Function)
		{
			this.whenClicked=whenClicked;
			this.name=name;
			
			mouseChildren=false;
			buttonMode=true;
			
			disable();
		}
		
		public function enable():void
		{
			addEventListener(MouseEvent.CLICK,clickHandler);
			addEventListener(MouseEvent.ROLL_OVER,overHandler);
			addEventListener(MouseEvent.ROLL_OUT,outHandler);
			
			useHandCursor=true;
			
			outHandler(null);
		}
		public function disable():void
		{
			try
			{
				removeEventListener(MouseEvent.CLICK,clickHandler);
				removeEventListener(MouseEvent.ROLL_OVER,overHandler);
				removeEventListener(MouseEvent.ROLL_OUT,outHandler);
			}
			catch(error:Error)
			{
			}
			
			draw(0xAAAAAA,0xFFFFFF);
			
			useHandCursor=false;
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			whenClicked();
		}
		private function overHandler(event:MouseEvent):void
		{
			draw(0x000000,0xDDDDDD);
		}
		private function outHandler(event:MouseEvent):void
		{
			draw(0x000000,0xFFFFFF);
		}
		
		private function draw(edgeColor:int,fillColor:int):void
		{
			graphics.clear();
			graphics.lineStyle(1,edgeColor);
			graphics.beginFill(fillColor);
			graphics.drawRect(0,0,120,20);
			graphics.endFill();
			
			removeChildren();
			
			var format:TextFormat=new TextFormat();
			format.color=edgeColor;
			
			text=new TextField();
			text.autoSize=TextFieldAutoSize.LEFT;
			text.defaultTextFormat=format;
			text.text=name;
			addChild(text);
		}
	}
}
