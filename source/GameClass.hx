package;

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.Lib;
import flixel.*;

	
class GameClass extends FlxGame
{	
	
	private var gameWidth:Int = 683;
	private var gameHeight:Int = 384;
	
	public function new()
	{
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		
		var fps:Int = 60;
		
		x = (stageWidth - (gameWidth * ratio)) * .5;
		y = (stageHeight - (gameHeight * ratio)) * .5;
		
		super(gameWidth, gameHeight, MenuState, ratio, fps, fps);
		
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
		
		//if (FlxG.keyboard.justReleased("ESCAPE"))
		//	toggle_fullscreen();
	}
	
	
}
