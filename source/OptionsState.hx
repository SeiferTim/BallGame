package ;
import flixel.addons.text.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxSlider;

class OptionsState extends FlxState
{
	private var _state:Int;
	private var _loaded:Bool;
	private var alphaLevel:Float;
	
	private inline static var STATE_IN:Int = 0;
	private inline static var STATE_WAIT:Int = 1;
	private inline static var STATE_OUT:Int = 2;
	
	private var _fadeObjs:Array<Array<Dynamic>>;
	
	
	
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
		
		_fadeObjs = new Array<Array<Dynamic>>();
		
		var text:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		text.setText("Options", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		text.setPosition((FlxG.width - text.width) / 2, 32);
		//text.alpha = 0;
		add(text);
		
		_fadeObjs.push([text]);
		
		var optText1:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		optText1.setText("Sound FX:", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT, true);
		optText1.setPosition(16, 80);
		//optText1.alpha = 0;
		add(optText1);
		
		var optSlide1:FlxSlider = new FlxSlider(FlxG.sound, "volume", 176,62, 0, 1, FlxG.width - 192, 16, 8, 0xff993399, 0xffaaffff);
		optSlide1.decimals = 1;
		optSlide1.setTexts("", false);
		
		//optSlide1.alpha = 0;
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
		
		var exitButton:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, FlxG.height - Reg.BUTTON_HEIGHT - 16, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "Back", ClickBack);
		//exitButton.alpha = 0;
		add(exitButton);
		
		_fadeObjs.push([exitButton]);
		
		
		super.create();
		_loaded = true;
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
			/*if (cast(_fadeObjs[_fadeObjs.length-1][0],FlxSprite).alpha < 1)
			{
				alphaLevel += FlxG.elapsed * 6;
				
				for (i in 0..._fadeObjs.length)
				{
					for (j in 0..._fadeObjs[i].length)
					{
						cast(_fadeObjs[i][j],FlxSprite).alpha = alphaLevel - (i*.3);
					}
				}
			}
			else
			{*/
				alphaLevel = 1;
				_state = STATE_WAIT;
				
			//}
		}
		else if (_state == STATE_OUT)
		{
			/*if (cast(_fadeObjs[_fadeObjs.length-1][0],FlxObject).alpha >0)
			{
				alphaLevel -= FlxG.elapsed * 6;
				
				for (i in 0..._fadeObjs.length)
				{
					for (j in 0..._fadeObjs[i].length)
					{
						cast(_fadeObjs[i][j],FlxObject).alpha = alphaLevel + (i*.3);
					}
				}
			}
			else
			{*/
				FlxG.switchState(new MenuState());
			//}
		}
		
		
		super.update();
	}
	
	
}