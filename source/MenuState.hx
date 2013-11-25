package;

import flixel.addons.text.FlxBitmapFont;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;

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
		
		trace(txtClickToPlay.visible);
		_grpMain.add(txtClickToPlay);
		
		var p1:FlxButtonPlus = new FlxButtonPlus(0, 0, Start1Player, null, "1 Player", 100, 20);  //(0, 0, "1 Player", Start1Player);
		p1.x = (FlxG.width - p1.width) / 2;
		p1.y = (FlxG.height / 2) - p1.height - 4;
		_grpPlayChoices.add(p1);
		
		var p2:FlxButtonPlus = new FlxButtonPlus(0, 0, Start2Player, null, "2 Players", 100, 20);//(0, 0, "2 Players", Start2Player);
		p2.x = (FlxG.width - p2.width) / 2;
		p2.y = (FlxG.height / 2 ) + 4;
		_grpPlayChoices.add(p2);
		
		var playButton:FlxButtonPlus = new FlxButtonPlus(0, 0, PlayGameClick, null, "Play Game", 100, 20);//(0, 0, "Play Game", PlayGameClick);
		playButton.x = (FlxG.width - playButton.width) / 2;
		playButton.y = (FlxG.height - playButton.height) / 2;
 		_grpMenuChoices.add(playButton);
		
		var matchButton1:FlxButtonPlus = new FlxButtonPlus(0, 0, PlaySingleMatch, null, "Single Match", 100, 20);//(0, 0, "Single Match", PlaySingleMatch);
		matchButton1.x = (FlxG.width - matchButton1.width) / 2;
		matchButton1.y = (FlxG.height - matchButton1.height) / 2 - matchButton1.height - 4;
		_grpMatchesChoices.add(matchButton1);
		
		var matchButton2:FlxButtonPlus = new FlxButtonPlus(0, 0, Play2OO3Match, null, "Best of 3");//(0, 0, "Best 2 out of 3", Play2OO3Match);
		matchButton2.x = (FlxG.width - matchButton2.width) / 2;
		matchButton2.y = (FlxG.height - matchButton2.height) / 2;
		_grpMatchesChoices.add(matchButton2);
		
		var matchButton3:FlxButtonPlus = new FlxButtonPlus(0, 0, Play3OO5Match, null, "Best of 5", 100, 20); //(0, 0, "Best 3 out of 5", Play3OO5Match);
		matchButton3.x = (FlxG.width - matchButton3.width) / 2;
		matchButton3.y = (FlxG.height - matchButton3.height) / 2 + matchButton1.height + 4;
		_grpMatchesChoices.add(matchButton3);
		
		
		
		_sprBlack = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(_sprBlack);
		justTriggered = true;
		super.create();
	}
	
	private function PlaySingleMatch():Void
	{
		if (_state != STATE_MATCH || justTriggered) return;
		FlxG.mouse.reset();
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 1;
		
	}
	
	private function Play2OO3Match():Void
	{
		if (_state != STATE_MATCH || justTriggered) return;
		FlxG.mouse.reset();
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 3;
		
	}
	
	private function Play3OO5Match():Void
	{
		if (_state != STATE_MATCH || justTriggered) return;
		FlxG.mouse.reset();
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 5;
		
	}
	
	private function PlayGameClick():Void
	{
		if (_state != STATE_MENU || justTriggered) return;
		FlxG.mouse.reset();
		justTriggered = true;
		_state = STATE_PLAY;
		_grpMenuChoices.visible = false;
		_grpPlayChoices.visible = true;
	}
	
	private function Start1Player():Void
	{
		trace("play 1 click?");
		if (_state != STATE_PLAY || justTriggered) return;
		FlxG.mouse.reset();
		justTriggered = true;
		_state = STATE_MATCH;
		Reg.numPlayers = 1;
		_grpPlayChoices.visible = false;
		_grpMatchesChoices.visible = true;

	}
	
	private function Start2Player():Void
	{
		trace("play 2 click?");
		if (_state != STATE_PLAY || justTriggered) return;
		FlxG.mouse.reset();
		justTriggered = true;
		_state = STATE_MATCH;
		Reg.numPlayers = 2;
		_grpPlayChoices.visible = false;
		_grpMatchesChoices.visible = true;

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
				if (FlxG.mouse.justReleased)
				{
					FlxG.mouse.reset();
					_state = STATE_MENU;
					_grpMain.visible = false;
					_grpMenuChoices.visible = true;
				}
			case STATE_UNLOADING:
				if (_sprBlack.alpha < 1)
					_sprBlack.alpha += FlxG.elapsed * 3;
				else
					FlxG.switchState(new PlayState());
		}
		
		super.update();
		justTriggered = false;
	}	
}