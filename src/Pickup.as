package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Thomas Withaar
	 */
	public class Pickup extends Sprite
	{
		private var tileSize:int = 20;
		private var circle:Sprite;
		
		public function Pickup(xPos:int, yPos:int) 
		{
			makeCircle();
			this.x = xPos;
			this.y = yPos;
		}
		
		private function makeCircle():void {
			circle = new Sprite();
			circle.graphics.beginFill(0x0000FF);
			circle.graphics.drawCircle((tileSize / 2), (tileSize / 2), (tileSize / 2)-2);
			circle.graphics.endFill();
			addChild(circle);
		}
		
	}

}