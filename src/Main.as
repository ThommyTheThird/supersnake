package
{
	import flash.system.System;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import BodyPart;
	
	/**
	 * ...
	 * @author Thomas Withaar
	 */
	public class Main extends Sprite
	{
		private var fps:int = stage.frameRate;
		private var widthInTiles:int = stage.stageWidth
		private var frameCounter:int = 0;
		
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
		
		private var upText:TextField;
		private var downText:TextField;
		private var leftText:TextField;
		private var rightText:TextField;
		private var textFieldWidth:int = 200;
		private var textFieldHeight:int = 20;
		
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
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onRestart);
			startOrRestartGame();
		}
		
		private function startOrRestartGame():void {
			trace("START");

			while(numChildren > 0) {
				removeChildAt(0);
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForMain);
			
			players = new Array();
			playerParts = new Array();
			makeMainPlayer();
			makeMainSnake();
			players.push(mainPlayer);
			playerParts.push(mainSnakeBodyParts);
			
			makeTextFields();
			updateTextFields();
			
			spawnPickup();
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function makeTextFields():void
		{
			upText = new TextField();
			upText.width = textFieldWidth;
			upText.height = textFieldHeight;
			upText.x = 0;
			upText.y = (stage.stageHeight - textFieldHeight);
			
			downText = new TextField();
			downText.width = textFieldWidth;
			downText.height = textFieldHeight;
			downText.x = textFieldWidth;
			downText.y = (stage.stageHeight - textFieldHeight);
			
			leftText = new TextField();
			leftText.width = textFieldWidth;
			leftText.height = textFieldHeight;
			leftText.x = 2 * textFieldWidth;
			leftText.y = (stage.stageHeight - textFieldHeight);
			
			rightText = new TextField();
			rightText.width = textFieldWidth;
			rightText.height = textFieldHeight;
			rightText.x = 3 * textFieldWidth;
			rightText.y = (stage.stageHeight - textFieldHeight);
			
			addChild(upText);
			addChild(downText);
			addChild(leftText);
			addChild(rightText);
		}
		
		private function updateTextFields():void
		{
			upText.text = mainPlayer.movingUp ? "UP PRESSED" : "NOT UP";
			downText.text = mainPlayer.movingDown ? "DOWN PRESSED" : "NOT DOWN";
			leftText.text = mainPlayer.movingLeft ? "LEFT PRESSED" : "NOT LEFT";
			rightText.text = mainPlayer.movingRight ? "RIGHT PRESSED" : "NOT RIGHT";
		}
		private function setAllTextFields(text:String):void {
			upText.text = text;
			downText.text = text;
			leftText.text = text;
			rightText.text = text;
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
		private function makeMainSnake():void {
			mainSnakeBodyParts = new Array();
			mainSnakeBodyParts.push(mainPlayer);
		}
		
		private function splitUp(partHit:BodyPart):void {
			trace("-----SPLITTING-----");
			trace("main intact"); mainPlayer.traceEverythingBehindYou();
			
			
			var hitIndex:int = mainSnakeBodyParts.indexOf(partHit);
			partHit.parentPart = null; partHit.partBehind = null;
			if (contains(partHit)) removeChild(partHit);
			
			var whatRemainsOfMain:Array = mainSnakeBodyParts.slice(0, hitIndex);
			whatRemainsOfMain[whatRemainsOfMain.length - 1].partBehind = null; //chopped off
			
			trace("remains main"); whatRemainsOfMain[0].traceEverythingBehindYou();
			
			splitSnakeBodyParts = mainSnakeBodyParts.slice(hitIndex + 1);
			
			if (splitSnakeBodyParts.length > 0) {
				trace("split before rev"); splitSnakeBodyParts[0].traceEverythingBehindYou();
				
				mainPlayer = whatRemainsOfMain[0];
				mainSnakeBodyParts = whatRemainsOfMain;
				
				splitSnakeBodyParts[0].reverse();
				splitPlayer = splitSnakeBodyParts[splitSnakeBodyParts.length - 1];
				players[PLAYER_SPLIT] = splitPlayer;
				trace("split reversed"); splitPlayer.traceEverythingBehindYou();
				
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForSplit);
			} else {
				trace("YOU BROKE OFF THE LAST PIECE OR SOMETHING? WHAT? NOW ITS JUST DEAD DUDE?");
			}
		}
		
		private function resetMovements(player:int):void
		{
			if (player == PLAYER_MAIN) {
				mainPlayer.movingUp = false;
				mainPlayer.movingDown = false;
				mainPlayer.movingLeft = false;
				mainPlayer.movingRight = false;
			} else {
				splitPlayer.movingUp = false;
				splitPlayer.movingDown = false;
				splitPlayer.movingLeft = false;
				splitPlayer.movingRight = false;
			}
		}
		
		private function spawnPickup():void {
			var xPos:int = Math.floor(Math.random() * stage.stageWidth);
			xPos -= xPos % tileSize; //make it fall neatly in a tile
			var yPos:int = Math.floor(Math.random() * stage.stageHeight);
			yPos -= yPos % tileSize;
			
			if (isPositionFree(xPos, yPos)) {
				pickup = new Pickup(xPos, yPos);
				addChild(pickup);
			} else {
				spawnPickup(); //this breaks the game when you somehow fill the whole screen
			}
		}
		
		private function dieImmediately():void {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			trace("YOU ACTUALLY, LITERALLY DIED");
			setAllTextFields("RIP");
		}
		
		private function canITurnThisWay(player:int, direction:String):Boolean {
			if (players[player] == null) return false;
			
			switch(direction) {
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
		private function onRestart(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.R) startOrRestartGame();
			if (e.keyCode == Keyboard.Q) System.exit(0);
		}
		
		private function onKeyDownForMain(e:KeyboardEvent):void	{
			switch (e.keyCode)
			{
				case Keyboard.UP: 
					if (canITurnThisWay(PLAYER_MAIN, "UP")) {
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingUp = true;
					}
					break;
				case Keyboard.DOWN: 
					if (canITurnThisWay(PLAYER_MAIN, "DOWN")) {
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingDown = true;
					}
					break;
				case Keyboard.LEFT: 
					if (canITurnThisWay(PLAYER_MAIN, "LEFT")) {
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingLeft = true;
					}
					break;
				case Keyboard.RIGHT: 
					if (canITurnThisWay(PLAYER_MAIN, "RIGHT")) {
						resetMovements(PLAYER_MAIN);
						mainPlayer.movingRight = true;
					}
					break;
			}
		}
		private function onKeyDownForSplit(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case Keyboard.W:
					if (canITurnThisWay(PLAYER_SPLIT, "UP")) {
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingUp = true;
					}
					break;
				case Keyboard.S:
					if (canITurnThisWay(PLAYER_SPLIT, "DOWN")) {
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingDown = true;
					}
					break;
				case Keyboard.A:
					if (canITurnThisWay(PLAYER_SPLIT, "LEFT")) {
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingLeft = true;
					}
					break;
				case Keyboard.D:
					if (canITurnThisWay(PLAYER_SPLIT, "RIGHT")) {
						resetMovements(PLAYER_SPLIT);
						splitPlayer.movingRight = true;
					}
					break;
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			updateTextFields();
			if (++frameCounter > (fps / 10))
			{
				frameCounter = 0;
				
				// -- STEP
				mainPlayer.step();
				if (splitPlayer != null) splitPlayer.step();
				
				
				// -- DEATH CHECKS
				if (!died) {
					if(isPlayerOutOfBounds(PLAYER_MAIN) || isPlayerOutOfBounds(PLAYER_SPLIT)) {
						trace("DOOD, DOOD, DOOD, DOOD, DOOD");
						setAllTextFields("DOOD");
						died = true;
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForMain);
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForSplit);
					}
				} else {
					//the player already died. Keep moving until the last parts are completely offscreen, then end the game.
					if (mainSnakeBodyParts[mainSnakeBodyParts.length - 1] != null) {
						if (isPartOutOfBounds(mainSnakeBodyParts[mainSnakeBodyParts.length - 1])) {
							for (var mp:uint = 0; mp < mainSnakeBodyParts.length; mp++) {
								if (contains(mainSnakeBodyParts[mp])) removeChild(mainSnakeBodyParts[mp]);
							}
							mainSnakeBodyParts = [];
							mainPlayer = null;
						}
					}
					
					if (splitSnakeBodyParts != null) {
						if (splitSnakeBodyParts[0] != null) {
							if (isPartOutOfBounds(splitSnakeBodyParts[0])) {
								for (var sp:uint = 0; sp < splitSnakeBodyParts.length; sp++) {
									if (contains(splitSnakeBodyParts[sp])) removeChild(splitSnakeBodyParts[sp]);
								}
								splitSnakeBodyParts = null;
								splitPlayer = null;
							}
						}
					}
					
					if ((mainPlayer == null) && (splitPlayer == null)) {
						trace("ALRIGHT, THE JIG IS UP. THE GAME IS OVER. EVERYBODY GO HOME.");
						stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					}
				}
				
				
				// -- COLLISION
				for (var i:uint = 0; i < mainSnakeBodyParts.length; i++) {
					var mPart:BodyPart = mainSnakeBodyParts[i];
					
					if (splitPlayer != null) {
						// player already hit himself once, and should die hitting something again
						if (mPart != mainPlayer && mainPlayer.hitTestObject(mPart) && !died) {
							dieImmediately();
						}
						
						for (var s:uint = 0; s < splitSnakeBodyParts.length; s++) {
							var sPart:BodyPart = splitSnakeBodyParts[s];
							if (mPart.hitTestObject(sPart)) {
								dieImmediately();
							}
						}
					}else {
						// player hasn't split up yet, so if he hits himself, split up
						if (mPart != mainPlayer && mainPlayer.hitTestObject(mPart) && !died) {
							trace("HIT YOURSELF at " + mPart.x + "," + mPart.y);
							splitUp(mPart);
						}
						
					}
				}
				
				if (pickup != null && mainPlayer != null) {
					if (pickup.hitTestObject(mainPlayer)) {
						trace("HIT PICKUP");
						
						var newTail:BodyPart = mainSnakeBodyParts[mainSnakeBodyParts.length - 1].calculateExtension();
						mainSnakeBodyParts.push(newTail);
						mainPlayer.traceEverythingBehindYou();
						addChild(newTail);
						
						removeChild(pickup);
						spawnPickup();
					}
				}
			}
		}
		
		private function isPlayerOutOfBounds(player:int):Boolean {
			var p:BodyPart = players[player];
			if (p == null) return false;
			
			if (p.x < 0 || p.y < 0 || p.x > stage.stageWidth || p.y > stage.stageHeight) {
				return true;
			}
			return false;
		}
		private function isPartOutOfBounds(mPart:BodyPart):Boolean {
			if (mPart == null) return false;
			
			if (mPart.x < 0 || mPart.y < 0 || mPart.x > stage.stageWidth || mPart.y > stage.stageHeight) {
				return true;
			}
			return false;
		}
		private function isPositionFree(x:int, y:int):Boolean {
			var probably:Boolean = true;
			
			for each(var p:BodyPart in mainSnakeBodyParts) {
				if (p.x == x && p.y == y) probably = false;
			}
			
			return probably;
		}
	}

}