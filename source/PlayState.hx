package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _background:FlxSprite;
	private var _sprPlayer1:FlxSprite;
	private var _sprPlayer2:FlxSprite;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		_background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xff666666);
		_background.scrollFactor.x = _background.scrollFactor.y = 0;
		add(_background);
		
		_sprPlayer1 = new FlxSprite(16, 16).makeGraphic(16, 32, 0xff0000ff);
		_sprPlayer2 = new FlxSprite(FlxG.width - 32, 16).makeGraphic(16, 32, 0xff00ff00);
		
		add(_sprPlayer1);
		add(_sprPlayer2);
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		
		_sprPlayer1.velocity.y = 0;
		_sprPlayer2.velocity.y = 0;
		
		if (FlxG.keyboard.anyPressed(["W", "A"]))
		{
			_sprPlayer1.velocity.y = -320;
		}
		else if (FlxG.keyboard.anyPressed(["S", "D"]))
		{
			_sprPlayer1.velocity.y = 320;
		}
		
		if (FlxG.keyboard.anyPressed(["UP", "LEFT"]))
		{
			_sprPlayer2.velocity.y = -320;
		}
		else if (FlxG.keyboard.anyPressed(["DOWN", "RIGHT"]))
		{
			_sprPlayer2.velocity.y = 320;
		}
		
		super.update();
		
		if (_sprPlayer1.y < 16) _sprPlayer1.y = 16;
		else if (_sprPlayer1.y > FlxG.height - 48) _sprPlayer1.y = FlxG.height - 48;
		
		if (_sprPlayer2.y < 16) _sprPlayer2.y = 16;
		else if (_sprPlayer2.y > FlxG.height - 48) _sprPlayer2.y = FlxG.height - 48;
		
	}	
}