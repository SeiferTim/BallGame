package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	
	
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
		
		var p1:FlxButton = new FlxButton(0, 0, "1 Player", Start1Player);
		p1.x = (FlxG.width - p1.width) / 2;
		p1.y = (FlxG.height / 2) - p1.height - 4;
		add(p1);
		
		var p2:FlxButton = new FlxButton(0, 0, "2 Players", Start2Player);
		p2.x = (FlxG.width - p2.width) / 2;
		p2.y = (FlxG.height / 2 ) + 4;
		add(p2);
		
		super.create();
	}
	
	private function Start1Player():Void
	{
		Reg.numPlayers = 1;
		FlxG.switchState(new PlayState());
	}
	
	private function Start2Player():Void
	{
		Reg.numPlayers = 2;
		FlxG.switchState(new PlayState());
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
		
		
		super.update();
	}	
}