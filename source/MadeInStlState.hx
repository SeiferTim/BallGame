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
		
		
		_twn = FlxTween.multiVar(_img, { alpha:1 }, Reg.TweenTime, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeIn } );
		
		FlxG.sound.play(SoundAssets.MUS_MADEINSTL, 1, false, true, DonePause);
		
		super.create();
	}
	
	private function DoneFadeIn(T:FlxTween):Void
	{
		
		
		T = FlxTween.multiVar(_img, { alpha:1 }, 3, {type: FlxTween.ONESHOT, ease:FlxEase.quartIn } );
	}
	
	private function DonePause():Void
	{
		_twn = FlxTween.multiVar(_bright, { alpha:1 }, Reg.TweenTime, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeOut } );
	}
	
	private function DoneFadeOut(T:FlxTween):Void
	{
		FlxG.switchState(new MenuState());
	}
}