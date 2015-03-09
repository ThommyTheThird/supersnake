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
		private var frameCounter:int = 0;
		
		private var size:int = 20;
		private var tilesWidth:int;
		private var tilesHeight:int;
		private var padding:int = 1;
		
		private var bg:Sprite;
		private var controlTexts:Array;
		private var format:TextFormat;
		
		private var red:BodyPart;
		private var blue:BodyPart;
		
		private static var TICKS:int = 10; //should be in sync with Main.TICK_FRAMES, so.. not another field here...
		
		private static const VERT_SPACING:int = 30;
		
		public function HelpScreen()
		{
			this.visible = false;
			this.addEventListener(Event.ADDED, onAdded);
		}
		
		public function toggleVisibility():void
		{
			this.visible = !visible;
			if (visible) 	this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			else 			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onAdded(e:Event):void
		{
			this.removeEventListener(Event.ADDED, onAdded);
			
			tilesWidth = stage.stageWidth / size;
			tilesHeight = stage.stageHeight / size;
			
			makeBackground();
			makeMessages();
			makeGameExplanation();
			makeSnakes();
		}
		private function onEnterFrame(e:Event):void
		{
			if (++frameCounter > (stage.frameRate / TICKS)) {
				frameCounter = 0;
				
				red.step();
				switch(red.getCurrentDirection()) {
					case Dirs.UP:
						if (red.y < ((padding+1) * size)) red.setMovements([false, false, false, true]);
						break;
					
					case Dirs.DOWN:
						if (red.y > ((tilesHeight - padding - 2) * size)) red.setMovements([false, false, true, false]);
						break;
					
					case Dirs.LEFT:
						if (red.x < ((padding+1) * size)) red.setMovements([true, false, false, false]);
						break;
					
					case Dirs.RIGHT:
						if (red.x > ((tilesWidth - padding - 2) * size)) red.setMovements([false, true, false, false]);
						break;
				}
				
				blue.step();
				switch(blue.getCurrentDirection()) {
					case Dirs.UP:
						if (blue.y < ((padding+1) * size)) blue.setMovements([false, false, false, true]);
						break;
					
					case Dirs.DOWN:
						if (blue.y > ((tilesHeight - padding - 2) * size)) blue.setMovements([false, false, true, false]);
						break;
					
					case Dirs.LEFT:
						if (blue.x < ((padding+1) * size)) blue.setMovements([true, false, false, false]);
						break;
					
					case Dirs.RIGHT:
						if (blue.x > ((tilesWidth - padding - 2) * size)) blue.setMovements([false, true, false, false]);
						break;
				}
			}
		}
		
		private function makeTextField(messages:Array, i:int, topToBottom:Boolean = true):Function
		{
			return function():void
			{
				trace('making tf at ' + i + "(i+1 * spacing is " + ((i + 1) * VERT_SPACING));
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.CENTER;
				tf.selectable = false;
				tf.text = messages[i];
				tf.setTextFormat(format);
				tf.x = stage.stageWidth / 2 - (tf.textWidth / 2);
				tf.y = stage.stageHeight - ((i + 1) * VERT_SPACING) - 60;
				if (topToBottom) tf.y = stage.stageHeight - tf.y;
				if (topToBottom) tf.y -= 20;
				addChild(tf);
			}
		}
		
		private function makeMessages():void 
		{
			format = new TextFormat(null, 18, Color.BLACK, false);
			for (var i:int = 0; i < Messages.ALL_TIPS.length; i++)
			{
				makeTextField(Messages.ALL_TIPS, i, false)();
			}
		}
		private function makeGameExplanation():void
		{
			format = new TextFormat("arial", 20, Color.BLACK, true);
			for (var i:int = 0; i < Messages.GAME_EXPLANATION.length; i++) {
				makeTextField(Messages.GAME_EXPLANATION, i)();
			}
		}
		
		private function makeBackground():void 
		{
			bg = new Sprite();
			bg.graphics.beginFill(Color.WHITE);
			bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			bg.graphics.endFill();
			addChild(bg);
		}
		
		private function makeSnakes():void
		{
			var creationPadding:int = 4;
			var length:int = tilesHeight;
			
			red = new BodyPart(size);
			red.setMovements([false, false, false, true]);
			red.x = (tilesWidth - padding - creationPadding - length - 1) * size;
			red.y = padding * size;
			addChild(red);
			
			var tail:BodyPart = red;
			for (var i:int = 0; i < length; i++) {
				red.step();
				tail = tail.calculateExtension();
				addChild(tail);
			}
			red.turnIntoColor(Color.RED, true);
			red.turnIntoColor(Color.RED_HEAD);
			
			blue = new BodyPart(size);
			blue.setMovements([false, false, true, false]);
			blue.x = (padding + creationPadding + length) * size;
			blue.y = (tilesHeight - padding - 1) * size;
			addChild(blue);
			
			tail = blue;
			for (var j:int = 0; j < length; j++) {
				blue.step();
				tail = tail.calculateExtension();
				addChild(tail);
			}
			blue.turnIntoColor(Color.BLUE, true);
			blue.turnIntoColor(Color.BLUE_HEAD);
		}
	}

}