package;

import flash.display.BlendMode;
import flixel.addons.text.FlxBitmapFont;
import flixel.addons.tile.FlxTilemapExt;
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
	private var _grpPlayerTrail:FlxGroup;
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
	private var _p1Trail:FlxTrail;
	private var _p2Trail:FlxTrail;
	
	private var AITimer:Float;
	private var AIDir:Int;
	
	private var _sprGrad:FlxSprite;
	private var _sprGrad2:FlxSprite;
	
	private var _gameTimer:Float;
	
	private var _txtTimer:FlxBitmapFont;
	private var _burstEmitter:FlxEmitterExt;
	private var _ballFollow:Int;
	private var _timerIsRed:Bool;
	private var _timerTween:FlxTween;
	
	
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
		//_background =  FlxGridOverlay.create(8,8,-1,-1,false,true, 0x33d83aad, 0x66d83aad ); //new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xff666666);
		
		_background = new FlxTileblock(0, 0, 704, 400).loadTiles("images/Tile.png", 16, 16);
		_background.scrollFactor.x = _background.scrollFactor.y = 0;
		_background.x = (FlxG.width - _background.width) / 2; 
		_background.y = (FlxG.height - _background.height) / 2; 
		
		_sprGrad = new FlxSprite(0, 0, "images/gradient.png");
		_sprGrad.blend = BlendMode.OVERLAY;
		_sprGrad2 = new FlxSprite(0, 0, "images/gradient.png");
		_sprGrad2.blend = BlendMode.OVERLAY;
		
		
		_grpWalls = new FlxGroup(1);
		_grpBallTrail = new FlxGroup(1);
		_grpPlayerTrail = new FlxGroup(2);
		_grpParticles = new FlxGroup();
		_grpPlayers = new FlxGroup(2);
		_grpEnemies = new FlxGroup(1);
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
		_ball.animation.add("normal", [0], 0, true);
		_ball.animation.play("normal");
		
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
		
		//_txtP1Score = new FlxText(4, 4, 200, "0",16);
		_txtP1Score = new FlxBitmapFont(Reg.FONT_BLUE, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP1Score.setText("0", false, 0, 0, FlxBitmapFont.ALIGN_LEFT);
		//_txtP1Score.borderStyle = FlxText.BORDER_OUTLINE;
		//_txtP1Score.alignment="left";
		_txtP1Score.y = 4;
		_txtP1Score.x = 4;
		_txtP1Score.scrollFactor.x = _txtP1Score.scrollFactor.y = 0;
		_grpUI.add(_txtP1Score);
		
		//_txtP2Score = new FlxText(FlxG.width - 204, 4, 200, "0",16);
		//_txtP2Score.borderStyle = FlxText.BORDER_OUTLINE;
		//_txtP2Score.alignment="right";
		_txtP2Score = new FlxBitmapFont(Reg.FONT_RED, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP2Score.setText("0", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT);
		_txtP2Score.y = 4;
		_txtP2Score.x = FlxG.width - _txtP2Score.width - 4;
		_txtP2Score.scrollFactor.x = _txtP2Score.scrollFactor.y = 0;
		_grpUI.add(_txtP2Score);
		
		_ballTrail = new FlxTrail(_ball, null, 6, 3, .6, .1);
		_ballTrail.setAll("blend", BlendMode.HARDLIGHT);
		_grpBallTrail.add(_ballTrail);
		
		_p1Trail = new FlxTrail(_sprPlayer1, null, 6, 3, .6, .1);
		_p1Trail.setAll("blend", BlendMode.HARDLIGHT);
		_grpPlayerTrail.add(_p1Trail);
		
		_p2Trail = new FlxTrail(_sprPlayer2, null, 6, 3, .6, .1);
		_p2Trail.setAll("blend", BlendMode.HARDLIGHT);
		_grpPlayerTrail.add(_p2Trail);
		
		//_txtTimer = new FlxText(4, 0, 100, "0:00",16);
		//_txtTimer.borderStyle = FlxText.BORDER_OUTLINE;
		//_txtTimer.alignment = "center";
		_txtTimer = new FlxBitmapFont(Reg.FONT_RED, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtTimer.setText("0:00", false, 0, 0, FlxBitmapFont.ALIGN_CENTER);
		_txtTimer.y = 4;
		_txtTimer.x = (FlxG.width - _txtTimer.width) / 2;
		_txtTimer.scrollFactor.x = _txtTimer.scrollFactor.y = 0;
		_grpUI.add(_txtTimer);
		
		_burstEmitter = new FlxEmitterExt();
		_burstEmitter.setRotation(0, 0);
		_burstEmitter.setMotion(0, 5,2, 360, 100, 4);
		_burstEmitter.makeParticles("images/particles.png", 1200, 0, true, 0);
		_burstEmitter.blend = BlendMode.SCREEN;
        _grpParticles.add(_burstEmitter);
		
		add(_background);
		add(_sprGrad);
		add(_sprGrad2);
		add(_grpWalls);
		add(_grpBallTrail);
		add(_grpPlayerTrail);
		add(_grpParticles);
		add(_grpPlayers);
		add(_grpEnemies);
		add(_grpBall);
		add(_grpUI);
		add(_sprFade);

		
	}
	
	private function burst():Void
	{
		_burstEmitter.x = _ball.x + (Reg.BALL_SIZE/2);
		_burstEmitter.y = _ball.y + (Reg.BALL_SIZE/2);
		_burstEmitter.start(true, 0, 0, 80,1);
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
		
		_gameTimer = Reg.GAME_TIME;
		ResetBall();
	}
	
	private function ResetBall():Void
	{
		
		
		SnapBall();
		_ballLaunchDisplay.animation.frameIndex = 0;
		_ballLaunchDisplay.alpha = 0;
		//_ballLaunchDisplay.scale.x = _ballLaunchDisplay.scale.y = 1;
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
		
		if (_lastHitBy != 0)
			FlxG.collide(_grpEnemies, _ball, BallHitEnemy);
		
		
		
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
			_ball.x = _sprPlayer2.x + Reg.PLAYER_WIDTH + 2;
			_ball.y = _sprPlayer2.y + ((Reg.PLAYER_HEIGHT - Reg.BALL_SIZE) / 2);
		}
		_ball.velocity.x = 0;
		_ball.velocity.y = 0;
	}
	
	private function LaunchBall():Void
	{
		/*_ball.x = (FlxG.width - Reg.BALL_SIZE) / 2;
		_ball.y = (FlxG.height - Reg.BALL_SIZE) / 2;
		_ball.velocity.x = 0;
		_ball.velocity.y = 0;*/
		
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
				//_ballLaunchDisplay.scale.x +=FlxG.elapsed * 6;
				//_ballLaunchDisplay.scale.y +=FlxG.elapsed * 6;
				_ballLaunchDisplay.alpha = _ballLaunchTimer;
			}
		}
		else if (_ballLaunchDisplay.animation.frameIndex < 3)
		{
			_ballLaunchDisplay.animation.frameIndex++;
			_ballLaunchTimer = 2;
			_ballLaunchDisplay.alpha = 1;
			//_ballLaunchDisplay.scale.x = _ballLaunchDisplay.scale.y = 1;
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
	
	private function BallHitEnemy(E:FlxObject, B:FlxObject):Void
	{
		var enemyMid:Int = Std.int(E.y + (E.height / 2));
		var ballMid:Int = Std.int(B.y + (Reg.BALL_SIZE / 2));
		var diff:Int;
		if (ballMid < enemyMid)
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
		}
		E.hurt(1);
		if (cast(E, Enemy).dying)
		{
			if (_lastHitBy == 1)
			{
				_p1score += 100;
			}
			else if (_lastHitBy == 2)
			{
				_p2score += 100;
			}
		}
		burst();
	}
	
	private function ChangeOwner(WhichPlayer:Int):Void
	{
		_ball.animation.play("p" + Std.string(WhichPlayer));
		_lastHitBy = WhichPlayer;
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


	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		
		_txtTimer.text =  StringTools.lpad( Std.string(Math.ceil(_gameTimer) ), '0', 2) ;
		_txtTimer.x = (FlxG.width - _txtTimer.width) / 2;
		if (_gameTimer < 10 && !_timerIsRed)
		{
			//_txtTimer.color = 0xffff9999;
			_txtTimer.setFontGraphics( FlxG.bitmap.add(Reg.FONT_RED));
			_timerTween = FlxTween.multiVar(_txtTimer, { alpha:.6 }, .3, { type: FlxTween.PINGPONG, ease: FlxEase.expoInOut } );
			_timerIsRed = true;
			
		}
		
		
		
		if (_lastHitBy <= 0)
			_ball.alpha = .6;
		else
		{
			_ball.alpha = 1;
			//FlxG.collide(_grpEnemies, _ball, BallHitEnemy);
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
		
		if (_p1score != Std.parseInt(_txtP1Score.text))
		{
			_txtP1Score.text = Std.string(Std.parseInt(_txtP1Score.text) + 1);
		}
		if (_p2score != Std.parseInt(_txtP2Score.text))
		{
			_txtP2Score.text = Std.string(Std.parseInt(_txtP2Score.text) + 1);
			_txtP2Score.x = FlxG.width - _txtP2Score.width - 4;
		}
		
		super.update();
		
		if (_sprPlayer1.y < _levelBounds.top) _sprPlayer1.y =  _levelBounds.top;
		else if (_sprPlayer1.y >  _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer1.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
		if (_sprPlayer2.y < 16) _sprPlayer2.y = _levelBounds.top;
		else if (_sprPlayer2.y > _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer2.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
	}
	
	override public function draw():Void
	{
		
		_sprGrad.x = _ball.x + ((_ball.width - _sprGrad.width) / 2);
		_sprGrad.y = _ball.y + ((_ball.height - _sprGrad.height) / 2);
		_sprGrad2.x = _ball.x + ((_ball.width - _sprGrad2.width) / 2);
		_sprGrad2.y = _ball.y + ((_ball.height - _sprGrad2.height) / 2);
		super.draw();
		
	}
	
}