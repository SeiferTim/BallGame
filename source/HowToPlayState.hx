package ;

import flash.display.BlendMode;
import flixel.addons.text.FlxBitmapFont;
import flixel.addons.ui.FlxButtonPlus;
import flixel.effects.particles.FlxEmitterExt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class HowToPlayState extends FlxState
{

	private var _sprWhite:FlxSprite;
	private var _alphaLevel:Float = 0;
	private var _colliders:FlxGroup;
	
	private var _fakeBall:FlxSprite;
	private var _burstEmitter:FlxEmitterExt;
	
	private var _grpPage01:FlxGroup;
	private var _grpPage02:FlxGroup;
	
	private var _state:Int;
	private var _loaded:Bool;
	
	private var _groupOut:FlxGroup;
	private var _groupIn:FlxGroup;
	
	private inline static var STATE_IN:Int = 0;
	private inline static var STATE_WAIT:Int = 1;
	private inline static var STATE_OUT:Int = 2;
	private inline static var STATE_DONE:Int = 3;
	
	private var _twn:FlxTween;
	private var _switching:Bool;
	
	
	override public function create():Void 
	{
		FlxG.cameras.bgColor = 0xff330033;
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		_state = STATE_IN;
		_loaded = false;
		add(new FlxSprite(0, 0, "images/background.png"));
		
		_colliders = new FlxGroup(3);
		
		_grpPage01 = new FlxGroup();
		add(_grpPage01);
		
		_grpPage02 = new FlxGroup();
		add(_grpPage02);
		_grpPage02.active = false;
		_grpPage02.visible = false;
		
		_burstEmitter = new FlxEmitterExt();
		_burstEmitter.setRotation(0, 0);
		_burstEmitter.setMotion(0, 5,2, 360, 100, 4);
		_burstEmitter.makeParticles("images/particles.png", 200, 0, true, 0);
		_burstEmitter.blend = BlendMode.SCREEN;
		_grpPage01.add(_burstEmitter);
		
		var text001:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text001.setText("* * How to Play * *", false, 8, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text001.setPosition((FlxG.width - text001.width) / 2, 32);
		add(text001);
				
		var text002:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text002.setText("War is raging in Hyperspace!", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text002.setPosition((FlxG.width - text002.width) / 2, 80);
		_grpPage01.add(text002);
				
		var text003:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text003.setText("Fight for the      or     sides", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text003.setPosition((FlxG.width - text003.width) / 2, 112);
		_grpPage01.add(text003);
		
		var blue:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_BLUE,16,16, FlxBitmapFont.TEXT_SET1, 95);
		blue.setText("Blue", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		blue.setPosition(text003.x + (14*16), text003.y);
		_grpPage01.add(blue);
		
		var red:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_RED,16,16, FlxBitmapFont.TEXT_SET1, 95);
		red.setText("Red", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		red.setPosition(text003.x + (22*16), text003.y);
		_grpPage01.add(red);
		
		var text004:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text004.setText("with your hi-tech Ultra Paddle", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text004.setPosition((FlxG.width - text004.width) / 2, 128);
		_grpPage01.add(text004);
		
		var text005:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text005.setText("Harness the           for Power", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text005.setPosition((FlxG.width - text005.width) / 2, 160);
		_grpPage01.add(text005);
		
		var lightOrb:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_INVERT, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		lightOrb.setText("Light Orb", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		lightOrb.setPosition(text005.x + (12 * 16), text005.y);
		_grpPage01.add(lightOrb);
		
		var text006:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text006.setText("Reflect it - but don't drop it!", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text006.setPosition((FlxG.width - text006.width) / 2, 176);
		_grpPage01.add(text006);
		
		var fakeP1:FlxSprite = new FlxSprite(64, 224).loadGraphic("images/Left-Bumper-Ship-1.png", true, false, 18, 48);
		fakeP1.width = 15;
		fakeP1.offset.x = 2;
		fakeP1.animation.add("normal", [0, 1, 2, 1], 6);
		fakeP1.animation.play("normal");
		fakeP1.immovable = true;
		_grpPage01.add(fakeP1);
		
		var fakeP2:FlxSprite = new FlxSprite(FlxG.width - 64 - 15, 224).loadGraphic("images/Right-Bumper-Ship-1.png", true, false, 18, 48);
		fakeP2.width = 15;
		fakeP2.offset.x = 2;
		fakeP2.animation.add("normal", [0, 1, 2, 1], 6);
		fakeP2.animation.play("normal");
		fakeP2.immovable = true;
		_grpPage01.add(fakeP2);
		
		_fakeBall = new FlxSprite(fakeP1.x + fakeP1.width, fakeP1.y + ((fakeP1.height - Reg.BALL_SIZE) / 2)).loadGraphic("images/Ball.png", true, false, Reg.BALL_SIZE, Reg.BALL_SIZE);
		_fakeBall.elasticity = 1.025;
		_fakeBall.animation.add("neutral", [0, 1, 2, 1], 6);
		_fakeBall.animation.add("p1", [3, 4, 5, 4], 6);
		_fakeBall.animation.add("p2", [6, 7, 8, 7], 6);
		_fakeBall.animation.play("neutral");
		_fakeBall.maxVelocity.set(600, 0);
		_fakeBall.velocity.x = -200;
		_grpPage01.add(_fakeBall);
		
		_colliders.add(fakeP1);
		_colliders.add(fakeP2);
		
		var btnPage02:CustomButton = new CustomButton(FlxG.width - 16 - 48, FlxG.height - 16 - Reg.BUTTON_HEIGHT, 48, Reg.BUTTON_HEIGHT, ">", GoPage002);
		_grpPage01.add(btnPage02);
		
		
		
		
		
		
		
		
		var btnBack:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH)/2, FlxG.height - 16 - Reg.BUTTON_HEIGHT, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "Exit", GoBack);
		add(btnBack);
		
		
		_sprWhite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		_sprWhite.blend = BlendMode.ADD;
		add(_sprWhite);
		_grpPage01.active = false;
		StartFadeInTween();
		super.create();
	}
	
	private function StartFadeInTween():Void
	{
		if (_twn != null) _twn.cancel();
		_twn = FlxTween.multiVar(_sprWhite, { alpha: 0 }, .66, { type: FlxTween.ONESHOT, ease: FlxEase.quartIn, complete: FadeInDone } );
	}
	
	private function FadeInDone(T:FlxTween):Void
	{
		_loaded = true;
	}
	
	override public function update():Void 
	{
		switch (_state)
		{
			case STATE_IN:
				if (_loaded)
				{
					_state = STATE_WAIT;
					_grpPage01.active = true;
				}
			case STATE_WAIT:
				//if (_grpPage01.active)
					
			case STATE_OUT:
				_state = STATE_DONE;
				StartFadeOutTween();
			case STATE_DONE:
				
		}
		
		FlxG.collide(_colliders, _fakeBall, BallHitPaddle);
		
		super.update();
	}
	
	private function StartFadeOutTween():Void
	{
		_twn = FlxTween.multiVar(_sprWhite, { alpha: 1 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeOut } );
	}
	
	private function DoneFadeOut(T:FlxTween):Void
	{
		FlxG.switchState(new MenuState());
	}
	
	private function GoPage002():Void
	{
		if (_switching) return;
		SwitchStart(_grpPage01,_grpPage02);
	}
	
	private function SwitchStart(GroupOut:FlxGroup,GroupIn:FlxGroup):Void
	{
		_switching = true;
		_groupOut = GroupOut;
		_groupIn = GroupIn;
		_twn = FlxTween.multiVar(_sprWhite, { alpha: 1 }, .66, { type: FlxTween.ONESHOT, ease: FlxEase.quartIn, complete: SwitchMid } );
	}
	
	private function SwitchMid(T:FlxTween):Void
	{
		_groupOut.active = false;
		_groupOut.visible = false;
		_groupIn.active = true;
		_groupIn.visible = true;
		T = FlxTween.multiVar(_sprWhite, { alpha: 0 }, .66, { type: FlxTween.ONESHOT, ease: FlxEase.quartIn, complete: SwitchDone } );
	}
	
	private function SwitchDone(T:FlxTween):Void
	{
		_switching = false;
	}
	
	private function GoBack():Void
	{
		if (_switching) return;
		if (_state == STATE_WAIT)
		_state = STATE_OUT;
	}
	
	private function BallHitPaddle(S:FlxSprite, B:FlxSprite):Void
	{
		_burstEmitter.x = B.x + (Reg.BALL_SIZE/2);
		_burstEmitter.y = B.y + (Reg.BALL_SIZE / 2);
		_burstEmitter.start(true, 0, 0, 20,1);
		_burstEmitter.update();
		
		if (S.x < FlxG.width / 2) B.animation.play("p1");
		else B.animation.play("p2");
	}
	
}