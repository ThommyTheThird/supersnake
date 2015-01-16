package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Thomas Withaar
	 */
	public class HelpScreen extends Sprite
	{
		private var bg:Sprite;
		private var controlTexts:Array;
		private var format:TextFormat;
		
		private var mainPink:BodyPart;
		private var splitRed:BodyPart;
		private var splitBlue:BodyPart;
		
		private static const VERT_SPACING:int = 30;
		
		public function HelpScreen()
		{
			this.visible = false;
			this.addEventListener(Event.ADDED, onAdded);
		}
		
		public function toggleVisibility():void
		{
			this.visible = !visible;
		}
		
		private function onAdded(e:Event):void
		{
			this.removeEventListener(Event.ADDED, onAdded);
			
			bg = new Sprite();
			bg.graphics.beginFill(Color.WHITE);
			bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			bg.graphics.endFill();
			addChild(bg);
			
			format = new TextFormat(null, 18, Color.BLACK, true, false, false);
			for (var i:int = Messages.ALL_TIPS.length - 1; i >= 0; i--)
			{
				makeTextField(i)();
			}
			
			//main player
			var mainTf:TextField = new TextField();
			mainTf.selectable = false;
			mainTf.text = Messages.TIP_ARROWSKEYS;
			mainTf.setTextFormat(format);
			mainTf.autoSize = TextFieldAutoSize.LEFT;
			mainPink = new BodyPart(20); //TODO magic number
			mainPink.turnIntoColor(Color.PINK_HEAD);
			mainTf.y = mainPink.y = VERT_SPACING;
			mainTf.x = (stage.stageWidth / 2) + offset;
			mainPink.x = (stage.stageWidth / 2) - offset;
			addChild(mainTf);
			addChild(mainPink);
			
			var offset:int = 40;
			//split red
			var arrTf:TextField = new TextField();
			arrTf.selectable = false;
			arrTf.text = Messages.TIP_ARROWSKEYS;
			arrTf.setTextFormat(format);
			arrTf.autoSize = TextFieldAutoSize.LEFT;
			splitRed = new BodyPart(20); //TODO magic number
			splitRed.turnIntoColor(Color.RED_HEAD);
			arrTf.y = splitRed.y = 2 * VERT_SPACING;
			arrTf.x = (stage.stageWidth / 2) + offset;
			splitRed.x = (stage.stageWidth / 2) - offset;
			addChild(arrTf);
			addChild(splitRed);
			
			//split blue
			var wasdTf:TextField = new TextField();
			wasdTf.selectable = false;
			wasdTf.text = Messages.TIP_WASD;
			wasdTf.setTextFormat(format);
			wasdTf.autoSize = TextFieldAutoSize.LEFT;
			splitBlue = new BodyPart(20); //TODO magic number
			splitBlue.turnIntoColor(Color.BLUE_HEAD);
			wasdTf.y = splitBlue.y = 3 * VERT_SPACING;
			wasdTf.x = (stage.stageWidth / 2) + offset;
			splitBlue.x = (stage.stageWidth / 2) - offset;
			addChild(wasdTf);
			addChild(splitBlue);
		}
		
		private function makeTextField(i:int):Function
		{
			return function():void
			{
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.CENTER;
				tf.selectable = false;
				tf.text = Messages.ALL_TIPS[i];
				tf.setTextFormat(format);
				tf.x = stage.stageWidth / 2;
				tf.y = stage.stageHeight - ((i + 1) * VERT_SPACING) - 120;
				addChild(tf);
			}
		}
	}

}