package;

import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.addons.display.FlxGridOverlay;
import levels.TiledLevel;
import openfl.events.JoystickEvent;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _background:FlxSprite;
	private var _sprPlayer1:FlxSprite;
	private var _sprPlayer2:FlxSprite;
	private var _ball:FlxSprite;
	
	private var _levelBounds:FlxRect;
	private var _grpWalls:FlxGroup;
	private var _grpPlayers:FlxGroup;
	private var _grpBall:FlxGroup;
	private var _grpUI:FlxGroup;
	
	private var _sprFade:FlxSprite;
	private var _collisionMap:FlxTilemapExt;
	
	private var _state:Int = 0;
	private inline static var STATE_LOADING:Int = 0;
	private inline static var STATE_FADEIN:Int = 1;
	private inline static var STATE_FADEOUT:Int = 2;
	private inline static var STATE_PLAY:Int = 3;
	
	private var _ballLaunched:Bool = false;
	private var _ballLaunchTimer:Float;
	private var _ballLaunchDisplay:FlxSprite;
	
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		_state = STATE_LOADING;
		_ballLaunched = false;
		
		Reg.LoadLevels();
		InitGameScreen();
		
		_levelBounds = new FlxRect(16, 16, FlxG.width - 32, FlxG.height - 32);
		
		Reg.level = 0;
		LoadLevel();

		super.create();
		
		_state = STATE_FADEIN;
	}
	
	private function InitGameScreen():Void
	{
		_background =  FlxGridOverlay.create(8,8,-1,-1,false,true, 0x33d83aad, 0x66d83aad ); //new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xff666666);
		_background.scrollFactor.x = _background.scrollFactor.y = 0;
		add(_background);
		
		_grpWalls = new FlxGroup(1);
		_grpPlayers = new FlxGroup(2);
		_grpBall = new FlxGroup(1);
		_grpUI = new FlxGroup();
		
		add(_grpWalls);
		add(_grpPlayers);
		add(_grpBall);
		add(_grpUI);
		
		_sprFade = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(_sprFade);
		
		_sprPlayer1 = new FlxSprite(16, 16).makeGraphic(Reg.PLAYER_WIDTH, Reg.PLAYER_HEIGHT, FlxColor.BLUE);
		_sprPlayer2 = new FlxSprite(FlxG.width - 32, 16).makeGraphic(Reg.PLAYER_WIDTH, Reg.PLAYER_HEIGHT, FlxColor.GOLDENROD);
		_sprPlayer1.immovable = true;
		_sprPlayer2.immovable = true;
		
		_ball = new FlxSprite((FlxG.width - Reg.BALL_SIZE) / 2, (FlxG.height - Reg.BALL_SIZE) / 2).makeGraphic(Reg.BALL_SIZE, Reg.BALL_SIZE, 0xffffffff);
		_ball.elasticity = 1;
		_ball.maxVelocity.set(400, 400);
		
		_grpPlayers.add(_sprPlayer1);
		_grpPlayers.add(_sprPlayer2);
		_grpBall.add(_ball);
		
		_ballLaunchDisplay = new FlxSprite(0, 0).loadGraphic("images/count-down.png", true, false, 360, 360);
		_ballLaunchDisplay.animation.add("count", [0, 1, 2, 3], 0, false);
		_ballLaunchDisplay.animation.pause();
		_ballLaunchDisplay.animation.frameIndex = 0;
		_ballLaunchDisplay.alpha = 0;
		_ballLaunchDisplay.x = (FlxG.width - _ballLaunchDisplay.width) / 2;
		_ballLaunchDisplay.y = (FlxG.height - _ballLaunchDisplay.height) / 2;
		_ballLaunchTimer = 2;
		_grpUI.add(_ballLaunchDisplay);
		
		
	}
	
	private function LoadLevel():Void
	{
		
		var level:TiledLevel = new TiledLevel("data/room-" + Reg.levels[Reg.level] + ".tmx", "data/tiles.tanim");
		
		_grpWalls.add(level.wallTiles);
		
		_grpWalls.setAll("x", (FlxG.width - level.fullWidth) / 2);
		_grpWalls.setAll("y", (FlxG.height - level.fullHeight) / 2);
		
		_sprPlayer1.y = (FlxG.height - Reg.PLAYER_HEIGHT) / 2;
		_sprPlayer2.y = (FlxG.height - Reg.PLAYER_HEIGHT) / 2;
		
		_ballLaunchDisplay.animation.frameIndex = 0;
		_ballLaunchDisplay.alpha = 0;
		_ballLaunchTimer = 2;
	}
	
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
	
	
	private function GamePlay():Void
	{
		if (FlxG.keyboard.anyPressed(["W", "A"]))
		{
			_sprPlayer1.velocity.y = -Reg.PLAYER_SPEED;
		}
		else if (FlxG.keyboard.anyPressed(["S", "D"]))
		{
			_sprPlayer1.velocity.y = Reg.PLAYER_SPEED;
		}
		
		if (FlxG.keyboard.anyPressed(["UP", "LEFT"]))
		{
			_sprPlayer2.velocity.y = -Reg.PLAYER_SPEED;
		}
		else if (FlxG.keyboard.anyPressed(["DOWN", "RIGHT"]))
		{
			_sprPlayer2.velocity.y = Reg.PLAYER_SPEED;
		}
		
		FlxG.collide(_ball, _grpWalls);
		FlxG.collide(_grpPlayers, _ball, BallHitPlayer);
		
		if (!_ballLaunched)
		{
			if (_ballLaunchTimer > 0)
			{
				_ballLaunchTimer -= FlxG.elapsed * 2;
				if (_ballLaunchTimer > 1)
					_ballLaunchDisplay.alpha = 1;
				else
					_ballLaunchDisplay.alpha -= _ballLaunchTimer;
			}
			else if (_ballLaunchDisplay.animation.frameIndex < 3)
			{
				_ballLaunchDisplay.animation.frameIndex++;
				_ballLaunchTimer = 2;
				_ballLaunchDisplay.alpha = 1;
			}
			else if (_ballLaunchDisplay.animation.frameIndex == 3)
			{
				_ball.velocity.x = FlxRandom.sign() * 200;
				_ball.velocity.y = FlxRandom.sign() * FlxRandom.intRanged(0, 20);
				_ballLaunched = true;
			}
			
		}
	}
	
	private function BallHitPlayer(P:FlxObject, B:FlxObject):Void
	{
		var playerMid:Int = Std.int(P.y + (Reg.PLAYER_HEIGHT / 2));
		var ballMid:Int = Std.int(B.y + (Reg.BALL_SIZE / 2));
		var diff:Int;
		if (ballMid < playerMid)
		{
			// ball hit the 'top' of the paddle
			diff = playerMid - ballMid;
			B.velocity.y = ( -4 * Math.abs(diff));
			trace('top: ' + B.velocity.y);
		}
		else if (ballMid > playerMid)
		{
			// ball hit the 'bottom' of the paddle
			diff = playerMid - ballMid;
			B.velocity.y = ( 4 * Math.abs(diff));
			trace('bottom: ' + B.velocity.y);
		}
		else
		{
			// ball hit right in the middle...
			// randomize!
			B.velocity.y = 2 + Std.int(Math.random() * 8);
			trace('middle: ' + B.velocity.y);
		}
		
	}


	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		
		_sprPlayer1.velocity.y = 0;
		_sprPlayer2.velocity.y = 0;
		
		switch(_state)
		{
			case STATE_LOADING:
				
			case STATE_FADEIN:
				if (_sprFade.alpha > 0)
					_sprFade.alpha -= FlxG.elapsed * 6;
				else
					_state = STATE_PLAY;
			case STATE_PLAY:
				GamePlay();
		}
		
		super.update();
		
		if (_sprPlayer1.y < _levelBounds.top) _sprPlayer1.y =  _levelBounds.top;
		else if (_sprPlayer1.y >  _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer1.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
		if (_sprPlayer2.y < 16) _sprPlayer2.y = _levelBounds.top;
		else if (_sprPlayer2.y > _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer2.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
	}	
}