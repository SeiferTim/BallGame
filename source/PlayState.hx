package;

import flash.display.BlendMode;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flixel.addons.text.FlxBitmapFont;
import flixel.addons.tile.FlxTilemapExt;
import flixel.effects.FlxSpriteFilter;
import flixel.effects.particles.FlxEmitterExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.addons.display.FlxGridOverlay;
import levels.TiledLevel;
import openfl.events.JoystickEvent;
import flixel.effects.FlxTrail;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _background:FlxTileblock;
	private var _sprPlayer1:FlxSprite;
	private var _sprPlayer2:FlxSprite;
	private var _ball:FlxSprite;
	
	private var _levelBounds:FlxRect;
	private var _grpWalls:FlxGroup;
	private var _grpParticles:FlxGroup;
	private var _grpPlayers:FlxGroup;
	private var _grpEnemies:FlxGroup;
	private var _grpBall:FlxGroup;
	private var _grpUI:FlxGroup;
	
	private var _sprFade:FlxSprite;
	private var _grpBallTrail:FlxGroup;
	private var _grpLightTrail:FlxGroup;
	private var _grpPlayerTrail:FlxGroup;
	private var _grpNodes:FlxGroup;
	private var _collisionMap:FlxTilemapExt;
	
	private var _state:Int = 0;
	private inline static var STATE_LOADING:Int = 0;
	private inline static var STATE_FADEIN:Int = 1;
	private inline static var STATE_FADEOUT:Int = 2;
	private inline static var STATE_PLAY:Int = 3;
	private inline static var STATE_LEVELEND:Int = 4;
	
	private var _ballLaunched:Bool = false;
	private var _ballLaunchTimer:Float;
	private var _ballLaunchDisplay:FlxSprite;
	
	private var _p1score:Int;
	private var _p2score:Int;
	
	private var _txtP1Score:FlxBitmapFont;
	private var _txtP2Score:FlxBitmapFont;
	
	private var _lastHitBy:Int = 0;
	
	private var _ballTrail:FlxTrail;
	private var _lightTrail:FlxTrail;
	private var _p1Trail:FlxTrail;
	private var _p2Trail:FlxTrail;
	
	private var AITimer:Float;
	private var AIDir:Int;
	
	//private var _sprGrad:FlxSprite;
	//private var _sprGrad2:FlxSprite;
	//private var _sprGrad3:FlxSprite;
	
	private var _gameTimer:Float;
	
	private var _txtTimer:FlxBitmapFont;
	private var _burstEmitter:FlxEmitterExt;
	private var _ballFollow:Int;
	private var _timerIsRed:Bool;
	private var _timerTween:FlxTween;
	private var _grpFakeBalls:FlxGroup;
	
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		FlxG.mouse.hide();
		
		_state = STATE_LOADING;
		_ballLaunched = false;
		_p1score = 0;
		_p2score = 0;
		_lastHitBy = 0;
		
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
		_background = new FlxTileblock(0, 0, 704, 400).loadTiles("images/Tile.png", 16, 16);
		_background.scrollFactor.x = _background.scrollFactor.y = 0;
		_background.x = (FlxG.width - _background.width) / 2; 
		_background.y = (FlxG.height - _background.height) / 2; 
		//_background.blend = BlendMode.OVERLAY;
		
		_grpWalls = new FlxGroup(1);
		_grpBallTrail = new FlxGroup();
		_grpLightTrail = new FlxGroup();
		_grpPlayerTrail = new FlxGroup(2);
		_grpParticles = new FlxGroup();
		_grpPlayers = new FlxGroup(2);
		_grpEnemies = new FlxGroup(1);
		_grpNodes = new FlxGroup(1);
		_grpFakeBalls = new FlxGroup();
		_grpBall = new FlxGroup(1);
		_grpUI = new FlxGroup();
		
		_sprFade = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		
		_sprPlayer1 = new FlxSprite(16, 16).loadGraphic("images/Left Bumper Ship 1.png", true, false, 16, 48);//.makeGraphic(Reg.PLAYER_WIDTH, Reg.PLAYER_HEIGHT, FlxColor.BLUE);
		_sprPlayer1.animation.add("normal", [0, 1, 2, 1],6);
		_sprPlayer1.animation.play("normal");
		_sprPlayer2 = new FlxSprite(FlxG.width - 32, 16).loadGraphic("images/Right Bumper Ship 1.png", true, false, 16, 48);//).makeGraphic(Reg.PLAYER_WIDTH, Reg.PLAYER_HEIGHT, FlxColor.GOLDENROD);
		_sprPlayer2.animation.add("normal", [0, 1, 2, 1],6);
		_sprPlayer2.animation.play("normal");
		_sprPlayer1.immovable = true;
		_sprPlayer2.immovable = true;
		_sprPlayer1.allowCollisions = FlxObject.RIGHT;
		_sprPlayer2.allowCollisions = FlxObject.LEFT;
		
		_ball = new FlxSprite((FlxG.width - Reg.BALL_SIZE) / 2, (FlxG.height - Reg.BALL_SIZE) / 2).loadGraphic("images/Ball.png", true, false, 16, 16); // .makeGraphic(Reg.BALL_SIZE, Reg.BALL_SIZE, 0xffffffff);
		_ball.animation.add("neutral", [0, 1, 2, 1], 6);
		_ball.animation.add("p1", [3, 4, 5, 4], 6);
		_ball.animation.add("p2", [6, 7, 8, 7], 6);
		_ball.animation.play("neutral");
		_ball.elasticity = 1.025;
		_ball.maxVelocity.set(600, 600);
		//_ball.animation.add("normal", [0], 0, true);
		//_ball.animation.play("normal");
		
		
		/*var _filter:FlxSpriteFilter = new FlxSpriteFilter(_ball, 18, 18);
		_filter.addFilter(new GlowFilter(0xffccff, .6, 10, 10, 2, 1));
		*/
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
		
		_txtP1Score = new FlxBitmapFont(Reg.FONT_BLUE, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP1Score.setText("0", false, 0, 0, FlxBitmapFont.ALIGN_LEFT);
		_txtP1Score.y = 4;
		_txtP1Score.x = 4;
		_txtP1Score.scrollFactor.x = _txtP1Score.scrollFactor.y = 0;
		_grpUI.add(_txtP1Score);
		
		_txtP2Score = new FlxBitmapFont(Reg.FONT_RED, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP2Score.setText("0", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT);
		_txtP2Score.y = 4;
		_txtP2Score.x = FlxG.width - _txtP2Score.width - 4;
		_txtP2Score.scrollFactor.x = _txtP2Score.scrollFactor.y = 0;
		_grpUI.add(_txtP2Score);
		
		
		_lightTrail = new FlxTrail(_ball, "images/gradient.png", 4, 1, 1, .25);
		_lightTrail.setAll("width", Reg.BALL_SIZE);
		_lightTrail.setAll("height", Reg.BALL_SIZE);
		_lightTrail.setAll("offset", new FlxPoint((300 - Reg.BALL_SIZE) / 2, (300 - Reg.BALL_SIZE) / 2));
		
		_lightTrail.setAll("blend", BlendMode.OVERLAY);
		_grpLightTrail.add(_lightTrail);
		
		_ballTrail = new FlxTrail(_ball, null, 6, 3, .6, .1);
		_ballTrail.setAll("blend", BlendMode.HARDLIGHT);
		_grpBallTrail.add(_ballTrail);
		
		_p1Trail = new FlxTrail(_sprPlayer1, null, 6, 3, .6, .1);
		_p1Trail.setAll("blend", BlendMode.HARDLIGHT);
		_grpPlayerTrail.add(_p1Trail);
		
		_p2Trail = new FlxTrail(_sprPlayer2, null, 6, 3, .6, .1);
		_p2Trail.setAll("blend", BlendMode.HARDLIGHT);
		_grpPlayerTrail.add(_p2Trail);
		
		_txtTimer = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtTimer.setText("0:00", false, 0, 0, FlxBitmapFont.ALIGN_CENTER);
		_txtTimer.y = 4;
		_txtTimer.x = (FlxG.width - _txtTimer.width) / 2;
		_txtTimer.scrollFactor.x = _txtTimer.scrollFactor.y = 0;
		_grpUI.add(_txtTimer);
		
		_burstEmitter = new FlxEmitterExt();
		_burstEmitter.setRotation(0, 0);
		_burstEmitter.setMotion(0, 5,2, 360, 100, 4);
		_burstEmitter.makeParticles("images/particles.png", 1200, 0, true, 0);
		_burstEmitter.blend = BlendMode.HARDLIGHT;
        _grpParticles.add(_burstEmitter);
		
		add(_background);
		//add(_sprGrad);
		//add(_sprGrad2);
		//add(_sprGrad3);
		
		add(_grpLightTrail);
		
		add(_grpWalls);
		
		add(_grpBallTrail);
		add(_grpPlayerTrail);
		add(_grpParticles);
		add(_grpPlayers);
		add(_grpEnemies);
		add(_grpNodes);
		add(_grpFakeBalls);
		add(_grpBall);
		add(_grpUI);
		add(_sprFade);
		
	}
	
	private function burst(X:Float = -1, Y:Float = -1):Void
	{
		if (X == -1 && Y == -1)
		{
			_burstEmitter.x = _ball.x + (Reg.BALL_SIZE/2);
			_burstEmitter.y = _ball.y + (Reg.BALL_SIZE / 2);
		}
		else
		{
			_burstEmitter.x = X + (Reg.BALL_SIZE/2);
			_burstEmitter.y = Y + (Reg.BALL_SIZE / 2);
		}
		
		
		_burstEmitter.start(true, 0, 0, 120,1);
		_burstEmitter.update();
	}
	
	private function LoadLevel():Void
	{
		
		var level:TiledLevel = new TiledLevel("data/room-" + Reg.levels[Reg.level] + ".tmx", "data/tiles.tanim");
		
		_grpWalls.add(level.wallTiles);
		
		_grpWalls.setAll("x", (FlxG.width - level.fullWidth) / 2);
		_grpWalls.setAll("y", (FlxG.height - level.fullHeight) / 2);
		
		_sprPlayer1.y = (FlxG.height - Reg.PLAYER_HEIGHT) / 2;
		_sprPlayer2.y = (FlxG.height - Reg.PLAYER_HEIGHT) / 2;
		
		if (_grpEnemies.members.length > 0)
			_grpEnemies.replace(_grpEnemies.members[0], level.enemies);
		else
			_grpEnemies.add(level.enemies);
		
		if (_grpNodes.members.length > 0)
			_grpNodes.replace(_grpNodes.members[0], level.objects);
		else
			_grpNodes.add(level.objects);
		
		_gameTimer = Reg.GAME_TIME;
		ResetBall();
	}
	
	private function ResetBall():Void
	{
		
		
		SnapBall();
		_ballLaunchDisplay.animation.frameIndex = 0;
		_ballLaunchDisplay.alpha = 0;
		_ballLaunchDisplay.visible = true;
		_ballLaunchTimer = 2;
		_ballLaunched = false;
		_lastHitBy = 0;
		_ball.animation.play("neutral");
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
	
	private function MovePaddle(WhichPaddle:FlxSprite, WhichDir:Int):Void
	{
		WhichPaddle.velocity.y = WhichDir == FlxObject.UP ? -Reg.PLAYER_SPEED : Reg.PLAYER_SPEED;
	}
	
	private function P2AI():Void
	{
		var ballMid:FlxPoint = _ball.getMidpoint();
		var paddleMid:Float = _sprPlayer2.y + (Reg.PLAYER_HEIGHT / 2);
		var targetY:Float;
		
		if (_ball.velocity.x < 0 || _ball.x < FlxG.width * 0.4)
			targetY =  ballMid.y  + (FlxRandom.sign() * Reg.PLAYER_HEIGHT * 2);
		else
			targetY =  ballMid.y;
		
		targetY += FlxRandom.sign() * FlxRandom.floatRanged(0, Reg.PLAYER_HEIGHT*FlxRandom.floatRanged(.2,.5) +(FlxRandom.sign() * Math.floor(FlxRandom.floatRanged(0,1)) * (Reg.PLAYER_HEIGHT*.7)));
		
		if (targetY < paddleMid - Reg.PLAYER_HEIGHT * FlxRandom.floatRanged(0.2,0.3))
		{
			if (AIDir == FlxObject.UP || AITimer <= 0)
			{
				MovePaddle(_sprPlayer2, FlxObject.UP);
				AIDir = FlxObject.UP;
				AITimer = FlxRandom.floatRanged(.9,1.2);
			}
			else if (AITimer > 0)
				AITimer -= FlxG.elapsed * 12;
			
			
		}
		else if (targetY > paddleMid + Reg.PLAYER_HEIGHT *  FlxRandom.floatRanged(0.2,0.4))
		{
			if (AIDir == FlxObject.DOWN || AITimer <= 0)
			{
				MovePaddle(_sprPlayer2, FlxObject.DOWN);
				AIDir = FlxObject.DOWN;
				AITimer = FlxRandom.floatRanged(.9,1.2);
			}
			else if (AITimer > 0)
				AITimer -= FlxG.elapsed * 12;
		}
		else
		{
			AITimer = FlxRandom.floatRanged(.9,1.4);
			AIDir = -1;
		}
		
		
	}
	
	private function GamePlay():Void
	{
		
		
		if (FlxG.keyboard.anyPressed(Reg.P1_KEYS_UP))
		{
			MovePaddle(_sprPlayer1, FlxObject.UP);
		}
		else if (FlxG.keyboard.anyPressed(Reg.P1_KEYS_DOWN))
		{
			MovePaddle(_sprPlayer1, FlxObject.DOWN);
		}
		
		if (Reg.numPlayers == 2)
		{
			if (FlxG.keyboard.anyPressed(Reg.P2_KEYS_UP))
			{
				MovePaddle(_sprPlayer2, FlxObject.UP);
			}
			else if (FlxG.keyboard.anyPressed(Reg.P2_KEYS_DOWN))
			{
				MovePaddle(_sprPlayer2, FlxObject.DOWN);
			}
		}
		else
		{
			P2AI();
		}
		
		FlxG.collide(_ball, _grpWalls, BallHitWall);
		FlxG.collide(_grpPlayers, _ball, BallHitPlayer);
		FlxG.collide(_grpFakeBalls, _grpWalls, FakeBallHitWall);
		FlxG.collide(_grpPlayers, _grpFakeBalls, FakeBallHitsPlayer);
		
		if (_lastHitBy != 0)
		{
			FlxG.collide(_grpEnemies, _ball, BallHitEnemy);
			FlxG.collide(_grpNodes, _ball, BallHitNode);
		}
		
		
		
		if (!_ballLaunched)
		{
			// Ball not launched yet...
			LaunchBall();
		}
		else if (!_ball.onScreen())
		{
			// reset the ball!
			if (_ball.x < 0)
			{
				_ballFollow = 1;
				_p2score += 100;
			}
			else
			{
				_ballFollow = 2;
				_p1score += 100;
			}
			ResetBall();
		}
		else
		{
			_gameTimer -= FlxG.elapsed;
			if (_gameTimer <= 0)
			{
				_gameTimer = 0;
				_state = STATE_LEVELEND;
				Reg.scores.push([_p1score, _p2score]);
				_ball.velocity.x = _ball.velocity.y = 0;
			}
			if (_ball.velocity.x > -10 && _ball.velocity.x < 10)
				_ball.velocity.x *= 10;
			
		}
	}
	
	
	private function SnapBall():Void
	{
		if (_ballFollow == 0)
		{
			_ball.x = (FlxG.width - Reg.BALL_SIZE) / 2;
			_ball.y = (FlxG.height - Reg.BALL_SIZE) / 2;
		}
		else if (_ballFollow == 1)
		{
			_ball.x = _sprPlayer1.x + Reg.PLAYER_WIDTH + 2;
			_ball.y = _sprPlayer1.y + ((Reg.PLAYER_HEIGHT - Reg.BALL_SIZE) / 2);
		}
		else if (_ballFollow == 2)
		{
			_ball.x = _sprPlayer2.x - Reg.BALL_SIZE - 2;
			_ball.y = _sprPlayer2.y + ((Reg.PLAYER_HEIGHT - Reg.BALL_SIZE) / 2);
		}
		_ball.velocity.x = 0;
		_ball.velocity.y = 0;
	}
	
	private function LaunchBall():Void
	{
		SnapBall();
		if (_ballLaunchTimer > 0)
		{
			_ballLaunchTimer -= FlxG.elapsed * 3;
			if (_ballLaunchTimer > 1)
			{
				_ballLaunchDisplay.alpha = 1;
				
			}
			else
			{
				_ballLaunchDisplay.alpha = _ballLaunchTimer;
			}
		}
		else if (_ballLaunchDisplay.animation.frameIndex < 3)
		{
			_ballLaunchDisplay.animation.frameIndex++;
			_ballLaunchTimer = 2;
			_ballLaunchDisplay.alpha = 1;
		}
		else if (_ballLaunchDisplay.animation.frameIndex == 3)
		{
			_ballLaunchDisplay.visible = false;
			if (_ballFollow==0)
			{
				_ball.velocity.x = FlxRandom.sign() * 200;
				_ball.velocity.y = FlxRandom.sign() * FlxRandom.intRanged(0, 20);
			}
			else
			{
				if (_ballFollow == 1)
				{
					_ball.velocity.x = 200;
					_ball.velocity.y = FlxRandom.sign() * FlxRandom.intRanged(0, 20) + _sprPlayer1.velocity.y * .2;
					ChangeOwner(1);
				}
				else if (_ballFollow == 2)
				{
					_ball.velocity.x = -200;
					_ball.velocity.y = FlxRandom.sign() * FlxRandom.intRanged(0, 20) + _sprPlayer2.velocity.y * .2;
					ChangeOwner(2);
				}
			}
			_ballFollow = 0;
			_ballLaunched = true;
		}
	}
	
	private function BallHitNode(N:FlxObject, B:FlxObject):Void
	{
		if (cast(N, PointNode).owner != _lastHitBy)
		{
			cast(N, PointNode).owner = _lastHitBy;
			if (_lastHitBy == 1)
			{
				_p1score += 10;
			}
			else if (_lastHitBy == 2)
			{
				_p2score += 10;
			}
		}
		_ball.velocity.x *= 1.25;
		_ball.velocity.y *= 1.25;
		burst();
	}
	
	private function BallHitEnemy(E:FlxObject, B:FlxObject):Void
	{
		var enemyMid:Int = Std.int(E.y + (E.height / 2));
		var ballMid:Int = Std.int(B.y + (Reg.BALL_SIZE / 2));
		var diff:Int;
		var eType:Int = cast(E, Enemy).etype;
		
		E.hurt(1);
		if (cast(E, Enemy).dying)
		{
			if (_lastHitBy == 1)
			{
				_p1score += 25;
			}
			else if (_lastHitBy == 2)
			{
				_p2score += 25;
			}
		}
		burst();
		
		if ( eType <= 1)
		{
			/*if (ballMid < enemyMid)
			{
				// ball hit the 'top' of the paddle
				diff = enemyMid - ballMid;
				B.velocity.y = ( -8 * Math.abs(diff));
			}
			else if (ballMid > enemyMid)
			{
				// ball hit the 'bottom' of the paddle
				diff = enemyMid - ballMid;
				B.velocity.y = ( 8 * Math.abs(diff));
			}
			else
			{
				// ball hit right in the middle...
				// randomize!
				B.velocity.y = 2 + Std.int(Math.random() * 16);
			}*/
			
			
		}
		else if (eType == 2)
		{
			var newAngle:FlxPoint = FlxAngle.rotatePoint(B.velocity.x, B.velocity.y, 0,0, FlxRandom.floatRanged( -180, 180));
			B.velocity.x = newAngle.x;
			B.velocity.y = newAngle.y;
		}
		else if (eType == 3)
		{
			
			var newAngle:FlxPoint = FlxAngle.rotatePoint(B.velocity.x, B.velocity.y, 0,0, FlxRandom.floatRanged( -180, 180));
			B.velocity.x = newAngle.x;
			B.velocity.y = newAngle.y;
			ChangeOwner(0);
			
			newAngle = FlxAngle.rotatePoint(B.velocity.x, B.velocity.y, 0, 0, FlxRandom.floatRanged( -180, 180));
			var fb1:FakeBall = cast _grpFakeBalls.recycle(FakeBall, [B.x, B.y, newAngle.x, newAngle.y]);
			var fTrail:FlxTrail = new FlxTrail(fb1, null, 6, 3, .6, .1);
			fTrail.setAll("blend", BlendMode.HARDLIGHT);
			fb1.trail = fTrail;
			fb1.alpha = .6;
			_grpBallTrail.add(fTrail);
			
			var lTrail:FlxTrail = new FlxTrail(fb1, "images/gradient.png", 10, 1, 1, .1);
			lTrail.setAll("offset", new FlxPoint((300 - Reg.BALL_SIZE) / 2,(300 - Reg.BALL_SIZE) / 2));
			lTrail.setAll("blend", BlendMode.OVERLAY);
			_grpLightTrail.add(lTrail);
			fb1.grad = lTrail;
			
			newAngle = FlxAngle.rotatePoint(B.velocity.x, B.velocity.y, 0, 0, FlxRandom.floatRanged( -180, 180));
			var fb2:FakeBall = cast _grpFakeBalls.recycle(FakeBall, [B.x, B.y, newAngle.x, newAngle.y]);
			var fTrail:FlxTrail = new FlxTrail(fb2, null, 6, 3, .6, .1);
			fTrail.setAll("blend", BlendMode.HARDLIGHT);
			fb2.trail = fTrail;
			fb2.alpha = .6;
			_grpBallTrail.add(fTrail);
			
			var lTrail2:FlxTrail = new FlxTrail(fb2, "images/gradient.png", 10, 1, 1, .1);
			lTrail2.setAll("offset", new FlxPoint((300 - Reg.BALL_SIZE) / 2,(300 - Reg.BALL_SIZE) / 2));
			lTrail2.setAll("blend", BlendMode.OVERLAY);
			_grpLightTrail.add(lTrail2);
			fb2.grad = lTrail2;
			
			
		}
		
		
	}
	
	private function ChangeOwner(WhichPlayer:Int):Void
	{
		if (WhichPlayer == 0)
			_ball.animation.play("neutral");
		else
			_ball.animation.play("p" + Std.string(WhichPlayer));
		_lastHitBy = WhichPlayer;
	}
	
	private function FakeBallHitsPlayer(P:FlxObject, B:FlxObject):Void
	{
		burst(B.x, B.y);
		B.kill();
	}
	
	private function BallHitPlayer(P:FlxObject, B:FlxObject):Void
	{
		if (P.x == 16)
		{
			ChangeOwner(1);
		}
		else
		{
			ChangeOwner(2);
		}
		var playerMid:Int = Std.int(P.y + (Reg.PLAYER_HEIGHT / 2));
		var ballMid:Int = Std.int(B.y + (Reg.BALL_SIZE / 2));
		var diff:Int;
		if (ballMid < playerMid)
		{
			// ball hit the 'top' of the paddle
			diff = playerMid - ballMid;
			B.velocity.y = ( -4 * Math.abs(diff)) + (P.velocity.y * 0.2);
		}
		else if (ballMid > playerMid)
		{
			// ball hit the 'bottom' of the paddle
			diff = playerMid - ballMid;
			B.velocity.y = ( 4 * Math.abs(diff)) + (P.velocity.y *0.2);
		}
		else
		{
			// ball hit right in the middle...
			// randomize!
			B.velocity.y = 2 + Std.int(Math.random() * 8) + (P.velocity.y *0.2);
		}
		burst();
	}
	
	private function BallHitWall(W:FlxObject, B:FlxObject):Void
	{
		burst();
	}
	
	private function FakeBallHitWall(W:FlxObject, B:FlxObject):Void
	{
		burst(B.x, B.y);
	}

	
	private function SetTimerText():Void
	{
		_txtTimer.text =  StringTools.lpad( Std.string(Math.ceil(_gameTimer) ), '0', 2) ;
		_txtTimer.x = (FlxG.width - _txtTimer.width) / 2;
		if (_gameTimer < 10 && !_timerIsRed)
		{
			_txtTimer.setFontGraphics( FlxG.bitmap.add(Reg.FONT_RED));
			_timerTween = FlxTween.multiVar(_txtTimer, { alpha:.6 }, .3, { type: FlxTween.PINGPONG, ease: FlxEase.expoInOut } );
			_timerIsRed = true;
		}
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		SetTimerText();
		
		if (_lastHitBy <= 0)
			_ball.alpha = .6;
		else
		{
			_ball.alpha = 1;
		}
		
		
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
			case STATE_LEVELEND:
				if (_sprFade.alpha < 1)
					_sprFade.alpha += FlxG.elapsed * 6;
				else
					FlxG.switchState(new ScoreBoardState());
		}
		
		SetScoreText();
		
		super.update();
		
		if (_sprPlayer1.y < _levelBounds.top) _sprPlayer1.y =  _levelBounds.top;
		else if (_sprPlayer1.y >  _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer1.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
		if (_sprPlayer2.y < 16) _sprPlayer2.y = _levelBounds.top;
		else if (_sprPlayer2.y > _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer2.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
	}
	
	private function SetScoreText():Void
	{
		if (_p1score != Std.parseInt(_txtP1Score.text))
		{
			_txtP1Score.text = Std.string(Std.parseInt(_txtP1Score.text) + 1);
		}
		if (_p2score != Std.parseInt(_txtP2Score.text))
		{
			_txtP2Score.text = Std.string(Std.parseInt(_txtP2Score.text) + 1);
			_txtP2Score.x = FlxG.width - _txtP2Score.width - 4;
		}
	}
	
	override public function draw():Void
	{
		super.draw();
		
	}
	
}