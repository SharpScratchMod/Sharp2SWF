package
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.net.*;
	
	[SWF(width="300",height="200")]
	
	public class Main extends Sprite
	{
		private var exeButton:Button;
		private var swfButton:Button;
		private var createButton:Button;
		
		private var file:FileReference;
		
		private var exeData:ByteArray;
		private var swfData:ByteArray;
		
		public function Main():void
		{
			var titleFormat:TextFormat=new TextFormat();
			titleFormat.underline=true;
			
			var title:TextField=new TextField();
			title.defaultTextFormat=titleFormat;
			title.autoSize=TextFieldAutoSize.LEFT;
			title.text="\"Create Projector\" reimplementation for new Flash Player";
			title.x=5;
			title.y=0;
			addChild(title);
			
			exeButton=new Button("Load Flash Player EXE",openEXE);
			exeButton.x=10;
			exeButton.y=30;
			addChild(exeButton);
			exeButton.enable();
			
			var downloadButton:Button=new Button("Download Link",openEXELink);
			downloadButton.x=140;
			downloadButton.y=30;
			addChild(downloadButton);
			downloadButton.enable();
			
			swfButton=new Button("Load SWF File",openSWF);
			swfButton.x=10;
			swfButton.y=60;
			addChild(swfButton);
			
			createButton=new Button("Create Projector",create);
			createButton.x=10;
			createButton.y=90;
			addChild(createButton);
			
			var detailsFormat:TextFormat=new TextFormat();
			detailsFormat.italic=true;
			detailsFormat.color=0xAAAAAA;
			
			var details:TextField=new TextField();
			details.autoSize=TextFieldAutoSize.LEFT;
			details.defaultTextFormat=detailsFormat;
			details.text="This tool allows for conversion of SWF to EXE using\nrecent versions of Flash Player in which the \"Create\nProjector\" menu item has been disabled. A downloaded\nWindows Flash Player \"projector\" EXE is required and\ncan be acquired from the link above.";
			details.x=5;
			details.y=130;
			addChild(details);
		}
		
		private function openEXE():void
		{
			file=new FileReference();
			file.addEventListener(Event.SELECT,openEXESelect);
			file.browse();
		}
		private function openEXESelect(event:Event):void
		{
			file.addEventListener(Event.COMPLETE,openEXEComplete);
			file.load();
		}
		private function openEXEComplete(event:Event):void
		{
			exeData=file.data;
			swfButton.enable();
		}
		
		private function openEXELink():void
		{
			var request:URLRequest=new URLRequest("https://www.adobe.com/support/flashplayer/debug_downloads.html");
			navigateToURL(request);
		}
		
		private function openSWF():void
		{
			file=new FileReference();
			file.addEventListener(Event.SELECT,openSWFSelect);
			file.browse();
		}
		private function openSWFSelect(event:Event):void
		{
			file.addEventListener(Event.COMPLETE,openSWFComplete);
			file.load();
		}
		private function openSWFComplete(event:Event):void
		{
			swfData=file.data;
			createButton.enable();
		}
		
		private function create():void
		{
			var output:ByteArray=new ByteArray();
			
			output.writeBytes(exeData,0,exeData.length);
			
			output.writeBytes(swfData,0,swfData.length);
			
			var endData:ByteArray=new ByteArray();
			endData.writeByte(0x56);
			endData.writeByte(0x34);
			endData.writeByte(0x12);
			endData.writeByte(0xFA);
			
			var sizeTemp:int=swfData.length;
			while(sizeTemp>0)
			{
				var byte:int=sizeTemp%0x100;
				endData.writeByte(byte);
				sizeTemp/=0x100;
			}
			
			while(endData.length<8)
			{
				endData.writeByte(0x00);
			}
			
			output.writeBytes(endData,0,endData.length);
			
			file=new FileReference();
			file.save(output,"SWFProjector.exe");
		}
	}
}
