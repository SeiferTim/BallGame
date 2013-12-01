package;

import flash.display.BlendMode;
import flixel.addons.text.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	
	private var _grpMain:FlxGroup;
	private var _grpMenuChoices:FlxGroup;
	private var _grpPlayChoices:FlxGroup;
	private var _grpMatchesChoices:FlxGroup;
	
	private var _state:Int;
	
	private inline static var STATE_UNLOADED:Int = 0;
	private inline static var STATE_MAIN:Int = 1;
	private inline static var STATE_MENU:Int = 2;
	private inline static var STATE_PLAY:Int = 3;
	private inline static var STATE_MATCH:Int = 4;
	private inline static var STATE_UNLOADING:Int = 5;
	private var justTriggered:Bool;
	
	private var txtClickToPlay:FlxBitmapFont;
	
	private var _sprBlack:FlxSprite;
	private var _goingToCredits:Bool;
	private var _goingToOptions:Bool;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff330033;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		Reg.instance.FitWindow();
		
		_state = STATE_UNLOADED;
		
		
		
		_grpMain = new FlxGroup();
		_grpMenuChoices = new FlxGroup();
		_grpPlayChoices = new FlxGroup();
		_grpMatchesChoices = new FlxGroup();
		
		add(_grpMain);
		add(_grpMenuChoices);
		add(_grpPlayChoices);
		add(_grpMatchesChoices);
		
		_grpMain.visible = true;
		_grpMenuChoices.visible = false;
		_grpPlayChoices.visible = false;
		_grpMatchesChoices.visible = false;
		
		txtClickToPlay = new FlxBitmapFont(Reg.FONT_LIGHTGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		txtClickToPlay.setText("Click to Play", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		txtClickToPlay.y = 16;
		txtClickToPlay.x = (FlxG.width - txtClickToPlay.width ) / 2;
		
		_grpMain.add(txtClickToPlay);
		
		var playButton:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, ((FlxG.height - Reg.BUTTON_HEIGHT) / 2) - Reg.BUTTON_HEIGHT - 16, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "Play Game", PlayGameClick);
 		_grpMenuChoices.add(playButton);
		
		var optionsButton:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2,  (FlxG.height - Reg.BUTTON_HEIGHT) / 2, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "Options", OptionsClick);
 		_grpMenuChoices.add(optionsButton);
		
		var creditsButton:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2,((FlxG.height - Reg.BUTTON_HEIGHT) / 2) + Reg.BUTTON_HEIGHT+ 16, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "Credits", CreditsClick);
 		_grpMenuChoices.add(creditsButton);
		
		
		var p1:CustomButton = new CustomButton((FlxG.width -Reg.BUTTON_WIDTH) / 2, (FlxG.height / 2) - Reg.BUTTON_HEIGHT - 8, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "1 Player", Start1Player);
		_grpPlayChoices.add(p1);
		
		var p2:CustomButton = new CustomButton((FlxG.width -Reg.BUTTON_WIDTH) / 2, (FlxG.height / 2 ) + 8, Reg.BUTTON_WIDTH, Reg.BUTTON_HEIGHT, "2 Players", Start2Player);
		_grpPlayChoices.add(p2);
		
		
		
		var matchButton1:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, ((FlxG.height - Reg.BUTTON_HEIGHT) / 2) - Reg.BUTTON_HEIGHT - 16,Reg.BUTTON_WIDTH,Reg.BUTTON_HEIGHT, "Single Match", PlaySingleMatch);
		_grpMatchesChoices.add(matchButton1);
		
		var matchButton2:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, (FlxG.height - Reg.BUTTON_HEIGHT) / 2, Reg.BUTTON_WIDTH,Reg.BUTTON_HEIGHT,"Best of 3", Play2OO3Match);
		_grpMatchesChoices.add(matchButton2);
		
		var matchButton3:CustomButton = new CustomButton((FlxG.width - Reg.BUTTON_WIDTH) / 2, ((FlxG.height - Reg.BUTTON_HEIGHT) / 2) + Reg.BUTTON_HEIGHT+ 16, Reg.BUTTON_WIDTH,Reg.BUTTON_HEIGHT,"Best of 5", Play3OO5Match);
		_grpMatchesChoices.add(matchButton3);
		
		_sprBlack = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(_sprBlack);
		justTriggered = true;
		
		super.create();
	}
	
	private function PlaySingleMatch():Void
	{
		if (_state != STATE_MATCH || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 1;
		
	}
	
	private function Play2OO3Match():Void
	{
		if (_state != STATE_MATCH || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 3;
		
	}
	
	private function Play3OO5Match():Void
	{
		if (_state != STATE_MATCH || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 5;
		
	}
	
	private function PlayGameClick():Void
	{
		if (_state != STATE_MENU || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_PLAY;
		_grpMenuChoices.visible = false;
		_grpPlayChoices.visible = true;
	}
	
	private function Start1Player():Void
	{
		if (_state != STATE_PLAY || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_MATCH;
		Reg.numPlayers = 1;
		_grpPlayChoices.visible = false;
		_grpMatchesChoices.visible = true;

	}
	
	private function Start2Player():Void
	{
		if (_state != STATE_PLAY || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_MATCH;
		Reg.numPlayers = 2;
		_grpPlayChoices.visible = false;
		_grpMatchesChoices.visible = true;

	}
	
	private function CreditsClick():Void
	{
		if (_state != STATE_MENU || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		_goingToCredits = true;
		
	}
	
	private function OptionsClick():Void
	{
		if (_state != STATE_MENU || justTriggered) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		_goingToOptions = true;
		
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
		
		switch(_state)
		{
			case STATE_UNLOADED:
				if (_sprBlack.alpha > 0)
					_sprBlack.alpha -= FlxG.elapsed * 3;
				else
					_state = STATE_MAIN;
			case STATE_MAIN:
				#if !FLX_NO_MOUSE
				if (FlxG.mouse.justReleased)
				{
					FlxG.mouse.reset();
					_state = STATE_MENU;
					_grpMain.visible = false;
					_grpMenuChoices.visible = true;
				}
				#end
				#if !FLX_NO_TOUCH
				for (touch in FlxG.touches.list)
				{
					if (touch.justReleased && _state == STATE_MAIN)
					{
						_state = STATE_MENU;
						_grpMain.visible = false;
						_grpMenuChoices.visible = true;	
					}
				}
				#end
			case STATE_UNLOADING:
				if (_sprBlack.alpha < 1)
					_sprBlack.alpha += FlxG.elapsed * 3;
				else
				{
					if (_goingToCredits)
						FlxG.switchState(new CreditsState());
					else if (_goingToOptions)
						FlxG.switchState(new OptionsState());
					else
						FlxG.switchState(new PlayState());
				}
		}
		
		super.update();
		justTriggered = false;
	}	
}