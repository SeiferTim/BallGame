package ;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flixel.addons.text.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;

class CustomButton extends FlxGroup
{

	private	inline static var STATE_UP:Int = 0;
	private	inline static var STATE_DOWN:Int = 1;
	
	private var _onUp:Dynamic;
	
	private var _state:Int;
	private var _button_up:FlxSprite;
	private var _button_down:FlxSprite;
	private var _label:FlxBitmapFont;
	private var _width:Float;
	private var _height:Float;
	private var _x:Float;
	private var _y:Float;
	private var _scrollFactor:FlxPoint;
	private var _alpha:Float;
	private var _initialized:Bool;
	private var _touchPointID:Int;
	private var _buttonRect:FlxRect;
	
	public function new(X:Float, Y:Float, Width:Float, Height:Float, ?Label:String, ?OnClick:Dynamic) 
	{
		super(3);
		_x = X;
		_y = Y;
		_width = Width;
		_height = Height;
		_scrollFactor = new FlxPoint(1, 1);
		_onUp = OnClick;
		
		_button_up = new FlxSprite(_x, _y);
		_button_up.makeGraphic(Std.int(_width), Std.int(_height), 0xff00cc00);
		add(_button_up);
		
		_button_down = new FlxSprite(_x, _y);
		_button_down.makeGraphic(Std.int(_width), Std.int(_height), 0xffcc0000);
		add(_button_down);
		
		_button_down.visible = false;
		
		_label = new FlxBitmapFont(Reg.FONT_YELLOW, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_label.setText(Label == null ? "" : Label, false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_label.setPosition(_x + ((_width - _label.width) / 2), _y + ((_height - _label.height) / 2));
		add(_label);
		
		_state = STATE_UP;
		//_visible = true;
		_alpha = 1;
		_initialized = false;
		_touchPointID = -1;
		_buttonRect = new FlxRect(_x, _y, _width, _height);
		
		FlxG.watch.add(this, "_state");
		
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
		
		//trace(visible + " " + _button_down.visible + " " + _button_up.visible + " " + _label.visible);
		
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
				case STATE_UP:
					_button_down.visible = false;
					_button_up.visible = true;
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
		_button_down.x = _button_up.x = _x;
		_label.setPosition(_x + ((_width - _label.width) / 2), _y + ((_height - _label.height) / 2));
		
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
		_button_down.y = _button_up.y = _y;
		_label.setPosition(_x + ((_width - _label.width) / 2), _y + ((_height - _label.height) / 2));
		
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
		return  _label.alpha = _alpha = value;
		
	}
	
	public var alpha(get_alpha, set_alpha):Float;
	
	
	
	private function updateRect():Void
	{
		_buttonRect.x = _x;
		_buttonRect.y = _y;
		
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