package ;

import flash.display.BlendMode;
import flixel.addons.text.FlxBitmapFont;
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
	#if !FLX_NO_KEYBOARD
	private var _grpPage03:FlxGroup;
	#end
	
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
	private var _curMulti:Int = 1;
	private var _multiTimer:Float;
	private var _txtMulti:FlxBitmapFont;
	
	
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
		
		#if !FLX_NO_KEYBOARD
		_grpPage03 = new FlxGroup();
		add(_grpPage03);
		_grpPage03.active = false;
		_grpPage03.visible = false;
		#end
		
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
				
		var text002:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_RED, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text002.setText("War is raging in Hyperspace!", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text002.setPosition((FlxG.width - text002.width) / 2, 80);
		_grpPage01.add(text002);
		
		var text002b:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text002b.setText("Gain the most       in    seconds", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text002b.setPosition((FlxG.width - text002b.width) / 2, 112);
		_grpPage01.add(text002b);
		
		var text002c:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text002c.setText("Power", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text002c.setPosition(text002b.x + 224, text002b.y);
		_grpPage01.add(text002c);
		
		var text002d:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text002d.setText("60", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text002d.setPosition(text002b.x + 368, text002b.y);
		_grpPage01.add(text002d);
		
				
		var text003:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text003.setText("Fight for the      or     sides", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text003.setPosition((FlxG.width - text003.width) / 2, 144);
		_grpPage01.add(text003);
		
		var blue:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_BLUE,16,16, FlxBitmapFont.TEXT_SET1, 95);
		blue.setText("Blue", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		blue.setPosition(text003.x + (14*16), text003.y);
		_grpPage01.add(blue);
		
		var red:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_RED,16,16, FlxBitmapFont.TEXT_SET1, 95);
		red.setText("Red", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		red.setPosition(text003.x + (22*16), text003.y);
		_grpPage01.add(red);
		
		var text004:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text004.setText("with your hi-tech             ", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text004.setPosition((FlxG.width - text004.width) / 2, 160);
		_grpPage01.add(text004);
		
		var text004b:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text004b.setText("Ultra Paddle", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text004b.setPosition(text004.x + 288, text004.y);
		_grpPage01.add(text004b);
		
		
		var text005:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text005.setText("Harness the           for Power", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text005.setPosition((FlxG.width - text005.width) / 2, 192);
		_grpPage01.add(text005);
		
		var lightOrb:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		lightOrb.setText("Light Orb", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		lightOrb.setPosition(text005.x + (12 * 16), text005.y);
		_grpPage01.add(lightOrb);
		
		var text006:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text006.setText("Reflect it - but don't miss it!", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text006.setPosition((FlxG.width - text006.width) / 2, 240);
		_grpPage01.add(text006);
		
		var fakeP1:FlxSprite = new FlxSprite(64, 256).loadGraphic("images/Left-Bumper-Ship-1.png", true, false, 18, 48);
		fakeP1.width = 15;
		fakeP1.offset.x = 2;
		fakeP1.animation.add("normal", [0, 1, 2, 1], 6);
		fakeP1.animation.play("normal");
		fakeP1.immovable = true;
		_grpPage01.add(fakeP1);
		
		var fakeP2:FlxSprite = new FlxSprite(FlxG.width - 64 - 15, 256).loadGraphic("images/Right-Bumper-Ship-1.png", true, false, 18, 48);
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
		
		var text007:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text007.setText("When the     is your color,\nsmash things to gain      !", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text007.setPosition((FlxG.width - text007.width) / 2, 80);
		_grpPage02.add(text007);
		
		var txtOrb:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		txtOrb.setText("Orb", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		txtOrb.setPosition(text007.x + 144, 80);
		_grpPage02.add(txtOrb);
		
		var txtPower:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		txtPower.setText("Power", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		txtPower.setPosition(text007.x + 336, 96);
		_grpPage02.add(txtPower);
		
		var e1:Enemy = new Enemy(48, 144, 4);
		_grpPage02.add(e1);
		
		var text009:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_LIGHTGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text009.setText("=", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text009.setPosition(80,144);
		_grpPage02.add(text009);
		
		var text010:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text010.setText("10", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text010.setPosition(96,144);
		_grpPage02.add(text010);
		
		
		
		var e2:Enemy = new Enemy(160, 144, 0);
		_grpPage02.add(e2);
		
		var text011:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_LIGHTGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text011.setText("=", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text011.setPosition(192,144);
		_grpPage02.add(text011);
		
		var text012:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text012.setText("15", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text012.setPosition(208,144);
		_grpPage02.add(text012);
		
		
		var eN:PointNode = new PointNode(268, 140);
		
		
		var text012b:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_LIGHTGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text012b.setText("=", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text012b.setPosition(304,144);
		_grpPage02.add(text012b);
		
		var text012c:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text012c.setText("10", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text012c.setPosition(320,144);
		_grpPage02.add(text012c);
		
		var text012d:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text012d.setText("+5/sec", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text012d.setPosition(268,160);
		_grpPage02.add(text012d);
		
		eN.animation.add("playing", [0, 1, 2],1);
		eN.animation.play("playing");
		_grpPage02.add(eN);
		
		var e3:Enemy = new Enemy(FlxG.width - 304, 144, 2);
		_grpPage02.add(e3);
		
		var text013:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_LIGHTGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text013.setText("=", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text013.setPosition(FlxG.width - 240,144);
		_grpPage02.add(text013);
		
		var text014:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text014.setText("25", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text014.setPosition(FlxG.width - 224,144);
		_grpPage02.add(text014);
		
		var e4:Enemy = new Enemy(FlxG.width - 160, 136, 3);
		_grpPage02.add(e4);
		
		var text015:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_LIGHTGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text015.setText("=", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text015.setPosition(FlxG.width - 112,144);
		_grpPage02.add(text015);
		
		var text016:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text016.setText("30", false, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text016.setPosition(FlxG.width - 96,144);
		_grpPage02.add(text016);
		
		var text017:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text017.setText("Each      increases your\n           by 1 (Max = 9)", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text017.setPosition((FlxG.width - text017.width)/2,192);
		_grpPage02.add(text017);
		
		var text017b:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text017b.setText("kill", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text017b.setPosition(text017.x + 80,text017.y);
		_grpPage02.add(text017b);
		
		var text017c:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text017c.setText("Multiplier", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text017c.setPosition(text017.x, text017.y + 16);
		_grpPage02.add(text017c);
		
		_txtMulti = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtMulti.setText("1x", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		_txtMulti.setPosition(((FlxG.width-96)/2),240);
		_grpPage02.add(_txtMulti);

		var score:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_BLUE, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		score.setText("1000", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		score.setPosition(_txtMulti.x+_txtMulti.width,240);
		_grpPage02.add(score);
		
		var text018:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text018.setText("...but miss & your      \ngets                 x 50!", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text018.setPosition((FlxG.width - text018.width)/2,272);
		_grpPage02.add(text018);
		
		var text018b:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text018b.setText("Rival", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text018b.setPosition(text018.x + 304, text018.y);
		_grpPage02.add(text018b);
		
		var text018c:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text018c.setText("YOUR Multiplier", true, 0, 0, FlxBitmapFont.ALIGN_LEFT, true);
		text018c.setPosition(text018.x + 80, text018.y+16);
		_grpPage02.add(text018c);
		
		var btnPage01:CustomButton = new CustomButton(16, FlxG.height - 16 - Reg.BUTTON_HEIGHT, 48, Reg.BUTTON_HEIGHT, "<", GoPage001);
		_grpPage02.add(btnPage01);
		
		#if !FLX_NO_KEYBOARD
		
		var text019:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text019.setText("Controls", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text019.setPosition((FlxG.width - text019.width)/2,96);
		_grpPage03.add(text019);
		
		
		var text020:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text020.setText("Player 1", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text020.setPosition(((FlxG.width / 2) - text020.width) / 2, 128);
		_grpPage03.add(text020);
		
		var text021:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text021.setText("Player 2", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text021.setPosition((FlxG.width / 2) + (((FlxG.width / 2) - text020.width) / 2), 128);
		_grpPage03.add(text021);
		
		var text022:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text022.setText("W & S", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text022.setPosition(((FlxG.width / 2) - text022.width) / 2, 160);
		_grpPage03.add(text022);
		
		var text023:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text023.setText("UP & DOWN", true, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text023.setPosition((FlxG.width / 2) + (((FlxG.width / 2) - text023.width) / 2), 160);
		_grpPage03.add(text023);
		
		var text024:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text024.setText("    = Pause\n  = Toggle Fullscreen\n    = Adjust Volume\n  = Mute/Unmute", true, 0, 16, FlxBitmapFont.ALIGN_CENTER, true);
		text024.setPosition((FlxG.width - text024.width)/2,208);
		_grpPage03.add(text024);
		
		var text024b:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_GOLD, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text024b.setText("ESC        \nF                    \n+/-                \n0              ", true, 0, 16, FlxBitmapFont.ALIGN_CENTER, true);
		text024b.setPosition((FlxG.width - text024b.width)/2,208);
		_grpPage03.add(text024b);
		
		var btnPageBack02:CustomButton =  new CustomButton(16, FlxG.height - 16 - Reg.BUTTON_HEIGHT, 48, Reg.BUTTON_HEIGHT, "<", GoBackPage002);
		_grpPage03.add(btnPageBack02);
		
		var btnPage03:CustomButton = new CustomButton(FlxG.width - 16 - 48, FlxG.height - 16 - Reg.BUTTON_HEIGHT, 48, Reg.BUTTON_HEIGHT, ">", GoPage003);
		_grpPage02.add(btnPage03);
		
		#end
		
		var btnBack:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH)/2, FlxG.height - 16 - Reg.BUTTON_HEIGHT, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "Exit", GoBack);
		add(btnBack);
		
		
		_sprWhite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		_sprWhite.blend = BlendMode.ADD;
		add(_sprWhite);
		_grpPage01.active = false;
		_multiTimer = 2;
		
		StartFadeInTween();
		super.create();
	}
	
	private function StartFadeInTween():Void
	{
		if (_twn != null) _twn.cancel();
		_twn = FlxTween.multiVar(_sprWhite, { alpha: 0 }, Reg.TweenTime, { type: FlxTween.ONESHOT, ease: FlxEase.quartIn, complete: FadeInDone } );
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
				if (_grpPage02.active)
				{
					if (_multiTimer <= 0)
					{
						_multiTimer = 2;
						_curMulti++;
						if (_curMulti > 9) _curMulti = 1;
						_txtMulti.text = Std.string(_curMulti) + "x";
					}
					else
						_multiTimer -= FlxG.elapsed * 6;
				}
			case STATE_OUT:
				_state = STATE_DONE;
				Reg.Freeze = true;
				StartFadeOutTween();
			case STATE_DONE:
				
		}
		
		FlxG.collide(_colliders, _fakeBall, BallHitPaddle);
		
		super.update();
	}
	
	private function StartFadeOutTween():Void
	{
		_twn = FlxTween.multiVar(_sprWhite, { alpha: 1 }, Reg.TweenTime, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeOut } );
	}
	
	private function DoneFadeOut(T:FlxTween):Void
	{
		FlxG.switchState(new MenuState());
	}
	
	private function GoPage002():Void
	{
		if (_switching) return;
		Reg.Freeze = false;
		SwitchStart(_grpPage01,_grpPage02);
	}
	
	private function GoPage001():Void
	{
		if (_switching) return;
		Reg.Freeze = true;
		SwitchStart(_grpPage02, _grpPage01);
	}
	
	#if !FLX_NO_KEYBOARD
	private function GoPage003():Void
	{
		if (_switching) return;
		Reg.Freeze = true;
		SwitchStart(_grpPage02, _grpPage03);
	}
	
	private function GoBackPage002():Void
	{
		if (_switching) return;
		Reg.Freeze = false;
		SwitchStart(_grpPage03,_grpPage02);
	}
	#end
	
	private function SwitchStart(GroupOut:FlxGroup,GroupIn:FlxGroup):Void
	{
		_switching = true;
		_groupOut = GroupOut;
		_groupIn = GroupIn;
		_twn = FlxTween.multiVar(_sprWhite, { alpha: 1 }, Reg.TweenTime, { type: FlxTween.ONESHOT, ease: FlxEase.quartIn, complete: SwitchMid } );
	}
	
	private function SwitchMid(T:FlxTween):Void
	{
		_groupOut.active = false;
		_groupOut.visible = false;
		_groupIn.active = true;
		_groupIn.visible = true;
		T = FlxTween.multiVar(_sprWhite, { alpha: 0 }, Reg.TweenTime, { type: FlxTween.ONESHOT, ease: FlxEase.quartIn, complete: SwitchDone } );
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