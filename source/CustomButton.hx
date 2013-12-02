package ;

import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flixel.addons.text.FlxBitmapFont;
import flixel.effects.FlxSpriteFilter;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

class CustomButton extends FlxSpriteGroup
{

	private	inline static var STATE_UP:Int = 0;
	private	inline static var STATE_DOWN:Int = 1;
	
	private var _onUp:Dynamic;
	
	private var _state:Int;
	private var _button_up:FlxSprite;
	private var _button_down:FlxSprite;
	private var _label:FlxBitmapFont;
	//private var _width:Float;
	//private var _height:Float;
	//private var _x:Float;
	//private var _y:Float;
	//private var _scrollFactor:FlxPoint;
	//private var _alpha:Float;
	private var _initialized:Bool;
	private var _touchPointID:Int;
	private var _buttonRect:FlxRect;
	
	private var _glow:FlxSprite;
	//private var _lEmitter:FlxEmitter;
	//private var _rEmitter:FlxEmitter;
	
	public function new(X:Float, Y:Float, Width:Float, Height:Float, ?Label:String, ?OnClick:Dynamic) 
	{
		super(X,Y,4);
		//_x = X;
		//_y = Y;
		//_width = Width;
		//_height = Height;
		//_scrollFactor = new FlxPoint(1, 1);
		
		_onUp = OnClick;
		alpha = 1;
		
		
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
		
		_glow = FlxGradient.createGradientFlxSprite(Std.int(Width - 4), Std.int(Height - 4), [0x33ffffff,0x11ffffff, 0x00ffffff,0x00ffffff, 0x11ffffff,0x33ffffff], 1, 90);
		_glow.setPosition(2, 2);
		_glow.blend = BlendMode.ADD;
		
		add(_button_up);
		add(_button_down);
		add(_glow);
		
		
		_label = new FlxBitmapFont(Reg.FONT_BRIGHTVIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_label.setText(Label == null ? "" : Label, false, 0, 0, FlxBitmapFont.ALIGN_CENTER, false);
		_label.setPosition(((Width - _label.width) / 2),((Height - _label.height) / 2));
		add(_label);
		
		_state = STATE_UP;
		//_visible = true;
		
		_initialized = false;
		_touchPointID = -1;
		_buttonRect = new FlxRect(x, y, Width, Height);
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
		
		updateButton();
	}
	
	function updateButton():Void
	{
		
		var continueUpdate = false;
		
		#if !FLX_NO_MOUSE
			continueUpdate = true;
		#end
		
		#if !FLX_NO_TOUCH
			continueUpdate = true;
		#end
		
		if (continueUpdate)
		{
			var newState:Int;
			
			newState = STATE_UP;
			
			updateRect();
			
			#if !FLX_NO_MOUSE
			if (FlxMath.mouseInFlxRect(false, _buttonRect))
			{
				if (FlxG.mouse.pressed && ( _state == STATE_DOWN || FlxG.mouse.justPressed))
					newState = STATE_DOWN;
			}
			#end
			#if !FLX_NO_TOUCH
			for (touch in FlxG.touches.list)
			{
				if (_touchPointID == -1)
				{
					
					if (touch.inFlxRect(_buttonRect))
					{
						if (touch.justPressed)
						{
							_state = STATE_DOWN;
							_touchPointID = touch.touchPointID;
						}
					
					}
				}
				else if (touch.touchPointID == _touchPointID)
				{
					if (touch.justReleased && touch.inFlxRect(_buttonRect))
					{
						onMouseUp(null);
					}
					else if (touch.inFlxRect(_buttonRect))
						newState = STATE_DOWN;
				}
			}
			#end
			
			//trace(newState + " " + _state);
			
			updateButtonState(newState);
		}
	}
	
	private function updateButtonState(NewState:Int):Void
	{
		if (_state != NewState)
		{
			switch(NewState)
			{
				case STATE_DOWN:
					_button_down.visible = true;
					_button_up.visible = false;
					/*_lEmitter.setColor(0xccffff, 0xffffff);
					_lEmitter.setXSpeed( -30, -20);
					_rEmitter.setColor(0xccffff, 0xffffff);
					_rEmitter.setXSpeed( 20, 30);*/
				case STATE_UP:
					_button_down.visible = false;
					_button_up.visible = true;
					/*_lEmitter.setColor(0x99ffff, 0xffffff);
					_lEmitter.setXSpeed( -20, -10);
					_rEmitter.setColor(0x99ffff, 0xffffff);
					_rEmitter.setXSpeed( 10, 20);*/
			}
			_state = NewState;
		}
	}
	
	override public function destroy():Void 
	{
		if (FlxG.stage != null)
		{
			#if !FLX_NO_MOUSE
				Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, _onUp);
			#end
		}
		
		_onUp = null;
	
		super.destroy();
	}
	/*
	function get_width():Float 
	{
		return _width;
	}
	
	public var width(get_width, null):Float;
	
	function get_height():Float 
	{
		return _height;
	}
	
	public var height(get_height, null):Float;
	
	function get_x():Float 
	{
		return _x;
	}
	
	function set_x(value:Float):Float 
	{
		_x = value;
		_lEmitter.x = _button_down.x = _button_up.x = _x;
		_label.setPosition(_x + ((_width - _label.width) / 2), _y + ((_height - _label.height) / 2));
		_lEmitter.setAll("bounds", new FlxRect(_x,_y,width,height));
		updateRect();
		return _x;
	}
	
	public var x(get_x, set_x):Float;
	
	function get_y():Float 
	{
		return _y;
	}
	
	function set_y(value:Float):Float 
	{
		_y = value;
		_lEmitter.y = _button_down.y = _button_up.y = _y;
		_label.setPosition(_x + ((_width - _label.width) / 2), _y + ((_height - _label.height) / 2));
		_lEmitter.setAll("bounds", new FlxRect(_x,_y,width,height));
		updateRect();
		return _y;
	}
	
	public var y(get_y, set_y):Float;
	
	function get_scrollFactor():FlxPoint 
	{
		return _scrollFactor;
	}
	
	function set_scrollFactor(value:FlxPoint):FlxPoint 
	{
		_scrollFactor = value;
		_button_down.scrollFactor = value;
		_button_up.scrollFactor = value;
		_label.scrollFactor = value;
		return _scrollFactor;
	}
	
	public var scrollFactor(get_scrollFactor, set_scrollFactor):FlxPoint;
	
	function get_alpha():Float 
	{
		return _alpha;
	}
	
	function set_alpha(value:Float):Float 
	{
		if (_state == STATE_UP)
			_button_up.alpha = value;
		else 
			_button_down.alpha = value;
		_lEmitter.startAlpha.max = value;
		_lEmitter.startAlpha.min = value;
		_rEmitter.startAlpha.max = value;
		_rEmitter.startAlpha.min = value;
		return  _label.alpha = _alpha = value;
		
	}
	
	public var alpha(get_alpha, set_alpha):Float;
	
	*/
	
	private function updateRect():Void
	{
		_buttonRect.x = x;
		_buttonRect.y = y;
		
	}
	
	inline public function setOnUpCallback(Callback:Dynamic):Void 
	{
		_onUp = Callback;
	}
	
	private function onMouseUp(event:Event):Void 
	{
		if (!exists || !visible || !active || _state == STATE_UP)
		{
			return;
		}
		if (_onUp != null)
			Reflect.callMethod(null, _onUp, null);
		_touchPointID = -1;
		updateButtonState(STATE_UP);
	}
	
}