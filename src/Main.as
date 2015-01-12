package
{
	import BodyPart;
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
		private static var FAST:int = 10;
		private static var SLOW:int = 1;
		private static var TICK_FRAMES:int = FAST;
		
		private var prompt:TextField;
		private var promptFormat:TextFormat = new TextFormat(null, 32, Color.RED, true, false, false);
		private var help:HelpScreen;
		
		private var died:Boolean = false;
		
		private var tileSize:int = 20;
		private var PLAYER_MAIN:uint = 0;
		private var PLAYER_SPLIT:uint = 1;
		
		private var mainPlayer:BodyPart;
		private var mainSnakeBodyParts:Array;
		private var splitPlayer:BodyPart;
		private var splitSnakeBodyParts:Array;
		
		private var players:Array;
		private var playerParts:Array;
		
		private var pickup:Pickup;
		
		/*
		 * TODO
		 *** Snake kan NOG ALTIJD een 180 doen, als je cheat (snel UP en LEFT te doen in dezelfde 'tick');
		 *
		 *** BLAUW kan je staart bijten en weer terugkomen.
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
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onMenuButtons);
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
			mainSnakeBodyParts = null;
			splitPlayer = null;
			splitSnakeBodyParts = null;
			
			players = new Array();
			playerParts = new Array();
			makeMainPlayer();
			makeMainSnake();
			players.push(mainPlayer);
			playerParts.push(mainSnakeBodyParts);
			
			//START
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForMain);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			spawnPickup();
		}
		
		private function makeMainPlayer():void
		{
			//var movements:Array = [false, false, false, false];
			mainPlayer = new BodyPart(tileSize);
			mainPlayer.setMovements([false, false, false, false]);
			mainPlayer.x = 20 * tileSize;
			mainPlayer.y = 15 * tileSize;
			addChild(mainPlayer);
		}
		
		private function makeMainSnake():void
		{
			mainSnakeBodyParts = new Array();
			mainSnakeBodyParts.push(mainPlayer);
		}
		
		private function splitUp(partHit:BodyPart):void
		{
			trace("-----SPLITTING-----");
			trace("main intact");
			mainPlayer.traceEverythingBehindYou();
			
			var hitIndex:int = mainSnakeBodyParts.indexOf(partHit);
			partHit.parentPart = null;
			partHit.partBehind = null;
			if (contains(partHit))
				removeChild(partHit);
			
			var whatRemainsOfMain:Array = mainSnakeBodyParts.slice(0, hitIndex);
			whatRemainsOfMain[whatRemainsOfMain.length - 1].partBehind = null; //chopped off
			
			trace("remains main");
			whatRemainsOfMain[0].traceEverythingBehindYou();
			
			splitSnakeBodyParts = mainSnakeBodyParts.slice(hitIndex + 1);
			
			if (splitSnakeBodyParts.length > 0)
			{
				trace("split before rev");
				splitSnakeBodyParts[0].traceEverythingBehindYou();
				
				mainPlayer = whatRemainsOfMain[0];
				mainSnakeBodyParts = whatRemainsOfMain;
				
				splitSnakeBodyParts[0].reverse();
				splitPlayer = splitSnakeBodyParts[splitSnakeBodyParts.length - 1];
				players[PLAYER_SPLIT] = splitPlayer;
				trace("split reversed");
				splitPlayer.traceEverythingBehindYou();
				
				mainPlayer.turnIntoColor(Color.RED_HEAD);
				splitSnakeBodyParts[splitSnakeBodyParts.length - 1].turnIntoColor(Color.BLUE_HEAD);
				
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForSplit);
			}
			else
			{
				trace("YOU BROKE OFF THE LAST PIECE OR SOMETHING? WHAT? NOW ITS JUST DEAD DUDE?");
			}
			
			for each (var mPart:BodyPart in mainSnakeBodyParts)
				mPart.turnIntoColor(Color.RED);
		}
		
		private function resetMovements(player:int):void
		{
			if (player == PLAYER_MAIN)
			{
				mainPlayer.movingUp = false;
				mainPlayer.movingDown = false;
				mainPlayer.movingLeft = false;
				mainPlayer.movingRight = false;
			}
			else
			{
				splitPlayer.movingUp = false;
				splitPlayer.movingDown = false;
				splitPlayer.movingLeft = false;
				splitPlayer.movingRight = false;
			}
		}
		
		private function spawnPickup():void
		{
			var xPos:int = Math.floor(Math.random() * stage.stageWidth / 4);
			xPos -= xPos % tileSize; //make it fall neatly in a tile
			var yPos:int = Math.floor(Math.random() * stage.stageHeight / 4);
			yPos -= yPos % tileSize;
			
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
			trace("YOU ACTUALLY, LITERALLY DIED");
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
		
		private function canITurnThisWay(player:int, direction:String):Boolean
		{
			if (players[player] == null)
				return false;
			
			switch (direction)
			{
				case "UP": 
					return !players[player].movingDown;
					break;
				case "DOWN": 
					return !players[player].movingUp;
					break;
				case "LEFT": 
					return !players[player].movingRight;
					break;
				case "RIGHT": 
					return !players[player].movingLeft;
					break;
				default: 
					return true;
			}
		}
		
		//Event Listeners
		private function onMenuButtons(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.R)
				startOrRestartGame();
			if (e.keyCode == Keyboard.Q)
				System.exit(0);
			if (e.keyCode == Keyboard.C || e.keyCode == Keyboard.H || e.keyCode == Keyboard.ESCAPE)
				help.toggleVisibility();
			if (e.keyCode == Keyboard.SPACE)
			{
				if (TICK_FRAMES == FAST)
					TICK_FRAMES = SLOW;
				else
					TICK_FRAMES = FAST;
			}
		}
		
		private function onKeyDownForMain(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.UP: 
					if (canITurnThisWay(PLAYER_MAIN, "UP"))
					{
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingUp = true;
					}
					break;
				case Keyboard.DOWN: 
					if (canITurnThisWay(PLAYER_MAIN, "DOWN"))
					{
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingDown = true;
					}
					break;
				case Keyboard.LEFT: 
					if (canITurnThisWay(PLAYER_MAIN, "LEFT"))
					{
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingLeft = true;
					}
					break;
				case Keyboard.RIGHT: 
					if (canITurnThisWay(PLAYER_MAIN, "RIGHT"))
					{
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingRight = true;
					}
					break;
			}
		}
		
		private function onKeyDownForSplit(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.W: 
					if (canITurnThisWay(PLAYER_SPLIT, "UP"))
					{
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingUp = true;
					}
					break;
				case Keyboard.S: 
					if (canITurnThisWay(PLAYER_SPLIT, "DOWN"))
					{
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingDown = true;
					}
					break;
				case Keyboard.A: 
					if (canITurnThisWay(PLAYER_SPLIT, "LEFT"))
					{
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingLeft = true;
					}
					break;
				case Keyboard.D: 
					if (canITurnThisWay(PLAYER_SPLIT, "RIGHT"))
					{
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingRight = true;
					}
					break;
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (++frameCounter > (fps / TICK_FRAMES))
			{
				frameCounter = 0;
				
				// -- STEP
				mainPlayer.step();
				if (splitPlayer != null)
					splitPlayer.step();
				
				// -- DEATH CHECKS
				if (!died)
				{
					if (isPlayerOutOfBounds(PLAYER_MAIN) || isPlayerOutOfBounds(PLAYER_SPLIT))
					{
						trace("DOOD, DOOD, DOOD, DOOD, DOOD");
						died = true;
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForMain);
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForSplit);
					}
				}
				else
				{
					//the player already died. Keep moving until the last parts are completely offscreen, then end the game.
					if (mainSnakeBodyParts[mainSnakeBodyParts.length - 1] != null)
					{
						if (isPartOutOfBounds(mainSnakeBodyParts[mainSnakeBodyParts.length - 1]))
						{
							for (var mp:uint = 0; mp < mainSnakeBodyParts.length; mp++)
							{
								if (contains(mainSnakeBodyParts[mp]))
									removeChild(mainSnakeBodyParts[mp]);
							}
							mainSnakeBodyParts = [];
							mainPlayer = null;
						}
					}
					
					if (splitSnakeBodyParts != null)
					{
						if (splitSnakeBodyParts[0] != null)
						{
							if (isPartOutOfBounds(splitSnakeBodyParts[0]))
							{
								for (var sp:uint = 0; sp < splitSnakeBodyParts.length; sp++)
								{
									if (contains(splitSnakeBodyParts[sp]))
										removeChild(splitSnakeBodyParts[sp]);
								}
								splitSnakeBodyParts = null;
								splitPlayer = null;
							}
						}
					}
					
					if ((mainPlayer == null) && (splitPlayer == null))
					{
						dieImmediately();
					}
				}
				
				// -- COLLISION
				if (splitPlayer != null)
				{
					if (mainSnakeBodyParts[mainSnakeBodyParts.length - 1].hitTestObject(splitSnakeBodyParts[splitSnakeBodyParts.length - 1]))
					{
						trace("REATTACH REATTACH REATTACH REATTACH");
						promptMessage(Messages.REATTACH);
					}
				}
				
				for (var i:uint = 0; i < mainSnakeBodyParts.length; i++)
				{
					var mPart:BodyPart = mainSnakeBodyParts[i];
					
					if (splitPlayer != null)
					{
						// player already hit himself once, and should die hitting something again
						if (mPart != mainPlayer && mainPlayer.hitTestObject(mPart) && !died)
						{
							dieImmediately();
						}
						
						for (var s:uint = 0; s < splitSnakeBodyParts.length; s++)
						{
							var sPart:BodyPart = splitSnakeBodyParts[s];
							if (mPart.hitTestObject(sPart))
							{
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
						}
						
					}
				}
				
				if (pickup != null && mainPlayer != null)
				{
					if (pickup.hitTestObject(mainPlayer))
					{
						var newTail:BodyPart = mainSnakeBodyParts[mainSnakeBodyParts.length - 1].calculateExtension();
						mainSnakeBodyParts.push(newTail);
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
		
		private function isPlayerOutOfBounds(player:int):Boolean
		{
			var p:BodyPart = players[player];
			if (p == null)
				return false;
			
			if (p.x < 0 || p.y < 0 || p.x > stage.stageWidth || p.y > stage.stageHeight)
			{
				return true;
			}
			return false;
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
			var probably:Boolean = true;
			
			for each (var p:BodyPart in mainSnakeBodyParts)
			{
				if (p.x == x && p.y == y)
					probably = false;
			}
			
			return probably;
		}
	}

}