package;

import flash.display.StageDisplayState;
import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxRandom;
import flixel.util.FlxSave;
import levels.TiledLevel;

/**
* Handy, pre-built Registry class that can be used to store 
* references to objects and other things for quick-access. Feel
* free to simply ignore it or change it in any way you like.
*/
class Reg
{
	static public var GameInitialized:Bool = false;
	
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	static public var levels:Array<Dynamic> = [];
	
	static public var levelList:Array<String> = [];
	
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	static public var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	static public var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	//static public var score:Int = 0;
	/**
	 * Generic bucket for storing different <code>FlxSaves</code>.
	 * Especially useful for setting up multiple save slots.
	 */
	//static public var saves:Array<FlxSave> = [];
	/**
	 * Generic container for a <code>FlxSave</code>. You might want to 
	 * consider assigning <code>FlxG._game._prefsSave</code> to this in
	 * your state if you want to use the same save flixel uses internally
	 */
	static public var save:FlxSave;
	
	static public inline var CURSOR_NORMAL:Int = 0;
	static public inline var CURSOR_OVER:Int = 1;
	
	static public inline var PLAYER_WIDTH:Int = 16;
	static public inline var PLAYER_HEIGHT:Int = 48;
	static public inline var PLAYER_SPEED:Int = 480;
	
	static public inline var BALL_SIZE:Int = 16;
	
	static public var numPlayers:Int;
	static public var numMatches:Int;
	static public var curMatch:Int;
	
	static public var P1_KEYS_UP:Array<String> = 				["W", "D"];
	static public var P1_KEYS_DOWN:Array<String> = 				["S", "A"];
	static public var P2_KEYS_UP:Array<String> = 				["UP", "RIGHT"];
	static public var P2_KEYS_DOWN:Array<String> = 				["DOWN", "LEFT"];
	
	static public inline var FONT_LIGHTGREY:String = 			"images/font_light_grey.png";
	static public inline var FONT_CYAN:String = 				"images/font_cyan.png";
	static public inline var FONT_VIOLET:String = 				"images/font_violet.png";
	static public inline var FONT_YELLOW:String = 				"images/font_yellow.png";
	static public inline var FONT_BLUE:String =	 				"images/font_blue.png";
	static public inline var FONT_GREEN:String = 				"images/font_green.png";
	static public inline var FONT_RED:String = 					"images/font_red.png";
	static public inline var FONT_TAN:String = 					"images/font_tan.png";
	static public inline var FONT_GOLD:String = 				"images/font_gold.png";
	static public inline var FONT_DARKGREY:String = 			"images/font_dark_grey.png";
	static public inline var FONT_DARKGREEN:String = 			"images/font_dark_green.png";
	static public inline var FONT_PEACH:String = 				"images/font_peach.png";
	static public inline var FONT_INVERT:String = 				"images/font_invert.png";
	static public inline var FONT_BRIGHTVIOLET:String = 		"images/font_bright_violet.png";
	
	static public inline var BUTTON_WIDTH:Int = 240;
	static public inline var BUTTON_HEIGHT:Int = 32;
	
	static public var instance:GameClass;
	
	static public inline var GAME_TIME:Int =  60; // TESTING = 10, LIVE = 90;
	static public var Freeze:Bool = true;
	
	
	static public inline var GameWidth:Int = 683;
	static public inline var GameHeight:Int = 384;
	
	static public var MouseOverButton:Bool;
	
	static private var CurMusic:String = "";
	
	static public function initGame():Void
	{
		if (GameInitialized) return;

		if (save.data.volume != null)
			FlxG.sound.volume = save.data.volume;
		else
			FlxG.sound.volume = 0.5;
		#if desktop
			if (save.data.fullscreen != null)
				instance.set_screenmode(save.data.fullscreen);
			else
				instance.set_screenmode(true);
		#end
		
		LoadLevels();
		
		GameInitialized = true;
	}
	
	static public function ShowMouse(Which:Int = 0):Void
	{
		var pointer:String = "";
		switch (Which)
		{
			case CURSOR_NORMAL:
				pointer = "images/cursor.png";
			case CURSOR_OVER:
				pointer = "images/pointer-over.png";
		}
		#if !FLX_NO_MOUSE
		FlxG.mouse.show(pointer, 1, -5, -6);
		#end
	}
	
	static public function LoadLevels():Void
	{
		levelList = new Array<String>();
		levelList.push("001");
		levelList.push("001");
	}
	
	static public function PickLevels(Rounds:Int):Void 
	{
		var tLevel:String;
		level = 0;
		for (i in 0...Rounds)
		{
			//trace(i);
			tLevel = FlxArrayUtil.getRandom(levelList);
			levels.push(tLevel);
			levelList.remove(tLevel);
		}
	}
	
	static public function PlayMusic(Music:String):Void	
	{
		if (CurMusic != Music)
		{
			CurMusic = Music;
			FlxG.sound.playMusic(CurMusic);
		}
		
	}
	
}