package;

import flash.display.BlendMode;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.Lib;
import flash.media.Sound;
import flash.system.System;
import flash.ui.MouseCursorData;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.text.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxSave;

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
	
	private var _sprTitle:FlxSprite;
	
	#if (desktop && !FLX_NO_MOUSE)
	private var _sprExit:FlxSprite;
	#end
	
	private var _twnTitle:FlxTween;
	private var _outMenu:FlxGroup;
	private var _inMenu:FlxGroup;
	private var _switchToState:Int;
	private var _switchingMenu:Bool;
	private var _outAlpha:Float;
	private var _inAlpha:Float;
		
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		Reg.initGame();
		
		FlxG.cameras.bgColor = 0xff330033;
		#if !FLX_NO_MOUSE
		Reg.ShowMouse();
		#end
		_inAlpha = 0;
		_outAlpha = 0;
		_state = STATE_UNLOADED;
		
		add(new FlxSprite(0, 0, "images/background.png"));
		
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
		
		_sprTitle = new FlxSprite(0, 0, "images/title-card.png");
		_sprTitle.alpha = 0;
		_grpMain.add(_sprTitle);
		
		
		txtClickToPlay = new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		
		#if !FLX_NO_TOUCH
		txtClickToPlay.setText("Touch to Play", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		#end
		#if !FLX_NO_MOUSE
		txtClickToPlay.setText("Click to Play", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		#end
		
		txtClickToPlay.y = FlxG.height -32;
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
		
		_sprBlack = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		_sprBlack.blend = BlendMode.ADD;
		add(_sprBlack);
		justTriggered = true;
		
		#if (desktop && !FLX_NO_MOUSE)
		_sprExit = new FlxSprite(FlxG.width - 32, 16).loadGraphic("images/exit.png", true, false, 16, 16);
		_sprExit.animation.add("off", [0]);
		_sprExit.animation.add("on", [1]);
		_sprExit.animation.play("off");
		_sprExit.visible = true;
		_sprExit.alpha = 0;
		add(_sprExit);
		#end
		
		StartFadeInTween();
		
		super.create();
		
		Reg.PlayMusic(SoundAssets.MUS_BG1);
		
	}
	
	
	
	private function PlaySingleMatch():Void
	{
		if (_state != STATE_MATCH || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 1;
		StartFadeOutTween();
		
	}
	
	private function Play2OO3Match():Void
	{
		if (_state != STATE_MATCH || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 3;
		StartFadeOutTween();
		
	}
	
	private function Play3OO5Match():Void
	{
		if (_state != STATE_MATCH || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		Reg.numMatches = 5;
		StartFadeOutTween();
	}
	
	private function PlayGameClick():Void
	{
		if (_state != STATE_MENU || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		//_state = STATE_PLAY;
		//_grpMenuChoices.visible = false;
		//_grpPlayChoices.visible = true;
		MenuOut(_grpMenuChoices, _grpPlayChoices, STATE_PLAY);
	}
	
	private function Start1Player():Void
	{
		if (_state != STATE_PLAY || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		//_state = STATE_MATCH;
		Reg.numPlayers = 1;
		//_grpPlayChoices.visible = false;
		//_grpMatchesChoices.visible = true;
		MenuOut(_grpPlayChoices, _grpMatchesChoices, STATE_MATCH);

	}
	
	private function Start2Player():Void
	{
		if (_state != STATE_PLAY || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		//_state = STATE_MATCH;
		Reg.numPlayers = 2;
		//_grpPlayChoices.visible = false;
		//_grpMatchesChoices.visible = true;
		MenuOut(_grpPlayChoices, _grpMatchesChoices, STATE_MATCH);
		
	}
	
	private function CreditsClick():Void
	{
		if (_state != STATE_MENU || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		_goingToCredits = true;
		StartFadeOutTween();
	}
	
	private function OptionsClick():Void
	{
		if (_state != STATE_MENU || justTriggered || _switchingMenu) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		_state = STATE_UNLOADING;
		_goingToOptions = true;
		StartFadeOutTween();
	}
	
	private function ExitGame():Void
	{
		if (_state == STATE_UNLOADED || _state == STATE_UNLOADING) return;
		#if !FLX_NO_MOUSE
		FlxG.mouse.reset();
		#end
		justTriggered = true;
		System.exit(0);
	}
	
	private function StartFadeInTween():Void
	{
		
		_twnTitle = FlxTween.multiVar(_sprBlack, { alpha: 0 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:StartTitleTween } );
	}
	
	private function StartFadeOutTween():Void
	{
		
		_twnTitle = FlxTween.multiVar(_sprBlack, { alpha: 1 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:DoneFadeOut } );
	}
	
	private function StartTitleTween(Tween:FlxTween):Void
	{
		
		Tween = FlxTween.multiVar(_sprTitle, { alpha: 1 }, .66, { type: FlxTween.ONESHOT, ease:FlxEase.quartOut, complete:TitleTweenDone} );
	}
	
	private function TitleTweenDone(Tween:FlxTween):Void
	{
		_state = STATE_MAIN;
		Tween = FlxTween.multiVar(_sprTitle, { alpha:1 }, 2, { type:FlxTween.ONESHOT, complete: DoneWait } );
	}
	
	private function DoneFadeOut(Tween:FlxTween):Void
	{
		
		if (_goingToCredits)
			FlxG.switchState(new CreditsState());
		else if (_goingToOptions)
			FlxG.switchState(new OptionsState());
		else
		{
			Reg.PickLevels(Reg.numMatches);
			FlxG.switchState(new PlayState());
		}
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	
	private function MenuOut(OutMenu:FlxGroup,InMenu:FlxGroup, SwitchToState:Int):Void
	{
		_switchingMenu = true;
		_outMenu = OutMenu;
		_inMenu = InMenu;
		_switchToState = SwitchToState;
		_outAlpha = 1;
		_inAlpha = 0;
		//if (_twnTitle != null && !_twnTitle.finished) _twnTitle.cancel();
		_twnTitle = FlxTween.multiVar(this, { _outAlpha: 0 }, .5, { type: FlxTween.ONESHOT, ease:FlxEase.quartOut, complete:MenuIn } );
	}
	
	private function MenuIn(Tween:FlxTween):Void
	{
		_outMenu.visible = false;
		_inMenu.visible = true;
		_inMenu.setAll("alpha", 0);
		
		Tween = FlxTween.multiVar(this, { _inAlpha:1 }, .5, { type: FlxTween.ONESHOT, ease:FlxEase.quartIn, complete: MenuDone } );
	}
	
	private function DoneWait(Tween:FlxTween):Void
	{
		if (_switchingMenu || _state != STATE_MAIN) return;
		MenuOut(_grpMain,_grpMenuChoices, STATE_MENU);
	}
	
	private function MenuDone(Tween:FlxTween):Void
	{
		
		_state = _switchToState;
		_switchingMenu = false;
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{

		if (_switchingMenu)
		{
			_outMenu.setAll("alpha", _outAlpha);
			_inMenu.setAll("alpha", _inAlpha);
		}
		else
		{
			
			switch(_state)
			{
				case STATE_UNLOADED:
					//#if !(FLX_NO_MOUSE && FLX_NO_TOUCH)
					txtClickToPlay.alpha = _sprTitle.alpha;
					//#end
				case STATE_MAIN:
					#if !FLX_NO_MOUSE
					if (FlxG.mouse.justReleased && !_switchingMenu)
					{
						FlxG.mouse.reset();
						
						if (_twnTitle != null && _twnTitle.active)
							_twnTitle.cancel();
						
						MenuOut(_grpMain,_grpMenuChoices, STATE_MENU);
					}
					#end
					#if !FLX_NO_TOUCH
					for (touch in FlxG.touches.list)
					{
						if (touch.justReleased && !_switchingMenu)
						{
							if (_twnTitle != null && _twnTitle.active)
							_twnTitle.cancel();
							
							MenuOut(_grpMain,_grpMenuChoices, STATE_MENU);
						}
					}
					#end
				case STATE_PLAY:
					#if !FLX_NO_KEYBOARD
					if (FlxG.keyboard.justReleased("ESCAPE") && !_switchingMenu)
						MenuOut(_grpPlayChoices, _grpMenuChoices, STATE_MENU);
					#end
					#if android
					if (FlxG.android.justReleased("BACK") && !_switchingMenu)
						MenuOut(_grpPlayChoices, _grpMenuChoices, STATE_MENU);
					#end
				case STATE_MATCH:
					#if !FLX_NO_KEYBOARD
					if (FlxG.keyboard.justReleased("ESCAPE") && !_switchingMenu)
						MenuOut(_grpMatchesChoices,_grpPlayChoices, STATE_PLAY);
					#end
					#if android
					if (FlxG.android.justReleased("BACK") && !_switchingMenu)
						MenuOut(_grpMatchesChoices,_grpPlayChoices, STATE_PLAY);
					#end
					
			}
		}
		
		#if (desktop && !FLX_NO_MOUSE)
		if (_state == STATE_MAIN)
			_sprExit.alpha = _inAlpha;
		
		if (_state != STATE_UNLOADED && _state != STATE_UNLOADING && _sprExit.visible)
		{
			if (_sprExit.overlapsPoint(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y)))
			{
				if (FlxG.mouse.justReleased) ExitGame();
				if (_sprExit.animation.name != "on")
					_sprExit.animation.play("on");
			}
			else
			{
				if (_sprExit.animation.name != "off")
					_sprExit.animation.play("off");
			}
		}
		#end

		super.update();

		justTriggered = false;

	}
	
	
	override public function draw():Void
	{
		super.draw();
		
		#if !FLX_NO_MOUSE
			if (Reg.MouseOverButton)
				Reg.ShowMouse(Reg.CURSOR_OVER);
			else
				Reg.ShowMouse(Reg.CURSOR_NORMAL);
			Reg.MouseOverButton = false;
		#end
	}
}