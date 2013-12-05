package ;

import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.media.Sound;
import flixel.addons.text.FlxBitmapFont;
import flixel.effects.FlxSpriteFilter;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

class CustomButton extends FlxSpriteGroup
{
	private var _label:FlxBitmapFont;
	/**
	 * Shows the current state of the button, either <code>NORMAL</code>, 
	 * <code>HIGHLIGHT</code> or <code>PRESSED</code>
	 */
	public var status:Int;
	/**
	 * Set this to play a sound when the mouse goes over the button.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundOver:FlxSound;
	/**
	 * Set this to play a sound when the mouse leaves the button.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundOut:FlxSound;
	/**
	 * Set this to play a sound when the button is pressed down.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundDown:FlxSound;
	/**
	 * Set this to play a sound when the button is released.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundUp:FlxSound;
	
	/**
	 * This function is called when the button is released.
	 * We recommend assigning your main button behavior to this function
	 * via the <code>FlxButton</code> constructor.
	 */
	private var _onUp:Dynamic;
	/**
	 * This function is called when the button is pressed down.
	 */
	private var _onDown:Dynamic;
	/**
	 * This function is called when the mouse goes over the button.
	 */
	private var _onOver:Dynamic;
	/**
	 * This function is called when the mouse leaves the button area.
	 */
	private var _onOut:Dynamic;
	/**
	 * The params to pass to the <code>_onUp</code> function
	 */
	private var _onUpParams:Array<Dynamic>;
	/**
	 * The params to pass to the <code>_onDown</code> function
	 */
	private var _onDownParams:Array<Dynamic>;
	/**
	 * The params to pass to the <code>_onOver</code> function
	 */
	private var _onOverParams:Array<Dynamic>;
	/**
	 * The params to pass to the <code>_onOut</code> function
	 */
	private var _onOutParams:Array<Dynamic>;
	/**
	 * Tracks whether or not the button is currently pressed.
	 */
	private var _pressed:Bool;
	private var _wasPressed:Bool;
	/**
	 * Whether or not the button has initialized itself yet.
	 */
	private var _initialized:Bool;
	
	private var _touchPointID:Int;
	
	private var _button_up:FlxSprite;
	private var _button_down:FlxSprite;
	private var _button_highlight:FlxSprite;
	
	private var _buttonRect:FlxRect;
	
	
	public function new(X:Float, Y:Float, Width:Float, Height:Float, ?Label:String, ?OnClick:Dynamic) 
	{
		super(X, Y, 4);
		
		_button_up = new FlxSprite().makeGraphic(Std.int(Width), Std.int(Height), 0x0, true);
		FlxSpriteUtil.drawRoundRect(_button_up, 0, 0, Std.int(Width), Std.int(Height), 3, 3, 0xffc078f2);
		_button_up.pixels.fillRect(new Rectangle(2, 1, Width - 4, Height - 2), 0xccc078f2);
		_button_up.pixels.fillRect(new Rectangle(1, 2, Width - 2, Height - 4), 0xccc078f2);
		_button_up.pixels.fillRect(new Rectangle(2, 2, Width - 4, Height - 4), 0xff26ffff);
		_button_up.pixels.fillRect(new Rectangle(4, 4, Width - 8, (Height - 8)/2), 0xcc99ffff  );
		_button_up.pixels.fillRect(new Rectangle(4, ((Height - 8)/2)+4, Width - 8, (Height - 8)/2), 0xcc33ffff );
		
		_button_down = new FlxSprite();
		_button_down.makeGraphic(Std.int(Width), Std.int(Height), 0x0, true);
		FlxSpriteUtil.drawRoundRect(_button_down, 0, 0, Std.int(Width), Std.int(Height), 3, 3, 0xffc078f2);
		_button_down.pixels.fillRect(new Rectangle(2, 1, Width - 4, Height - 2), 0xccc078f2);
		_button_down.pixels.fillRect(new Rectangle(1, 2, Width - 2, Height - 4), 0xccc078f2);
		_button_down.pixels.fillRect(new Rectangle(2, 2, Width - 4, Height - 4), 0xff26ffff);
		_button_down.pixels.fillRect(new Rectangle(6, 6, Width - 12, (Height - 12)/2), 0xdd88ffff  );
		_button_down.pixels.fillRect(new Rectangle(6, ((Height - 12)/2)+6, Width - 12, (Height - 12)/2), 0xdd22ffff );
		_button_down.visible = false;
		
		_button_highlight = new FlxSprite();
		_button_highlight.makeGraphic(Std.int(Width), Std.int(Height), 0x0, true);
		FlxSpriteUtil.drawRoundRect(_button_highlight, 0, 0, Std.int(Width), Std.int(Height), 3, 3, 0xffc078f2);
		_button_highlight.pixels.fillRect(new Rectangle(2, 1, Width - 4, Height - 2), 0xccc078f2);
		_button_highlight.pixels.fillRect(new Rectangle(1, 2, Width - 2, Height - 4), 0xccc078f2);
		_button_highlight.pixels.fillRect(new Rectangle(2, 2, Width - 4, Height - 4), 0xff26ffff);
		_button_highlight.pixels.fillRect(new Rectangle(6, 6, Width - 12, (Height - 12)/2), 0xddaaffff  );
		_button_highlight.pixels.fillRect(new Rectangle(6, ((Height - 12)/2)+6, Width - 12, (Height - 12)/2), 0xdd44ffff );
		_button_highlight.visible = false;
		
		add(_button_up);
		add(_button_down);
		add(_button_highlight);
		
		_label = new FlxBitmapFont(Reg.FONT_BRIGHTVIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_label.setText(Label == null ? "" : Label, false, 0, 0, FlxBitmapFont.ALIGN_CENTER, false);
		_label.setPosition(((Width - _label.width) / 2),((Height - _label.height) / 2));
		add(_label);
		
		_buttonRect = new FlxRect(x, y, Width, Height);
		
		_onUp = OnClick;
		_onDown = null;
		_onOut = null;
		_onOver = null;
		
		_onUpParams = [];
		_onDownParams = [];
		_onOutParams = [];
		_onOverParams = [];
		
		soundOver = null;
		soundOut = null;
		soundDown = null;
		soundUp = null;
		
		status = FlxButton.NORMAL;
		_pressed = false;
		_wasPressed = false;
		_initialized = false;
		
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		
		_touchPointID = -1;
	}
	
	/**
	 * Called by the game state when state is changed (if this object belongs to the state)
	 */
	override public function destroy():Void
	{
		if (FlxG.stage != null)
		{
			#if !FLX_NO_MOUSE
				Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			#end
		}
		if (_label != null)
		{
			_label.destroy();
			_label = null;
		}
		
		_button_up.destroy();
		_button_down.destroy();
		_button_highlight.destroy();
		
		_onUp = null;
		_onDown = null;
		_onOut = null;
		_onOver = null;
		
		_onUpParams = null;
		_onDownParams = null;
		_onOutParams = null;
		_onOverParams = null;
		
		if (soundOver != null)
		{
			soundOver.destroy();
		}
		if (soundOut != null)
		{
			soundOut.destroy();
		}
		if (soundDown != null)
		{
			soundDown.destroy();
		}
		if (soundUp != null)
		{
			soundUp.destroy();
		}
		super.destroy();
	}
	
	private function drawButtonState():Void
	{
		
		switch(status)
		{
			case FlxButton.PRESSED:
				_button_down.visible = true;
				_button_up.visible = false;
				_button_highlight.visible = false;
			case FlxButton.NORMAL:
				_button_down.visible = false;
				_button_up.visible = true;
				_button_highlight.visible = false;
			case FlxButton.HIGHLIGHT:
				_button_down.visible = false;
				_button_up.visible = false;
				_button_highlight.visible = true;
		}
	}
	
	
	override public function update():Void
	{
		if (!_initialized)
		{
			if (FlxG.stage != null)
			{
				#if !FLX_NO_MOUSE
					Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				#end
				_initialized = true;
			}
		}
		super.update();
	}
	
	/**
	 * Called by the game loop automatically, handles mouseover and click detection.
	 */
	override public function draw():Void
	{
		
		super.draw();
		
		updateButton(); //Basic button logic

		// Default button appearance is to simply update
		// the label appearance based on animation frame.
		if (_label == null)
		{
			return;
		}
		switch (status)
		{
			case FlxButton.HIGHLIGHT:
				_label.alpha = alpha * .8;
			case FlxButton.PRESSED:
				_label.alpha = alpha * .5;
				_label.setPosition(_button_down.x + ((_button_down.width - _label.width) / 2), (_button_down.y + 1 + (_button_down.height - _label.height) / 2));
			default:
				_label.alpha = alpha * 1;
		}
	}
	
	/**
	 * Basic button update logic
	 */
	function updateButton():Void
	{
		// Figure out if the button is highlighted or pressed or what
		var continueUpdate = false;
		
		#if !FLX_NO_MOUSE
			continueUpdate = true;
		#end
		
		#if !FLX_NO_TOUCH
			continueUpdate = true;
		#end
		
		_wasPressed = _pressed;
		_pressed = false;
		if (continueUpdate)
		{
			if (cameras == null)
			{
				cameras = FlxG.cameras.list;
			}
			var camera:FlxCamera;
			var i:Int = 0;
			var l:Int = cameras.length;
			var offAll:Bool = true;
			var _point:FlxPoint = new FlxPoint();
			var _point:FlxPoint = new FlxPoint();
			while (i < l)
			{
				camera = cameras[i++];
				#if !FLX_NO_MOUSE
					FlxG.mouse.getWorldPosition(camera, _point);
					offAll = (updateButtonStatus(_point, camera, FlxG.mouse.pressed && !_wasPressed, 1) == false) ? false : offAll;
				#end
				#if !FLX_NO_TOUCH
					for (touch in FlxG.touches.list)
					{
						if (_touchPointID == -1)
						{
							if (touch.pressed && !_wasPressed)
							{
								touch.getWorldPosition(camera, _point);
								offAll = (updateButtonStatus(_point, camera, touch.pressed && !_wasPressed, touch.touchPointID) == false) ? false : offAll;
							}
						}
						else if (touch.touchPointID == _touchPointID)
						{
							touch.getWorldPosition(camera, _point);
							offAll = false;
							
							if (!touch.pressed && _wasPressed || !overlapsPoint(_point, true, camera))
							{
								offAll = true;
								this.onMouseUp(null);
							}
						}
					}
				#end
				
				if (!offAll)
				{
					break;
				}
			}
			if (offAll)
			{
				if (status != FlxButton.NORMAL)
				{
					if (_onOut != null)
					{
						Reflect.callMethod(null, _onOut, _onOutParams);
					}
					if (soundOut != null)
					{
						soundOut.play(true);
					}
				}
				trace("NORMAL");
				status = FlxButton.NORMAL;
			}
		}
	
		// Then if the label and/or the label offset exist,
		// position them to match the button.
		if (_label != null)
		{
			_label.setPosition(_button_down.x + ((_button_down.width - _label.width) / 2), (_button_down.y + (_button_down.height - _label.height) / 2));
			_label.scrollFactor = scrollFactor;
		}
		
		// Then pick the appropriate frame of animation
		//frame = framesData.frames[status];
		drawButtonState();
	}
	
	/**
	 * Updates status and handles the onDown and onOver logic (callback functions + playing sounds).
	 */
	private function updateButtonStatus(P:FlxPoint, Camera:FlxCamera, JustPressed:Bool, touchID:Int):Bool
	{
		var offAll:Bool = true;
		
		if (overlapsPoint(P, true, Camera))
		{
			offAll = false;
			
			#if !FLX_NO_MOUSE
			Reg.MouseOverButton = true;
			#end
			
			if (JustPressed)
			{
				trace("PRESSED");
				status = FlxButton.PRESSED;
				_pressed = true;
				if (_onDown != null)
				{
					Reflect.callMethod(null, _onDown, _onDownParams);
				}
				if (soundDown != null)
				{
					soundDown.play(true);
				}
				
				_touchPointID = touchID;
			}
			if (status == FlxButton.NORMAL)
			{
				trace("HIGHLIGHT");
				status = FlxButton.HIGHLIGHT;
				if (_onOver != null)
				{
					Reflect.callMethod(null, _onOver, _onOverParams);
				}
				if (soundOver != null)
				{
					soundOver.play(true);
				}
			}
		}
		
		return offAll;
	}
		
	// TODO: Return from Sound -> Class<Sound>
	/**
	 * Set sounds to play during mouse-button interactions.
	 * These operations can be done manually as well, and the public
	 * sound variables can be used after this for more fine-tuning,
	 * such as positional audio, etc.
	 * 
	 * @param	SoundOver			What embedded sound effect to play when the mouse goes over the button. Default is null, or no sound.
	 * @param 	SoundOverVolume		How load the that sound should be.
	 * @param 	SoundOut			What embedded sound effect to play when the mouse leaves the button area. Default is null, or no sound.
	 * @param 	SoundOutVolume		How load the that sound should be.
	 * @param 	SoundDown			What embedded sound effect to play when the mouse presses the button down. Default is null, or no sound.
	 * @param 	SoundDownVolume		How load the that sound should be.
	 * @param 	SoundUp				What embedded sound effect to play when the mouse releases the button. Default is null, or no sound.
	 * @param 	SoundUpVolume		How load the that sound should be.
	 */
	public function setSounds(?SoundOver:Sound, SoundOverVolume:Float = 1, ?SoundOut:Sound, SoundOutVolume:Float = 1, ?SoundDown:Sound, SoundDownVolume:Float = 1, ?SoundUp:Sound, SoundUpVolume:Float = 1):Void
	{
		if (SoundOver != null)
		{
			soundOver = FlxG.sound.load(SoundOver, SoundOverVolume);
		}
		if (SoundOut != null)
		{
			soundOut = FlxG.sound.load(SoundOut, SoundOutVolume);
		}
		if (SoundDown != null)
		{
			soundDown = FlxG.sound.load(SoundDown, SoundDownVolume);
		}
		if (SoundUp != null)
		{
			soundUp = FlxG.sound.load(SoundUp, SoundUpVolume);
		}
	}
	
	/**
	 * Set the callback function for when the button is released.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnUpCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onUp = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onUpParams = Params;
	}
	
	/**
	 * Set the callback function for when the button is being pressed on.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnDownCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onDown = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onDownParams = Params;
	}
	
	/**
	 * Set the callback function for when the button is being hovered over.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnOverCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onOver = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onOverParams = Params;
	}
	
	/**
	 * Set the callback function for when the button mouse leaves the button area.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnOutCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onOut = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onOutParams = Params;
	}
	
	/**
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxMisc.openURL()</code>).
	 */
	private function onMouseUp(event:Event):Void
	{
		trace(exists + " " + visible + " " + active + " " + status);
		if (!exists || !visible || !active || (status != FlxButton.PRESSED))
		{
			
			return;
		}

		if (_onUp != null)
		{
			Reflect.callMethod(null, _onUp, _onUpParams);
		}
		if (soundUp != null)
		{
			soundUp.play(true);
		}
		
		_touchPointID = -1;
		trace("NORMAL");
		status = FlxButton.NORMAL;
	}
	
	private function updateRect():Void
	{
		_buttonRect.x = x;
		_buttonRect.y = y;
		
	}
	
	function get_text():String 
	{
		return _label.text;
	}
	
	function set_text(value:String):String 
	{
		_label.text = value;
		_label.setPosition(_button_down.x + ((_button_down.width - _label.width) / 2), (_button_down.y + (_button_down.height - _label.height) / 2));
		return value;
	}
	
	public var text(get_text, set_text):String;
	
	
}