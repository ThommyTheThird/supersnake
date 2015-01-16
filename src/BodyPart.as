package
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Thomas Withaar
	 */
	public class BodyPart extends Sprite
	{
		private var bodySize:int;
		private var square:Sprite;
		
		public var id:int;
		private static var ID:int;
		
		public var parentPart:BodyPart;
		public var partBehind:BodyPart;
		
		public var movingUp:Boolean = false;
		public var movingDown:Boolean = false;
		public var movingLeft:Boolean = false;
		public var movingRight:Boolean = false;
		
		public var prevMovements:Array;
		
		//public function BodyPart(size:int, movements:Array, parent:BodyPart = null) 
		public function BodyPart(size:int, parent:BodyPart = null)
		{
			this.bodySize = size;
			if (parent != null)
			{
				setMovements(parent.getMovements());
			}
			this.parentPart = parent;
			
			prevMovements = [false, false, false, false];
			
			this.id = ID++;
			
			square = new Sprite();
			turnIntoColor(Color.PINK);
			square.x = 1;
			square.y = 1;
			addChild(square);
		}
		
		public function step():void
		{
			prevMovements = [movingUp, movingDown, movingLeft, movingRight];
			
			if (movingUp)
				this.y -= bodySize;
			if (movingDown)
				this.y += bodySize;
			if (movingLeft)
				this.x -= bodySize;
			if (movingRight)
				this.x += bodySize;
			
			if (partBehind != null)
			{
				partBehind.step();
				partBehind.setMovements(this.getMovements());
			}
		}
		
		public function setMovements(movements:Array):void
		{
			this.movingUp = movements[0];
			this.movingDown = movements[1];
			this.movingLeft = movements[2];
			this.movingRight = movements[3];
		}
		
		public function getMovements():Array
		{
			return [movingUp, movingDown, movingLeft, movingRight];
		}
		
		public function getPrevMovements():Array
		{
			return prevMovements;
		}
		
		public function calculateExtension():BodyPart
		{
			trace("part " + id + " is calcing extension at", this.x, this.y, "(" + this.x%bodySize + "," + this.y%bodySize + ")");
			if (partBehind != null)
			{
				trace("There's already something behind, wtf you doing son?");
			}
			else
			{
				partBehind = new BodyPart(bodySize, this);
				partBehind.setMovements(prevMovements);
				var xPos:int = this.x;
				var yPos:int = this.y;
				if (prevMovements[0])
					yPos += bodySize;
				if (prevMovements[1])
					yPos -= bodySize;
				if (prevMovements[2])
					xPos += bodySize;
				if (prevMovements[3])
					xPos -= bodySize;
				partBehind.x = xPos;
				partBehind.y = yPos;
			}
			return partBehind;
		}
		
		public function reverse():void
		{
			var oldBehind:BodyPart = partBehind;
			partBehind = parentPart;
			parentPart = oldBehind;
			reverseMovements();
			turnIntoColor(Color.BLUE);
			if (oldBehind != null)
				parentPart.reverse();
			else
				trace(id + " had no more stuff behind him and is now the new tail?");
		}
		
		public function getTail():BodyPart
		{
			if (partBehind != null)
			{
				return partBehind.getTail();
			}
			else
			{
				return this;
			}
		}
		
		public function getHead():BodyPart
		{
			if (parentPart != null)
			{
				return parentPart.getHead();
			}
			else
			{
				return this;
			}
		}
		
		private function reverseMovements():void
		{
			if (prevMovements[0])
				setMovements([false, true, false, false]);
			else if (prevMovements[1])
				setMovements([true, false, false, false]);
			else if (prevMovements[2])
				setMovements([false, false, false, true]);
			else if (prevMovements[3])
				setMovements([false, false, true, false]);
		}
		
		public function turnIntoColor(color:uint):void
		{
			square.graphics.clear();
			square.graphics.beginFill(color);
			square.graphics.drawRect(0, 0, bodySize - 2, bodySize - 2);
			square.graphics.endFill();
		}
		
		public function traceEverythingBehindYou(everything:Array = null):void
		{
			if (everything == null)
				everything = new Array();
			everything.push(id);
			
			if (partBehind != null)
			{
				partBehind.traceEverythingBehindYou(everything);
			}
			else
			{
				trace(everything);
			}
		}
		public function traceLength(len:int = 0):void {
			trace("current length (at " + id + ") " + len);
			len++;
			if (partBehind != null) partBehind.traceLength(len);
			else trace("Length from head to " + id + " ----- " + len);
		}
	}

}