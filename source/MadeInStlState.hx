package ;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class MadeInStlState extends FlxState
{

	private var _img:FlxSprite;
	private var _twn:FlxTween;
	private var _bright:FlxSprite;
	private var _sndAwesome:FlxSound; 
	
	override public function create():Void 
	{
		
		//Reg.initGame();
		
		_img = new FlxSprite(0, 0, "images/made_in_stl.png");
		_img.alpha = 0;
		add(_img);
		
		_bright = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		_bright.alpha = 0;
		_bright.blend = BlendMode.ADD;
		add(_bright);
		
		
		_twn = FlxTween.multiVar(_img, { alpha:1 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeIn } );
		
		
		
		super.create();
	}
	
	private function DoneFadeIn(T:FlxTween):Void
	{
		FlxG.sound.play(SoundAssets.SND_MADEINSTL);
		T = FlxTween.multiVar(_img, { alpha:1 }, 2, {type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DonePause } );
	}
	
	private function DonePause(T:FlxTween):Void
	{
		T = FlxTween.multiVar(_bright, { alpha:1 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeOut } );
	}
	
	private function DoneFadeOut(T:FlxTween):Void
	{
		FlxG.switchState(new MenuState());
	}
}