package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class MadeInStlState extends FlxState
{

	private var _img:FlxSprite;
	private var _twn:FlxTween;
	
	
	override public function create():Void 
	{
		super.create();
		
		_img = new FlxSprite(0, 0, "images/made_in_stl.png");
		_img.alpha = 0;
		add(_img);
		
		_twn = FlxTween.multiVar(_img, { alpha:1 }, .66, {type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeIn } );
		
	}
	
	private function DoneFadeIn(T:FlxTween):Void
	{
		T = FlxTween.multiVar(_img, { alpha:1 }, 2, {type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DonePause } );
	}
	
	private function DonePause(T:FlxTween):Void
	{
		T = FlxTween.multiVar(_img, { alpha:0 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeOut } );
	}
	
	private function DoneFadeOut(T:FlxTween):Void
	{
		FlxG.switchState(new MenuState());
	}
}