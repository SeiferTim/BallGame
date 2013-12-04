package ;

import flash.events.IOErrorEvent;
import flixel.addons.text.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class CreditsState extends FlxState
{

	private var _texts:Array<FlxSprite>;
	private var _btnBack:CustomButton;
	
	private var _state:Int;
	private var _loaded:Bool;
	private var alphaLevel:Float;
	
	private inline static var STATE_IN:Int = 0;
	private inline static var STATE_WAIT:Int = 1;
	private inline static var STATE_OUT:Int = 2;
	
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
		
		_texts = new Array<FlxSprite>();
		
		add(new FlxSprite(0, 0, "images/background.png"));
		
		_texts.push(cast add(new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95)));
		cast(_texts[0],FlxBitmapFont).setText("This Game was Made By:", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_texts[0].setPosition((FlxG.width - _texts[0].width) / 2, 32);
		_texts[0].alpha = 0;
		
		_texts.push(cast add(new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95)));
		cast(_texts[1],FlxBitmapFont).setText("Jevion White", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_texts[1].setPosition((FlxG.width - _texts[1].width) / 2, 80);
		_texts[1].alpha = 0;
		
		_texts.push(cast add(new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95)));
		cast(_texts[2],FlxBitmapFont).setText("Tim I Hely", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_texts[2].setPosition((FlxG.width - _texts[2].width) / 2, 112);
		_texts[2].alpha = 0;
		
		_texts.push(cast add(new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95)));
		cast(_texts[3],FlxBitmapFont).setText("Isaac Benrubi", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_texts[3].setPosition((FlxG.width - _texts[3].width) / 2, 144);
		_texts[3].alpha = 0;
		
		_texts.push(cast add(new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95)));
		cast(_texts[4],FlxBitmapFont).setText("Visit us on the Web at:", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_texts[4].setPosition((FlxG.width - _texts[4].width) / 2, 192);
		_texts[4].alpha = 0;
		
		_texts.push(cast add(new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95)));
		cast(_texts[5],FlxBitmapFont).setText("tileisle.net", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_texts[5].setPosition((FlxG.width - _texts[5].width) / 2, 224);
		_texts[5].alpha = 0;
	
		_btnBack = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH)/2, FlxG.height - Reg.BUTTON_HEIGHT - 32,Reg.BUTTON_WIDTH,Reg.BUTTON_HEIGHT, "Exit", ClickBack);//Plus(16, FlxG.height - 36, ClickQuit, null, "Exit", 100, 20);
		_btnBack.alpha = 0;
		//_btnBack.visible = false;
		add(_btnBack);
		_texts.push(_btnBack);
		
		super.create();
		_loaded = true;
	}
	
	override public function update():Void
	{
		if (_loaded && _state == STATE_IN)
		{
			if (_texts[_texts.length-1].alpha < 1)
			{
				alphaLevel += FlxG.elapsed * 3;
				
				for (i in 0..._texts.length)
				{
					_texts[i].alpha = alphaLevel - (i*.3);	
				}
				
				//_btnBack.alpha = alphaLevel - (_texts.length * .3);
			}
			else
			{
				alphaLevel = 1;
				_state = STATE_WAIT;
				_btnBack.visible = true;
			}
		}
		else if (_state == STATE_OUT)
		{
			if (_texts[_texts.length-1].alpha >0)
			{
				alphaLevel -= FlxG.elapsed * 3;
				
				for (i in 0..._texts.length)
				{
					_texts[i].alpha = alphaLevel + (i*.3);
				}
				
				//_btnBack.alpha = alphaLevel + (_texts.length * .3);
			}
			else
			{
				FlxG.switchState(new MenuState());
				
			}
		}
		
		super.update();
	}
	
	private function ClickBack():Void 
	{
		//trace(_state);
		if (_state == STATE_WAIT)
		_state = STATE_OUT;
		//_btnBack.visible = false;
	}
	
}