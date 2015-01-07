package
{
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
		
		private var diedAlready:Boolean = false;
		
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
		 *** BLAUW moet nog iets met pickups doen
		 *** BLAUW moet je ook killen als je het aanraakt.
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
			
			stage.addChild(upText);
			stage.addChild(downText);
			stage.addChild(leftText);
			stage.addChild(rightText);
		}
		
		private function updateTextFields():void
		{
			upText.text = mainPlayer.movingUp ? "UP PRESSED" : "NOT UP";
			downText.text = mainPlayer.movingDown ? "DOWN PRESSED" : "NOT DOWN";
			leftText.text = mainPlayer.movingLeft ? "LEFT PRESSED" : "NOT LEFT";
			rightText.text = mainPlayer.movingRight ? "RIGHT PRESSED" : "NOT RIGHT";
		}
		
		private function makeMainPlayer():void
		{
			//var movements:Array = [false, false, false, false];
			mainPlayer = new BodyPart(tileSize);
			mainPlayer.setMovements([false, false, false, false]);
			mainPlayer.x = 20 * tileSize;
			mainPlayer.y = 15 * tileSize;
			stage.addChild(mainPlayer);
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
			if (stage.contains(partHit)) stage.removeChild(partHit);
			
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
			
			pickup = new Pickup(xPos, yPos);
			stage.addChild(pickup);
		}
		
		//Event Listeners
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
		
		private function onEnterFrame(e:Event):void
		{
			updateTextFields();
			if (++frameCounter > (fps / 10))
			{
				frameCounter = 0;
				
				mainPlayer.step();
				if (splitPlayer != null) splitPlayer.step();
				
				if (!diedAlready) {
					if(isPlayerOutOfBounds(PLAYER_MAIN) || isPlayerOutOfBounds(PLAYER_SPLIT)) {
						trace("DOOD, DOOD, DOOD, DOOD, DOOD");
						diedAlready = true;
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForMain);
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownForSplit);
					}
				} else {
					//the player already died. Keep moving until the last parts are completely offscreen, then end the game.
					if (mainSnakeBodyParts[mainSnakeBodyParts.length - 1] != null) {
						if (isPartOutOfBounds(mainSnakeBodyParts[mainSnakeBodyParts.length - 1])) {
							for (var mp:uint = 0; mp < mainSnakeBodyParts.length; mp++) {
								if (stage.contains(mainSnakeBodyParts[mp])) stage.removeChild(mainSnakeBodyParts[mp]);
							}
							mainSnakeBodyParts = [];
							mainPlayer = null;
						}
					}
					
					if (splitSnakeBodyParts != null) {
						if (splitSnakeBodyParts[0] != null) {
							if (isPartOutOfBounds(splitSnakeBodyParts[0])) {
								for (var sp:uint = 0; sp < splitSnakeBodyParts.length; sp++) {
									if (stage.contains(splitSnakeBodyParts[sp])) stage.removeChild(splitSnakeBodyParts[sp]);
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
				
				for (var i:uint = 0; i < mainSnakeBodyParts.length; i++) {
					var part:BodyPart = mainSnakeBodyParts[i];
					if (part != mainPlayer && mainPlayer.hitTestObject(part) && !diedAlready) {
						trace("OUCH at " + part.x + "," + part.y);
						
						splitUp(part);
					}
				}
				
				if (pickup != null && mainPlayer != null) {
					if (pickup.hitTestObject(mainPlayer)) {
						trace("HIT PICKUP");
						
						var newTail:BodyPart = mainSnakeBodyParts[mainSnakeBodyParts.length - 1].calculateExtension();
						mainSnakeBodyParts.push(newTail);
						mainPlayer.traceEverythingBehindYou();
						stage.addChild(newTail);
						
						stage.removeChild(pickup);
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
		private function isPartOutOfBounds(part:BodyPart):Boolean {
			if (part == null) return false;
			
			if (part.x < 0 || part.y < 0 || part.x > stage.stageWidth || part.y > stage.stageHeight) {
				return true;
			}
			return false;
		}
	}

}