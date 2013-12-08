package;

import flash.display.BlendMode;
import flash.events.Event;
import flixel.addons.text.FlxBitmapFont;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.ui.FlxButtonPlus;
import flixel.effects.FlxSpriteFilter;
import flixel.effects.FlxTrail;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitterExt;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.input.touch.FlxTouch;
import flixel.tile.FlxTileblock;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAngle;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import levels.TiledLevel;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _background:FlxTileblock;
	private var _sprPlayer1:FlxSprite;
	private var _sprPlayer2:FlxSprite;
	private var _ball:FlxSprite;
	private var justTriggered:Bool;
	
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
	private var _grpEnemyTrail:FlxGroup;
	private var _grpPlayerTrail:FlxGroup;
	private var _grpNodes:FlxGroup;
	private var _collisionMap:FlxTilemapExt;
	
	private var _state:Int = 0;
	private inline static var STATE_LOADING:Int = 0;
	private inline static var STATE_FADEIN:Int = 1;
	private inline static var STATE_FADEOUT:Int = 2;
	private inline static var STATE_PLAY:Int = 3;
	private inline static var STATE_LEVELEND:Int = 4;
	private inline static var STATE_PREPLAY:Int = 5;
	
	private var _ballLaunched:Bool = false;
	private var _ballLaunchTimer:Float;
	private var _ballLaunchDisplay:FlxSprite;
	private var _ballLaunchScale:Float;
	
	private var _scores:Array<Int>;
	private var _multi:Array<Int>;
	
	private var _txtP1Score:FlxBitmapFont;
	private var _txtP2Score:FlxBitmapFont;
	
	private var _lastHitBy:Int = 0;
	
	private var _p1Trail:FlxTrail;
	private var _p2Trail:FlxTrail;
	
	private var AITimer:Float;
	private var AIDir:Int;
	
	private var _gameTimer:Float;
	
	private var _txtTimer:FlxBitmapFont;
	private var _burstEmitter:FlxEmitterExt;
	private var _ballFollow:Int;
	private var _timerIsRed:Bool;
	private var _timerTween:FlxTween;
	private var _grpFakeBalls:FlxGroup;
	
	private var _txtP1Multi:FlxBitmapFont;
	private var _txtP2Multi:FlxBitmapFont;
	
	private var _p1Emit:FlxEmitter;
	private var _p2Emit:FlxEmitter;
	private var _grpPlayerEmits:FlxGroup;
	
	#if !FLX_NO_TOUCH
	private var _p1TouchZone:FlxRect;
	private var _p2TouchZone:FlxRect;
	#end
	
	private var _paused:Bool;
	private var _pauseScreen:FlxGroup;
	
	private var _twn:FlxTween;
	private var _pauseTwn:FlxTween;
	
	private var GameStartTimer:Float;
	
	private var _pauseAlpha:Float;
	
	private var _grpQuit:FlxGroup;
	private var _grpPause:FlxGroup;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff4e1c8d;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
		#end
		
		_state = STATE_LOADING;
		_ballLaunched = false;
		Reg.Freeze = true;
		
		_scores = new Array<Int>();
		_multi = new Array<Int>();
		_scores[1] = _scores[2] = 0;
		_multi[1] = _multi[2] = 1;
		_lastHitBy = 0;
		
		
		InitGameScreen();
		
		_levelBounds = new FlxRect(16, 16, FlxG.width - 32, FlxG.height - 32);
		
		Reg.level = 0;
		LoadLevel();

		super.create();
		
		_state = STATE_FADEIN;
		_twn = FlxTween.multiVar(_sprFade, { alpha:0 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeIn } );
		GameStartTimer  = 4;
		justTriggered = true;
		_pauseAlpha = 0.0001;
		FlxG.autoPause = false;
		//FlxG.watch.add(this, "_pauseAlpha");
		
	}
	
	override public function onFocusLost():Void 
	{
		//super.onFocusLost();
		if (_paused) return;
		StartPause();
	}
	
	override public function onFocus():Void 
	{
		//super.onFocus();
	}
	
	private function DoneFadeIn(T:FlxTween):Void
	{
		//_state = STATE_PREPLAY;
		ResetGamePlay();
	}
	
	private function AddLightTrail(Target:FlxSprite):FlxTrail
	{
		var _lightTrail:FlxTrail = new FlxTrail(Target, "images/gradient3.png", 1, 12, .6, .08);
		_lightTrail.setAll("width", Target.width);
		_lightTrail.setAll("height", Target.height);
		_lightTrail.setAll("offset", new FlxPoint((300 - Target.width) / 2, (300 - Target.height) / 2));
		_lightTrail.setAll("blend", BlendMode.ADD);
		_grpLightTrail.add(_lightTrail);
		return _lightTrail;
	}
	
	private function AddTrail(Target:FlxSprite, Group:FlxGroup):FlxTrail
	{
		var _ballTrail = new FlxTrail(Target, null, 4, 10, .4, .08);
		_ballTrail.setAll("blend", BlendMode.ADD);
		Group.add(_ballTrail);
		return _ballTrail;
	}
	
	private function InitGameScreen():Void
	{
		
		#if !FLX_NO_TOUCH
		_p1TouchZone = new FlxRect(0, 0, FlxG.width / 4, FlxG.height);
		_p2TouchZone = new FlxRect(0, FlxG.width - (FlxG.width / 4), FlxG.width / 4, FlxG.height);
		#end
		
		_background = new FlxTileblock(0, 0, 704, 400).loadTiles("images/Tile-Top.png", 16, 16);
		_background.scrollFactor.x = _background.scrollFactor.y = 0;
		_background.x = (FlxG.width - _background.width) / 2; 
		_background.y = (FlxG.height - _background.height) / 2; 
		_background.blend = BlendMode.NORMAL;
		
		_grpWalls = new FlxGroup(1);
		_grpBallTrail = new FlxGroup();
		_grpLightTrail = new FlxGroup();
		_grpEnemyTrail = new FlxGroup();
		_grpPlayerTrail = new FlxGroup(2);
		_grpParticles = new FlxGroup();
		_grpPlayers = new FlxGroup(2);
		_grpEnemies = new FlxGroup(1);
		_grpNodes = new FlxGroup(1);
		_grpFakeBalls = new FlxGroup();
		_grpBall = new FlxGroup(1);
		_grpUI = new FlxGroup();
		_grpPlayerEmits = new FlxGroup();
		
		_sprFade = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		_sprFade.blend = BlendMode.ADD;
		
		_sprPlayer1 = new FlxSprite(22, 16).loadGraphic("images/Left-Bumper-Ship-1.png", true, false, 18, 48);//.makeGraphic(Reg.PLAYER_WIDTH, Reg.PLAYER_HEIGHT, FlxColor.BLUE);
		_sprPlayer1.width = 15;
		_sprPlayer1.offset.x = 2;
		_sprPlayer1.animation.add("normal", [0, 1, 2, 1],6);
		_sprPlayer1.animation.play("normal");
		_sprPlayer2 = new FlxSprite(FlxG.width - 22 - 15, 16).loadGraphic("images/Right-Bumper-Ship-1.png", true, false, 18, 48);//).makeGraphic(Reg.PLAYER_WIDTH, Reg.PLAYER_HEIGHT, FlxColor.GOLDENROD);
		_sprPlayer2.width = 15;
		_sprPlayer2.offset.x = 1;
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
		

		_grpPlayers.add(_sprPlayer1);
		_grpPlayers.add(_sprPlayer2);
		_grpBall.add(_ball);
		
		_ballLaunchDisplay = new FlxSprite(0, 0).loadGraphic("images/count-down.png", true, false, 360, 360);
		_ballLaunchDisplay.animation.add("count", [0, 1, 2, 3], 0, false);
		_ballLaunchDisplay.animation.pause();
		_ballLaunchDisplay.animation.frameIndex = 0;
		_ballLaunchDisplay.alpha = 0;
		_ballLaunchDisplay.visible = false;
		_ballLaunchScale = 1;
		_ballLaunchDisplay.scale.set(_ballLaunchScale, _ballLaunchScale);
		_ballLaunchDisplay.x = (FlxG.width - _ballLaunchDisplay.width) / 2;
		_ballLaunchDisplay.y = (FlxG.height - _ballLaunchDisplay.height) / 2;
		_ballLaunchTimer = 3;
		
		_grpUI.add(_ballLaunchDisplay);
		
		_txtP1Multi = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP1Multi.setText(Std.string(_multi[1])+"x", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		_txtP1Multi.y = 4;
		_txtP1Multi.x = 4;
		_txtP1Multi.scrollFactor.x = _txtP1Multi.scrollFactor.y = 0;
		_grpUI.add(_txtP1Multi);
		
		_txtP1Score = new FlxBitmapFont(Reg.FONT_BLUE, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP1Score.setText("0", false, 0, 0, FlxBitmapFont.ALIGN_LEFT);
		_txtP1Score.y = 4;
		_txtP1Score.x = _txtP1Multi.x + _txtP1Multi.width;
		_txtP1Score.scrollFactor.x = _txtP1Score.scrollFactor.y = 0;
		_grpUI.add(_txtP1Score);
		
		_txtP2Multi = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP2Multi.setText("x"+ Std.string(_multi[1]), false, 0, 0, FlxBitmapFont.ALIGN_RIGHT, true);
		_txtP2Multi.y = 4;
		_txtP2Multi.x = FlxG.width - _txtP2Multi.width - 4;
		_txtP2Multi.scrollFactor.x = _txtP2Multi.scrollFactor.y = 0;
		_grpUI.add(_txtP2Multi);
		
		_txtP2Score = new FlxBitmapFont(Reg.FONT_RED, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtP2Score.setText("0", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT);
		_txtP2Score.y = 4;
		_txtP2Score.x = _txtP2Multi.x - _txtP2Score.width;
		_txtP2Score.scrollFactor.x = _txtP2Score.scrollFactor.y = 0;
		_grpUI.add(_txtP2Score);
		
		
		AddTrail(_ball,_grpBallTrail);
		AddTrail(_sprPlayer1, _grpPlayerTrail);
		AddTrail(_sprPlayer2, _grpPlayerTrail);
		
		AddLightTrail(_ball);
		AddLightTrail(_sprPlayer1);
		AddLightTrail(_sprPlayer2);
		
		_txtTimer = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtTimer.setText("60", false, 0, 0, FlxBitmapFont.ALIGN_CENTER);
		_txtTimer.y = 4;
		_txtTimer.x = (FlxG.width - _txtTimer.width) / 2;
		_txtTimer.scrollFactor.x = _txtTimer.scrollFactor.y = 0;
		_grpUI.add(_txtTimer);
		
		_burstEmitter = new FlxEmitterExt();
		_burstEmitter.setRotation(0, 0);
		_burstEmitter.setMotion(0, 5,2, 360, 100, 4);
		_burstEmitter.makeParticles("images/particles.png", 200, 0, true, 0);
		_burstEmitter.blend = BlendMode.SCREEN;
        _grpParticles.add(_burstEmitter);
		
		var particles:Int = Std.int(FlxG.height/10);
		var particle:FlxParticle;
		var size:Int;
		var sizes:Array<Int> = [1,2,2,3,3,3,3,4,4,5];//[1, 1, 1, 1, 2, 2, 2, 4, 4, 6,8,10,12,14,16];
		var alphas:Array<Float> = [.04,.05,.06,.07,.1];
		var pBlend:BlendMode = BlendMode.LIGHTEN;
		var rate:Float = 0.05;
		var lspan:Int = 10;
		
		
		_p1Emit = new FlxEmitter( -10, -20, particles);
		_p1Emit.width = 10;
		_p1Emit.height = FlxG.height+40;
		_p1Emit.gravity = 0;
		_p1Emit.setXSpeed(20, 100);
		_p1Emit.setYSpeed(0, 0);
		_p1Emit.setRotation(0, 0);
		_p1Emit.blend = pBlend;
		_p1Emit.setAlpha(.02, .1, 0, 0);
		
		
		for (i in 0...particles)
		{
			size = FlxArrayUtil.getRandom(sizes);
			particle = new FlxParticle();
			particle.makeGraphic(size*16, size*16, FlxColorUtil.makeFromRGBA(30, 30, 255,1));// , FlxArrayUtil.getRandom(alphas)));
			
			
			//particle.blend = pBlend;
			particle.exists = false;
			
			_p1Emit.add(particle);
		}
		_p1Emit.start(false, lspan, rate);
		_grpPlayerEmits.add(_p1Emit);
		
		_p2Emit = new FlxEmitter( FlxG.width, -20, particles);
		_p2Emit.width = 10;
		_p2Emit.height = FlxG.height+40;
		_p2Emit.gravity = 0;
		_p2Emit.setXSpeed(-100, -20);
		_p2Emit.setYSpeed(0, 0);
		_p2Emit.setRotation(0, 0);
		_p2Emit.blend = pBlend;
		_p2Emit.setAlpha(.02, .1, 0, 0);
		
		for (i in 0...particles)
		{
			size = FlxArrayUtil.getRandom(sizes);
			particle = new FlxParticle();
			particle.makeGraphic(size*16, size*16, FlxColorUtil.makeFromRGBA(255, 30, 30,1));// , FlxArrayUtil.getRandom(alphas)));
			
			
			//particle.blend = pBlend;
			particle.exists = false;
			
			_p2Emit.add(particle);
		}
		_p2Emit.start(false, lspan, rate);
		var _grad:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xffccccff,0xff9966cc,0xff660066,0xff330033,0xff660066,0xffcc6699,0xffffcccc], 1, 0);
		_grpPlayerEmits.add(_p2Emit);
		add(_grad );
		add(_grpLightTrail);
		add(_background);
		
		//[0x99ccccff, 0x669999cc, 0x009999cc, 0x00000000, 0x00000000, 0x00000000, 0x00cc9999, 0x66cc9999, 0x99ffcccc]
		
		//_grad.blend = BlendMode.MULTIPLY;
		
		add(_grpPlayerEmits);
		add(_grpWalls);
		add(_grpEnemyTrail);
		add(_grpBallTrail);
		add(_grpPlayerTrail);
		add(_grpPlayers);
		add(_grpEnemies);
		add(_grpNodes);
		add(_grpFakeBalls);
		add(_grpBall);
		add(_grpParticles);
		add(_grpUI);
		add(_sprFade);
		
		_pauseScreen = new FlxGroup();
		add(_pauseScreen);
		
		_grpPause = new FlxGroup();
		
		
		var _pauseBack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		_pauseBack.alpha = .8;
		_pauseBack.blend = BlendMode.ADD;
		_pauseScreen.add(_pauseBack);
		
		_pauseScreen.add(_grpPause);
		
		var _pauseText = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_pauseText.setText("* * PAUSED * *", false, 8, 0, FlxBitmapFont.ALIGN_CENTER, false);
		_pauseText.x = (FlxG.width - _pauseText.width) / 2;
		_pauseText.y = (FlxG.height/2) - _pauseText.height - 8;
		_grpPause.add(_pauseText);
		
		var _resumeButton:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH)/2, (FlxG.height/2) + 8, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "RESUME", ResumeGame);
		_grpPause.add(_resumeButton);
		
		var _quitButton:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, (FlxG.height / 2) + 16 + Reg.BUTTON_HEIGHT, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "QUIT", QuitGame);
		_grpPause.add(_quitButton);
		
		
		_grpQuit = new FlxGroup();
		_pauseScreen.add(_grpQuit);
		
		var confirm:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		confirm.setText("Are you sure\nyou want to Quit?", true, 8, 0, FlxBitmapFont.ALIGN_CENTER, false);
		confirm.x = (FlxG.width - confirm.width) / 2;
		confirm.y = (FlxG.height / 2) - confirm.height - 8;
		_grpQuit.add(confirm);
		
		var quitYes:CustomButton  = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, (FlxG.height / 2) + 8, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "YES", YesQuit);
		_grpQuit.add(quitYes);
		
		var quitNo:CustomButton  = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, (FlxG.height / 2) + 16 + Reg.BUTTON_HEIGHT, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "NO", NoQuit);
		_grpQuit.add(quitNo);
		
		_grpQuit.visible = false;
		
		_pauseScreen.visible = false;
		
		_pauseScreen.setAll("alpha", 0.0001);
		
	
	
		
	}
	
	private function QuitGame():Void
	{
		if (!_paused || _grpQuit.visible) return;
		_grpPause.visible = false;
		_grpQuit.visible = true;
	}
	
	private function YesQuit():Void
	{
		if (!_grpQuit.visible || _state == STATE_LEVELEND) return;
		GameQuit();
	}
	
	private function NoQuit():Void
	{
		if (!_paused || !_grpQuit.visible) return;
		_grpPause.visible = true;
		_grpQuit.visible = false;
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
		
		
		_burstEmitter.start(true, 0, 0, 20,1);
		_burstEmitter.update();
	}
	
	private function LoadLevel():Void
	{
		//trace("data/room-" + Reg.levels[Reg.level] + ".tmx");
		var level:TiledLevel = new TiledLevel("data/room-" + Reg.levels[Reg.level] + ".tmx", "data/tiles.tanim");
		
		_grpWalls.add(level.wallTiles);
		
		_grpWalls.setAll("x", (FlxG.width - level.fullWidth) / 2);
		_grpWalls.setAll("y", (FlxG.height - level.fullHeight) / 2);
		
		_sprPlayer1.y = (FlxG.height - Reg.PLAYER_HEIGHT) / 2;
		_sprPlayer2.y = (FlxG.height - Reg.PLAYER_HEIGHT) / 2;
		
		if (_grpEnemies.members.length > 0)
			_grpEnemies.replace(_grpEnemies.members[0], level.enemies);
		else
		{
			_grpEnemies.add(level.enemies);
			for (e in level.enemies.members)
			{
				if (cast(e, Enemy).etype == 2)
					cast(e, Enemy).trail = AddTrail(cast(e, Enemy), _grpEnemyTrail);
			}
		}
		
		if (_grpNodes.members.length > 0)
			_grpNodes.replace(_grpNodes.members[0], level.objects);
		else
			_grpNodes.add(level.objects);
		
		_gameTimer = Reg.GAME_TIME;
		
	}
	
	private function ResetBall():Void
	{
		
		
		
		_ballLaunchDisplay.animation.frameIndex = 0;
		_ballLaunchDisplay.alpha = 1;
		_ballLaunchScale = 1;
		_ballLaunchDisplay.scale.set(_ballLaunchScale, _ballLaunchScale);
		_ballLaunchDisplay.visible = true;
		_ballLaunchTimer = 3;
		_ballLaunched = false;
		FlxG.sound.play(SoundAssets.SND_BOOOP);
		SnapBall();
		
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
		
		var p1Up:Bool = false;
		var p1Down:Bool = false;
		var p2Up:Bool = false;
		var p2Down:Bool = false;
		
		#if !FLX_NO_KEYBOARD
		if (FlxG.keyboard.anyPressed(Reg.P1_KEYS_UP))
		{
			p1Up = true;
		}
		else if (FlxG.keyboard.anyPressed(Reg.P1_KEYS_DOWN))
		{
			p1Down = true;	
		}
		#end
		
		#if !FLX_NO_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.inFlxRect(_p1TouchZone))
				{
					if (touch.y < _sprPlayer1.y + (Reg.PLAYER_HEIGHT / 2))
						p1Up = true;
					else if (touch.y > _sprPlayer1.y + (Reg.PLAYER_HEIGHT / 2))
						p1Down = true;
				}
			}
		}
		#end
		
		if (!(p1Up && p1Down))
		{
			if (p1Up)
				MovePaddle(_sprPlayer1, FlxObject.UP);
			else if (p1Down)
				MovePaddle(_sprPlayer1, FlxObject.DOWN);
		}
		
		if (Reg.numPlayers == 2)
		{
			#if !FLX_NO_KEYBOARD
			if (FlxG.keyboard.anyPressed(Reg.P2_KEYS_UP))
			{
				p2Up = true;
			}
			else if (FlxG.keyboard.anyPressed(Reg.P2_KEYS_DOWN))
			{
				p2Down = true;	
			}
			#end
			
			#if !FLX_NO_TOUCH
			for (touch in FlxG.touches.list)
			{
				if (touch.pressed)
				{
					if (touch.inFlxRect(_p2TouchZone))
					{
						if (touch.y < _sprPlayer2.y + (Reg.PLAYER_HEIGHT / 2))
							p2Up = true;
						else if (touch.y > _sprPlayer2.y + (Reg.PLAYER_HEIGHT / 2))
							p2Down = true;
					}
				}
			}
			#end
			
			if (!(p2Up && p2Down))
			{
				if (p2Up)
					MovePaddle(_sprPlayer2, FlxObject.UP);
				else if (p2Down)
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
		
		
	}
	
	
	private function updateBall():Void
	{
		
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
				_scores[2] += 50 * _multi[1];
				_multi[1] = 1;
			}
			else
			{
				_ballFollow = 2;
				_scores[1] += 50 * _multi[2];
				_multi[2] = 1;
			}
			ResetGamePlay();
			//ResetBall();
		}
		else
		{
			_gameTimer -= FlxG.elapsed;
			if (_gameTimer <= 0)
			{
				GameQuit();
				Reg.scores.push([_scores[1], _scores[2]]);
				_ball.velocity.x = _ball.velocity.y = 0;
			}
			else
			{
				if (_ball.velocity.x > -180 && _ball.velocity.x < 180)
					_ball.velocity.x = 180 * (_ball.velocity.x / Math.abs(_ball.velocity.x));
			}
			
		}
	}
	
	private function GameQuit():Void
	{
		_gameTimer = 0;
		_state = STATE_LEVELEND;
		_twn = FlxTween.multiVar(_sprFade, { alpha:1 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeOut } );
	}
	
	private function ResetGamePlay():Void
	{
		Reg.Freeze = true;
		_state = STATE_PREPLAY;
		GameStartTimer = 4;
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
				_ballLaunchScale = 1;
				_ballLaunchDisplay.alpha = 1;
				
			}
			else
			{
				_ballLaunchScale = _ballLaunchTimer; 
				_ballLaunchDisplay.alpha = _ballLaunchTimer;
			}
			_ballLaunchDisplay.scale.set(_ballLaunchScale, _ballLaunchScale);
			_ballLaunchDisplay.setPosition((FlxG.width - _ballLaunchDisplay.width) / 2, (FlxG.height - _ballLaunchDisplay.height) / 2);
		}
		else if (_ballLaunchDisplay.animation.frameIndex < 3)
		{
			if (_ballLaunchDisplay.animation.frameIndex < 2)
				FlxG.sound.play(SoundAssets.SND_BOOOP);
			else
				FlxG.sound.play(SoundAssets.SND_BOOOOP);
			_ballLaunchDisplay.animation.frameIndex++;
			_ballLaunchTimer = 3;
			_ballLaunchDisplay.alpha = 1;
			_ballLaunchScale = 1;
			_ballLaunchDisplay.scale.set(_ballLaunchScale, _ballLaunchScale);
			_ballLaunchDisplay.setPosition((FlxG.width - _ballLaunchDisplay.width) / 2, (FlxG.height - _ballLaunchDisplay.height) / 2);
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
			Reg.Freeze = false;
		}
	}
	
	private function BallHitNode(N:FlxObject, B:FlxObject):Void
	{
		if (cast(N, PointNode).owner != _lastHitBy)
		{
			cast(N, PointNode).owner = _lastHitBy;
			_scores[_lastHitBy] += 10 * _multi[_lastHitBy];
			_multi[_lastHitBy]++;
			if (_multi[_lastHitBy] > 9) _multi[_lastHitBy] = 9;
		}
		_ball.velocity.x *= 1.1;
		_ball.velocity.y *= 1.1;
		PlayPopSound();
		PlayHitSound();
		burst();
	}
	
	private function BallHitEnemy(E:FlxObject, B:FlxObject):Void
	{
		var enemyMid:Int = Std.int(E.y + (E.height / 2));
		var ballMid:Int = Std.int(B.y + (Reg.BALL_SIZE / 2));
		var diff:Int;
		var eType:Int = cast(E, Enemy).etype;
		PlayPopSound();
		PlayHitSound();
		burst();
		
		E.hurt(1);
		if (cast(E, Enemy).dying)
		{
			_scores[_lastHitBy] += cast(E, Enemy).score * _multi[_lastHitBy];
			_multi[_lastHitBy]++;
			if (_multi[_lastHitBy] > 9) _multi[_lastHitBy] = 9;
		}
		
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
			
			var fb:FakeBall;
			
			
			for (i in 0...FlxRandom.intRanged(2, 4))
			{			
				newAngle = FlxAngle.rotatePoint(B.velocity.x, B.velocity.y, 0, 0, FlxRandom.floatRanged( -180, 180));
				fb = cast _grpFakeBalls.recycle(FakeBall, [B.x, B.y, newAngle.x, newAngle.y]);
				//fb.revive();
				fb.reset(B.x, B.y);
				fb.alpha = .6;
				fb.trail = AddTrail(fb,_grpBallTrail);
				fb.grad = AddLightTrail(fb);
			
			}
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
		PlayPopSound();
		PlayHitSound();
		B.kill();
	}
	
	private function BallHitPlayer(P:FlxObject, B:FlxObject):Void
	{
		//PlayPopSound();
		PlayHitSound();
		if (P.x == _sprPlayer1.x)
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
			B.velocity.y = ( -4 * Math.abs(diff));
		}
		else if (ballMid > playerMid)
		{
			// ball hit the 'bottom' of the paddle
			diff = playerMid - ballMid;
			B.velocity.y = ( 4 * Math.abs(diff));
		}
		else
		{
			// ball hit right in the middle...
			// randomize!
			B.velocity.y = 2 + Std.int(Math.random() * 8);
		}
		burst();
	}
	
	private function PlayHitSound():Void
	{
		FlxG.sound.play(FlxArrayUtil.getRandom(SoundAssets.HIT_SOUNDS, 0, SoundAssets.HIT_SOUNDS.length), .66);
	}
	private function PlayPopSound():Void
	{
		FlxG.sound.play(FlxArrayUtil.getRandom(SoundAssets.POP_SOUNDS, 0, SoundAssets.POP_SOUNDS.length), .88);
	}
	
	private function BallHitWall(W:FlxObject, B:FlxObject):Void
	{
		PlayHitSound();
		burst();
	}
	
	private function FakeBallHitWall(W:FlxObject, B:FlxObject):Void
	{
		PlayHitSound();
		burst(B.x, B.y);
	}

	
	private function SetTimerText():Void
	{
		var wasTime:Int = Std.parseInt(_txtTimer.text);
		_txtTimer.text =  StringTools.lpad( Std.string(Math.ceil(_gameTimer) ), '0', 2) ;
		_txtTimer.x = (FlxG.width - _txtTimer.width) / 2;
		if (wasTime != Std.parseInt(_txtTimer.text))
		{
			for (i in 0...cast(_grpNodes.members[0], FlxGroup).length)
			{
				if (cast(_grpNodes.members[0], FlxGroup).members[i] != null)
				{
					if (cast(cast(_grpNodes.members[0], FlxGroup).members[i], PointNode).owner != 0)
						_scores[cast(cast(_grpNodes.members[0], FlxGroup).members[i], PointNode).owner] += 5 * _multi[cast(cast(_grpNodes.members[0], FlxGroup).members[i], PointNode).owner];
				}
			}
		}
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
		
		GamePlay();
		
		switch(_state)
		{
			case STATE_LOADING:
				
			case STATE_FADEIN:
				//if (_sprFade.alpha > 0)
				//	_sprFade.alpha -= FlxG.elapsed * 3;
				//else
				//	_state = STATE_PLAY;
			case STATE_PREPLAY:
				if (GameStartTimer > 0)
					GameStartTimer -= FlxG.elapsed * 3;
				else
				{
					ResetBall();
					_state = STATE_PLAY;
				}
			case STATE_PLAY:
				if (!_paused)
				{
					#if !FLX_NO_KEYBOARD
					if (FlxG.keyboard.anyJustReleased(["ESCAPE", "P"]))
						StartPause();
					#end
					#if android
					if (FlxG.android.justReleased("MENU"))
						StartPause();
					#end
					updateBall();
				}
			case STATE_LEVELEND:
				/*if (_sprFade.alpha < 1)
					_sprFade.alpha += FlxG.elapsed * 3;
				else
					FlxG.switchState(new ScoreBoardState());*/
		}
		
		if (_paused)
		{
			
			_pauseScreen.setAll("alpha", _pauseAlpha);
			cast(_pauseScreen.members[0],FlxSprite).alpha = .33 * _pauseAlpha;
		}
		SetScoreText();
		
		if (!_paused)
		{
			super.update();
		}
		else
		{
			_sprPlayer1.update();
			_sprPlayer2.update();
			_pauseScreen.update();
		}
		
		
		
		
		if (_sprPlayer1.y < _levelBounds.top) _sprPlayer1.y =  _levelBounds.top;
		else if (_sprPlayer1.y >  _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer1.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
		if (_sprPlayer2.y < 16) _sprPlayer2.y = _levelBounds.top;
		else if (_sprPlayer2.y > _levelBounds.bottom - Reg.PLAYER_HEIGHT) _sprPlayer2.y = _levelBounds.bottom - Reg.PLAYER_HEIGHT;
		
	}
	
	private function StartPause():Void
	{
		_paused = true;
		_pauseScreen.visible = true;
		justTriggered = false;
		#if !FLX_NO_MOUSE
		FlxG.mouse.show(Reg.CURSOR_NORMAL);
		#end
		_pauseTwn = FlxTween.multiVar(this, { _pauseAlpha:1 }, .33, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn } );
	}
	
	
	private function ResumeGame():Void
	{
		if (!_paused || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		FlxG.mouse.hide();
		#end
		_pauseTwn = FlxTween.multiVar(this, { _pauseAlpha:0.0001 }, .33, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete: DonePauseOut } );
		justTriggered = true;
	}
	
	private function DonePauseOut(T:FlxTween):Void
	{
		_pauseScreen.visible = false;
		_paused = false;
	}
	
	
	private function DoneFadeOut(T:FlxTween):Void
	{
		if (_paused)
			FlxG.switchState(new MenuState());
		else
			FlxG.switchState(new ScoreBoardState());
	}
	
	private function SetScoreText():Void
	{
		if (Std.string(_scores[1]) != _txtP1Score.text )
		{
			_txtP1Score.text = Std.string(Std.parseInt(_txtP1Score.text) + 1);
		}
		
		if (Std.string(_scores[2]) != _txtP2Score.text )
		{
			_txtP2Score.text = Std.string(Std.parseInt(_txtP2Score.text) + 1);
			_txtP2Score.x = _txtP2Multi.x - _txtP2Score.width;
		}
		_txtP1Multi.text = Std.string(_multi[1]) + "x";
		_txtP2Multi.text = "x" + Std.string(_multi[2]);
		//_txtP1Score.x = _txtP1Multi.x + _txtP1Multi.width;
		//_txtP2Multi.x = FlxG.width - _txtP2Multi.width - 4;
		

	}
	
	override public function draw():Void
	{
		super.draw();
		
	}
	
}