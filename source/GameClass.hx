package;

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.Lib;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
	
class GameClass extends FlxGame
{
	
	private var gameWidth:Int;
	private var gameHeight:Int;
	
	public function new()
	{
		Reg.save = new FlxSave();
		Reg.save.bind("Options");
		gameWidth = Reg.GameWidth;
		gameHeight = Reg.GameHeight;
		
		Reg.instance = this;
	
		var fps:Int = 120;
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		#if debug
		super(gameWidth, gameHeight, MenuState, ratio, fps, 60);
		#end
		#if !debug
		super(gameWidth, gameHeight, MadeInStlState, ratio, fps, 60);
		#end
		
		Lib.current.stage.addEventListener(Event.RESIZE, window_resized);
		
		#if android
		FlxG.android.preventDefaultBackAction = true;
		#end
		SoundAssets.cacheSounds();
	}

	public function setScreenSize(Size:Int):Void
	{
		
	}
	
	public function toggle_fullscreen():Void
	{
		FlxG.fullscreen = !FlxG.fullscreen;
		window_resized();
	}
	
	private function window_resized(?E:Event = null):Void
	{
		FitWindow();
	}
	
	public function set_screenmode(Fullscreen:Bool):Void
	{
		FlxG.fullscreen = Fullscreen;
		window_resized();
	}
	
	public function FitWindow():Void
	{
		
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		//FlxG.resizeGame(stageWidth, stageHeight);
		
		x = (stageWidth - (gameWidth * ratio)) * .5;
		y = (stageHeight - (gameHeight * ratio)) * .5;
		
		FlxCamera.defaultZoom = ratio;
		
		if (FlxG.camera != null)
		FlxG.camera.zoom = ratio;
		
		
	}
		
	
	override public function update():Void
	{
		super.update();
		#if !FLX_NO_KEYBOARD
		#if !web
		if (FlxG.keyboard.justReleased("F"))
			toggle_fullscreen();
		#end
		#end
		
	}
	
	
}
