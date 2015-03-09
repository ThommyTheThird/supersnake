package
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Thomas Withaar
	 */
	public class Pickup extends Sprite
	{
		private var circle:Sprite;
		
		public function Pickup(xPos:int, yPos:int)
		{
			makeCircle();
			this.x = xPos;
			this.y = yPos;
		}
		
		private function makeCircle():void
		{
			circle = new Sprite();
			circle.graphics.beginFill(Color.BLUE);
			circle.graphics.drawCircle((Options.TILESIZE / 2), (Options.TILESIZE / 2), (Options.TILESIZE / 2) - 2);
			circle.graphics.endFill();
			addChild(circle);
		}
	
	}

}