package
{
	import BodyPart;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Thomas Withaar
	 */
	public class Main extends Sprite
	{
		private var fps:int = stage.frameRate;
		private var frameCounter:int = 0;
		
		private static var TICK_FRAMES:int = Options.FAST;
		
		private var prompt:TextField;
		private var promptFormat:TextFormat = new TextFormat(null, 32, Color.RED, true, false, false);
		private var help:HelpScreen;
		
		private var died:Boolean = false;
		
		private var mainPlayer:BodyPart;
		private var splitPlayer:BodyPart;
		
		private var mainTail:BodyPart;
		private var splitTail:BodyPart;
		
		private var pickup:Pickup;
		
		/*
		 * TODO
		 *** splitplayer kan 1 length zijn, dan gaat reattach fout (partbehind null) en... het is gewoon dom om 1 stukje te hebben
		 */
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			help = new HelpScreen();
			stage.addChild(help);
			
			startOrRestartGame();
		}
		
		private function startOrRestartGame():void
		{
			//CLEAR STUFF
			while (numChildren > 0)
			{
				removeChildAt(0);
			}
			stage.removeEventListener(Event.ENTER_FRAME, animationStepPrompt);
			prompt = null;
			
			frameCounter = 0;
			died = false;
			mainPlayer = null;
			splitPlayer = null;
			
			makeMainPlayer();
			
			//START
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			spawnPickup();
		}
		
		private function makeMainPlayer():void
		{
			mainPlayer = new BodyPart(Options.TILESIZE);
			mainTail = mainPlayer;
			mainPlayer.turnIntoColor(Color.PINK_HEAD);
			mainPlayer.setMovements([false, false, false, false]);
			mainPlayer.x = (((stage.stageWidth / Options.TILESIZE) / 2) % Options.TILESIZE) * Options.TILESIZE;
			mainPlayer.y = ((((stage.stageHeight / Options.TILESIZE) / 2)) % Options.TILESIZE) * Options.TILESIZE;
			addChild(mainPlayer);
		}
		
		private function splitUp(partHit:BodyPart):void
		{
			trace('splitup');
			var mainSnake:Array = mainPlayer.getSnake();
			var hitIndex:int = mainSnake.indexOf(partHit);
			partHit.completelyDetach();
			
			if (contains(partHit))
			{
				removeChild(partHit);
			}
			
			var whatRemainsOfMain:Array = mainSnake.slice(0, hitIndex);
			var newMainTail:BodyPart = whatRemainsOfMain[whatRemainsOfMain.length - 1];
			newMainTail.partBehind = null; //chopped off
			mainTail = newMainTail;
			
			var splitSnake:Array = mainSnake.slice(hitIndex + 1);
			if (splitSnake.length > 0)
			{
				mainPlayer.turnIntoColor(Color.RED, true); //recursive to the tail
				mainPlayer.turnIntoColor(Color.RED_HEAD);
				
				splitSnake[0].parentPart = null;
				splitSnake[0].reverse();
				splitPlayer = splitSnake[splitSnake.length - 1];
				splitTail = splitPlayer.getTail();
				
				splitPlayer.turnIntoColor(Color.BLUE_HEAD);
			}
			else
			{
				trace("YOU BROKE OFF THE LAST PIECE OR SOMETHING? WHAT? NOW ITS JUST DEAD DUDE?");
			}
		}
		
		private function spawnPickup():void
		{
			var xPos:int = Math.floor(Math.random() * stage.stageWidth / 4);
			xPos -= xPos % Options.TILESIZE; //make it fall neatly in a tile
			var yPos:int = Math.floor(Math.random() * stage.stageHeight / 4);
			yPos -= yPos % Options.TILESIZE;
			
			if (isPositionFree(xPos, yPos))
			{
				pickup = new Pickup(xPos, yPos);
				addChild(pickup);
			}
			else
			{
				spawnPickup(); //this breaks the game when you somehow fill the whole screen
			}
		}
		
		private function dieImmediately():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			promptMessage(Messages.RESTART);
		}
		
		private function promptMessage(message:String):void
		{
			if (prompt == null)
			{
				prompt = new TextField();
				prompt.autoSize = TextFieldAutoSize.CENTER;
				prompt.selectable = false;
				prompt.x = stage.stageWidth / 2;
				prompt.y = stage.stageHeight / 2;
				addChild(prompt);
			}
			prompt.text = message;
			prompt.setTextFormat(promptFormat);
			stage.addEventListener(Event.ENTER_FRAME, animationStepPrompt);
		}
		
		private function animationStepPrompt(e:Event):void
		{
			prompt.rotationZ += 2;
			prompt.rotationZ %= 360;
		}
		
		private function toggleSpeed():void
		{
			if (TICK_FRAMES == Options.FAST)
				TICK_FRAMES = Options.SLOW;
			else
				TICK_FRAMES = Options.FAST;
		}
		
		//Event Listeners
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				//MENU BUTTONS
				case Controls.RESTART: 
					startOrRestartGame();
					break;
				case Controls.QUIT: 
					System.exit(0);
					break;
				case Controls.HELP: 
				case Controls.HELP_ALT: 
				case Controls.HELP_ESC: 
					help.toggleVisibility();
					break;
				case Controls.TOGGLE_SPEED: 
					toggleSpeed();
					break;
				case Controls.SMALL:
					if (Options.TILESIZE != Options.SMALL_SIZE) {
						Options.TILESIZE = Options.SMALL_SIZE;
						startOrRestartGame();
					}
					break;
				case Controls.NORMAL:
					if (Options.TILESIZE != Options.MEDIUM_SIZE) {
						Options.TILESIZE = Options.MEDIUM_SIZE;
						startOrRestartGame();
					}
					break;
				case Controls.LARGE:
					if (Options.TILESIZE != Options.LARGE_SIZE) {
						Options.TILESIZE = Options.LARGE_SIZE;
						startOrRestartGame();
					}
					break;
			}
			
			if (!died)
			{
				switch (e.keyCode)
				{
					// PLAYER MAIN
					case Controls.UP_MAIN: 
						mainPlayer.tryMove(Dirs.UP);
						break;
					case Controls.DOWN_MAIN: 
						mainPlayer.tryMove(Dirs.DOWN);
						break;
					case Controls.LEFT_MAIN: 
						mainPlayer.tryMove(Dirs.LEFT);
						break;
					case Controls.RIGHT_MAIN: 
						mainPlayer.tryMove(Dirs.RIGHT);
						break;
					
					// PLAYER SPLIT
					case Controls.UP_SPLIT: 
						if (splitPlayer != null)
							splitPlayer.tryMove(Dirs.UP);
						break;
					case Controls.DOWN_SPLIT: 
						if (splitPlayer != null)
							splitPlayer.tryMove(Dirs.DOWN);
						break;
					case Controls.LEFT_SPLIT: 
						if (splitPlayer != null)
							splitPlayer.tryMove(Dirs.LEFT);
						break;
					case Controls.RIGHT_SPLIT: 
						if (splitPlayer != null)
							splitPlayer.tryMove(Dirs.RIGHT);
						break;
				}
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (++frameCounter > (fps / TICK_FRAMES))
			{
				frameCounter = 0;
				
				// -- DEATH CHECK
				if ((mainPlayer == null) && (splitPlayer == null))
				{
					dieImmediately();
					return;
				}
				
				// -- STEP
				if (mainPlayer != null)
					mainPlayer.step();
				if (splitPlayer != null)
					splitPlayer.step();
				
				// -- OFFSCREEN YET?
				if (!died)
				{
					if (isPartOutOfBounds(mainPlayer) || (splitPlayer != null && isPartOutOfBounds(splitPlayer)))
					{
						died = true;
					}
				}
				else
				{
					//the player already died. Keep moving until the last parts are completely offscreen, then end the game.
					if (mainPlayer != null)
					{
						if (isPartOutOfBounds(mainTail))
						{
							var main:Array = mainPlayer.getSnake();
							for each (var mp:BodyPart in main)
							{
								if (contains(mp))
									removeChild(mp);
							}
							mainPlayer = null;
						}
					}
					
					if (splitPlayer != null)
					{
						if (isPartOutOfBounds(splitTail))
						{
							var split:Array = splitPlayer.getSnake();
							for each (var sp:BodyPart in split)
							{
								if (contains(sp))
									removeChild(sp);
							}
							splitPlayer = null;
						}
					}
					return;
				}
				
				// -- COLLISION
				if (splitPlayer != null)
				{
					if (!died)
					{
						if (mainTail.hitTestObject(splitPlayer))
						{
							trace("REATTACH REATTACH REATTACH REATTACH");
							promptMessage(Messages.REATTACH);
							stage.addEventListener(Event.ENTER_FRAME, animationStepPrompt);
							var timer:Timer = new Timer(2000, 1);
							timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void
								{
									died = false;
									stage.removeEventListener(Event.ENTER_FRAME, animationStepPrompt);
									
									if (splitPlayer.partBehind != null) {
										splitPlayer.partBehind.parentPart = mainTail;
										mainTail.partBehind = splitPlayer.partBehind;
									}
									
									removeChild(splitPlayer);
									splitPlayer = null;
									
									mainTail = mainPlayer.getTail();
									
									mainPlayer.turnIntoColor(Color.PINK, true);
									mainPlayer.turnIntoColor(Color.PINK_HEAD);
									
									stage.removeEventListener(Event.ENTER_FRAME, animationStepPrompt);
									removeChild(prompt);
									prompt = null;
									
									stage.addEventListener(Event.ENTER_FRAME, onEnterFrame); //resume
								});
							stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame); //pause a bit
							timer.start();
							return;
						}
					}
				}
				
				var mainParts:Array = mainPlayer.getSnake();
				for each (var mPart:BodyPart in mainParts)
				{
					if (splitPlayer != null)
					{
						// player already hit himself once, and should die hitting something again
						if (mPart != mainPlayer && mainPlayer.hitTestObject(mPart) && !died)
						{
							trace("HIERDOOD");
							dieImmediately();
						}
						
						var splitParts:Array = splitPlayer.getSnake();
						
						for each (var sPart:BodyPart in splitParts)
						{
							if (mPart.hitTestObject(sPart)) {
								trace("mPart " + mPart.id + " hits sPart " + sPart + ":::     s(" + sPart.x + "," + sPart.y + ")  m(" + mPart.x + "," + mPart.y + ")");
								trace("JERAAKTESPLITPART DOOD");
								dieImmediately();
							}
						}
					}
					else
					{
						// player hasn't split up yet, so if he hits himself, split up
						if (mPart != mainPlayer && mainPlayer.hitTestObject(mPart) && !died)
						{
							trace("HIT YOURSELF at " + mPart.x + "," + mPart.y);
							splitUp(mPart);
							return;
						}
					}
				}
				
				if (pickup != null && mainPlayer != null)
				{
					if (pickup.hitTestObject(mainPlayer))
					{
						var newTail:BodyPart = mainTail.calculateExtension();
						mainTail = newTail;
						mainPlayer.traceEverythingBehindYou();
						addChild(newTail);
						
						if (splitPlayer != null)
							newTail.turnIntoColor(Color.RED);
						
						removeChild(pickup);
						spawnPickup();
					}
				}
			}
		}
		
		private function isPartOutOfBounds(mPart:BodyPart):Boolean
		{
			if (mPart == null)
				return false;
			
			if (mPart.x < 0 || mPart.y < 0 || mPart.x > stage.stageWidth || mPart.y > stage.stageHeight)
			{
				return true;
			}
			return false;
		}
		
		private function isPositionFree(x:int, y:int):Boolean
		{
			for each (var p:BodyPart in mainPlayer.getSnake())
			{
			   if (p.x == x && p.y == y)
			   return false;
			}
			
			return true;
		}
	}

}