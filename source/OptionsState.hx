package ;
import flash.display.StageDisplayState;
import flixel.addons.text.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxSlider;
import flixel.util.FlxGradient;
import flixel.util.FlxSpriteUtil;

class OptionsState extends FlxState
{
	private var _state:Int;
	private var _loaded:Bool;
	private var alphaLevel:Float;
	
	private inline static var STATE_IN:Int = 0;
	private inline static var STATE_WAIT:Int = 1;
	private inline static var STATE_OUT:Int = 2;
	
	private var _fadeObjs:Array<Array<FlxSprite>>;
	
	private var _exitButton:CustomButton;
	private var _optButton2:CustomButton;
	
	override public function create():Void 
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff330033;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		_loaded = false;
		_state = STATE_IN;
		alphaLevel = 0;
		
		add(new FlxSprite(0, 0, "images/background.png"));
		
		_fadeObjs = new Array<Array<FlxSprite>>();
		
		var text:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text.setText("Options", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text.setPosition((FlxG.width - text.width) / 2, 48);
		text.alpha = 0;
		add(text);
		
		_fadeObjs.push([text]);
		
		var optText1:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		optText1.setText("Sound FX:", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT, true);
		optText1.setPosition(32, 80);
		optText1.alpha = 0;
		add(optText1);
		
		var optSlide1:CustomSlider = new CustomSlider(Std.int(optText1.x + optText1.width + 16),Std.int(optText1.y), Std.int(FlxG.width - optText1.width - 80),64,16,14,0,1,SlideChange);
		optSlide1.decimals = 1;
		optSlide1.value = FlxG.sound.volume;
		
		var newBar:FlxSprite = new FlxSprite();
		var newBarBorder:FlxSprite = new FlxSprite();
		var tmpMask:FlxSprite;
		tmpMask = new FlxSprite().makeGraphic(Std.int(optSlide1.bar.width), Std.int(optSlide1.bar.height), 0x0,true);
		FlxSpriteUtil.drawRoundRect(tmpMask, 0,0,optSlide1.bar.width,optSlide1.bar.height, 8, 8, 0xff000000);
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Std.int(optSlide1.bar.width), Std.int(optSlide1.bar.height), [0xff7d7d7d, 0xff0e0e0e]), tmpMask, newBarBorder);		
		
		tmpMask = new FlxSprite().makeGraphic(Std.int(optSlide1.bar.width), Std.int(optSlide1.bar.height), 0x0,true);
		FlxSpriteUtil.drawRoundRect(tmpMask, 1,1,optSlide1.bar.width-2,optSlide1.bar.height-2, 8, 8, 0xff000000);
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Std.int(optSlide1.bar.width), Std.int(optSlide1.bar.height), [0xff111111, 0xff333333,0xff333333,0xff333333, 0xff666666]), tmpMask, newBar);
		
		newBarBorder.stamp(newBar, 0, 0);
		
		optSlide1.replaceBarSprite(newBarBorder);
		
		var newHandle:FlxSprite = new FlxSprite();
		var newHandleBorder:FlxSprite = new FlxSprite().makeGraphic(Std.int(optSlide1.handle.width), Std.int(optSlide1.handle.height), 0x0);
		tmpMask = new FlxSprite().makeGraphic(Std.int(optSlide1.handle.width), Std.int(optSlide1.handle.height), 0x0, true);
		FlxSpriteUtil.drawRoundRect(tmpMask, 0,0,optSlide1.handle.width,optSlide1.handle.height, 8, 8, 0xff000000);
		FlxSpriteUtil.drawRoundRect(tmpMask, 0,0,optSlide1.handle.width,optSlide1.handle.height, 8, 8, 0xff000000);
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Std.int(optSlide1.handle.width), Std.int(optSlide1.handle.height), [0xffd0e4f7, 0xff73b1e7, 0xff0a77d5, 0xff539fe1, 0xff87bcea]), tmpMask, newHandleBorder);		
		
		tmpMask = new FlxSprite().makeGraphic(Std.int(optSlide1.handle.width), Std.int(optSlide1.handle.height), 0x0, true);
		FlxSpriteUtil.drawRoundRect(tmpMask, 1,1,optSlide1.handle.width-2,optSlide1.handle.height-2, 8, 8, 0xff000000);
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Std.int(optSlide1.handle.width), Std.int(optSlide1.handle.height), [0xffb3dced,0xff29b8e5,0xffbce0ee]), tmpMask, newHandle);
		
		newHandleBorder.stamp(newHandle, 0, 0);
		
		optSlide1.replaceHandleSprite(newHandleBorder);
		optSlide1.alpha = 0;
		
		add(optSlide1);
		
		_fadeObjs.push([optText1, optSlide1]);
		
		/*
		var optText2:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		optText2.setText("Music:", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT, true);
		optText2.setPosition(16, 128);
		//optText1.alpha = 0;
		add(optText2);
		
		var optSlide2:FlxSlider = new FlxSlider(FlxG.sound.music, "volume", 176,110, 0, 1, FlxG.width - 192, 16, 8, 0xff993399, 0xffaaffff);
		optSlide2.decimals = 1;
		optSlide2.setTexts("", false);
		
		//optSlide1.alpha = 0;
		add(optSlide2);
		
		_fadeObjs.push([optText2, optSlide2]);
		*/
		
		
		#if desktop
		
		var optText2:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		optText2.setText("Screen:", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT, true);
		optText2.setFixedWidth(144, FlxBitmapFont.ALIGN_RIGHT);
		optText2.setPosition(32, 112);
		optText2.alpha = 0;
		add(optText2);
		
		_optButton2 = new CustomButton((optText2.x + optText2.width + 16) + ((FlxG.width - optText2.x - optText2.width - 48 - Reg.BUTTON_WIDTH) / 2), 112, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, FlxG.stage.displayState == StageDisplayState.FULL_SCREEN ? "Fullscreen" : "Window", ChangeScreen);
		_optButton2.alpha = 0;
		add(_optButton2);
		
		_fadeObjs.push([optText2, _optButton2]);
		
		#end
		
		_exitButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, FlxG.height - Reg.BUTTON_HEIGHT - 32, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "Back", ClickBack);
		_exitButton.alpha = 0;
		add(_exitButton);
		
		_fadeObjs.push([_exitButton]);
		
		
		super.create();
		_loaded = true;
	}
	
	private function ChangeScreen():Void
	{
		Reg.instance.toggle_fullscreen();
		if (FlxG.stage.displayState == StageDisplayState.FULL_SCREEN)
			_optButton2.text = "Fullscreen";
		else
			_optButton2.text = "Window";
		Reg.save.data.screenstate = FlxG.stage.displayState;
		Reg.save.flush();
	}
	
	private function SlideChange(Value:Float):Void
	{
		FlxG.sound.volume = Value;
		Reg.save.data.volume = FlxG.sound.volume;
		Reg.save.flush();
	}
	
	private function ClickBack():Void
	{
		if (_state == STATE_WAIT)
		_state = STATE_OUT;
	}
	
	override public function update():Void
	{
		if (_loaded && _state == STATE_IN)
		{
			if (_fadeObjs[_fadeObjs.length-1][0].alpha < 1)
			{
				alphaLevel += FlxG.elapsed * 6;
				
				for (i in 0..._fadeObjs.length)
				{
					for (j in 0..._fadeObjs[i].length)
					{
						_fadeObjs[i][j].alpha = alphaLevel - (i*.3);
					}
				}
				
				//_exitButton.alpha = alphaLevel - (_fadeObjs.length * .3);
			}
			else
			{
				alphaLevel = 1;
				_state = STATE_WAIT;
				
			}
		}
		else if (_state == STATE_OUT)
		{
			if (_fadeObjs[_fadeObjs.length-1][0].alpha >0)
			{
				alphaLevel -= FlxG.elapsed * 6;
				
				for (i in 0..._fadeObjs.length)
				{
					for (j in 0..._fadeObjs[i].length)
					{
						_fadeObjs[i][j].alpha = alphaLevel + (i*.3);
					}
				}
				
				//_exitButton.alpha = alphaLevel + (_fadeObjs.length * .3);
			}
			else
			{
				FlxG.switchState(new MenuState());
			}
		}
		
		
		super.update();
	}
	
	
}