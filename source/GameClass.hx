package;

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.Lib;
import flixel.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;

	
class GameClass extends FlxGame
{	
	
	private var gameWidth:Int = 683;
	private var gameHeight:Int = 384;
	
	public function new()
	{
		Reg.instance = this;
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		var fps:Int = 120;
		
		x = (stageWidth - (gameWidth * ratio)) * .5;
		y = (stageHeight - (gameHeight * ratio)) * .5;
		
		#if debug
		super(gameWidth, gameHeight, MenuState, ratio, fps, 60);
		#end
		#if !debug
		super(gameWidth, gameHeight, MadeInStlState, ratio, fps, 60);
		#end
		
		Lib.current.stage.addEventListener(Event.RESIZE, window_resized);
		
	}
	
	public function toggle_fullscreen():Void
	{
		if (FlxG.stage.displayState != StageDisplayState.FULL_SCREEN)
			FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
		else
			FlxG.stage.displayState = StageDisplayState.NORMAL;
		 
		// The next function contains steps 2-4
		window_resized();
	}
	
	private function window_resized(?E:Event = null):Void
	{
		FitWindow();
	}
	
	public function set_screenmode(State:StageDisplayState):Void
	{
		FlxG.stage.displayState = State;
		window_resized();
	}
	
	public function FitWindow():Void 
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		x = (stageWidth - (gameWidth * ratio)) * .5;
		y = (stageHeight - (gameHeight * ratio)) * .5;
		
		FlxCamera.defaultZoom = ratio;
		FlxG.camera.zoom = ratio;
	}
	
	override public function update():Void 
	{
		super.update();
		#if !FLX_NO_KEYBOARD
		#if !web
		if (FlxG.keyboard.justReleased("ESCAPE"))
			toggle_fullscreen();
		#end
		#end
	}
	
	
}
