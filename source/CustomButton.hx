package ;

import flash.display.BitmapDataChannel;
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
import flixel.util.FlxArrayUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

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
	private var _lEmitter:FlxEmitter;
	private var _rEmitter:FlxEmitter;
	
	public function new(X:Float, Y:Float, Width:Float, Height:Float, ?Label:String, ?OnClick:Dynamic) 
	{
		super(5);
		_x = X;
		_y = Y;
		_width = Width;
		_height = Height;
		_scrollFactor = new FlxPoint(1, 1);
		_onUp = OnClick;
		/*
		var tmpMask:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(Width), Std.int(Height), 0x0);
		FlxSpriteUtil.drawRoundRect(tmpMask, 0, 0, Width, Height, 8, 8, 0xff000000);
		
		var tmpLine:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(Width), Std.int(Height), 0xff33ffff);
		
		var tmpLineMask:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(Width), Std.int(Height), 0xff000000);
		FlxSpriteUtil.drawRoundRect(tmpLineMask, 1, 1, Width-2, Height-2, 8, 8, 0xffffffff);
		FlxSpriteUtil.drawRoundRect(tmpLineMask, 2, 2, Width - 4, Height - 4, 8, 8, 0xff000000);
		
		tmpLine.pixels.copyChannel(tmpLineMask.pixels, new Rectangle(0, 0, tmpLine.width, tmpLine.height), new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

		_button_up = new FlxSprite();
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Std.int(Width), Std.int(Height), [0xffcc66cc, 0xffcc66cc, 0xffcc66cc, 0xff660066, 0xffcc66cc, 0xff993399], 1, 90), tmpMask, _button_up);
		FlxSpriteUtil.mergeFlxSprite(_button_up, tmpLine,_button_up);
		_button_up.setPosition(_x, _y);
		add(_button_up);
		
		
		_button_down = new FlxSprite();
		FlxSpriteUtil.alphaMaskFlxSprite(FlxGradient.createGradientFlxSprite(Std.int(Width), Std.int(Height), [0xffee88ee, 0xffee88ee, 0xff882288, 0xffee88ee,0xffee88ee,  0xffbb55bb], 1, 90), tmpMask, _button_down);
		FlxSpriteUtil.mergeFlxSprite(_button_down, tmpLine,_button_down);
		_button_down.setPosition(_x, _y);
		add(_button_down);
		
		_button_down.visible = false;
		
		*/
		
		_button_up = new FlxSprite(_x, _y).makeGraphic(Std.int(Width), Std.int(Height), 0xff99ffff);
		_button_down = new FlxSprite(_x, _y).makeGraphic(Std.int(Width), Std.int(Height), 0xffccffff);
		_button_down.visible = false;
		
		
		var particles:Int = 48;
		var particle:BoundedParticle;
		var size:Int;
		var sizes:Array<Int> = [1,2,4,6,8,10,12];//[1, 1, 1, 1, 2, 2, 2, 4, 4, 6,8,10,12,14,16];
		//var alphas:Array<Float> = [.04,.05,.06,.07,.1];
		//var pBlend:BlendMode = BlendMode.LIGHTEN;
		var rate:Float = 0.025;
		var lspan:Float = .4;
		
		
		_lEmitter = new FlxEmitter(_x,_y, particles);
		_lEmitter.width = 1;
		_lEmitter.height = Height;
		_lEmitter.gravity = 0;
		_lEmitter.setXSpeed(-20, -10);
		_lEmitter.setYSpeed(0, 0);
		_lEmitter.setRotation(0, 0);
		_lEmitter.setAlpha(1, 1, 0, 0);
		_lEmitter.setColor(0x99ffff, 0x660066);
		_lEmitter.particleClass = BoundedParticle;
		
		for (i in 0...particles)
		{
			size = sizes[i%sizes.length];
			particle = new BoundedParticle();
			particle.makeGraphic(size, size, 0xffffffff);
			particle.exists = false;
			//particle.useFading = true;
			particle.useColoring = true;
			particle.bounds = new FlxRect(_x, _y, Width, Height);
			_lEmitter.add(particle);
		}
		_lEmitter.start(false, lspan, rate,0,1);
		add(_lEmitter);
		
		_rEmitter = new FlxEmitter(_x+Width-1,_y, particles);
		_rEmitter.width = 1;
		_rEmitter.height = Height;
		_rEmitter.gravity = 0;
		_rEmitter.setXSpeed(10, 20);
		_rEmitter.setYSpeed(0, 0);
		_rEmitter.setRotation(0, 0);
		_rEmitter.setAlpha(1,1, 0, 0);
		_rEmitter.setColor(0x99ffff, 0x660066);
		_rEmitter.particleClass = BoundedParticle;
		
		for (i in 0...particles)
		{
			size = sizes[i%sizes.length];
			particle = new BoundedParticle();
			particle.makeGraphic(size, size, 0xffffffff);
			particle.exists = false;
			
			particle.useColoring = true;
			particle.bounds = new FlxRect(_x, _y, Width, Height);
			_rEmitter.add(particle);
		}
		_rEmitter.start(false, lspan, rate,0,1);
		add(_rEmitter);
		
		
		add(_button_up);
		add(_button_down);
		
		
		_label = new FlxBitmapFont(Reg.FONT_VIOLET, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_label.setText(Label == null ? "" : Label, false, 0, 0, FlxBitmapFont.ALIGN_CENTER, true);
		_label.setPosition(_x + ((_width - _label.width) / 2), _y + ((_height - _label.height) / 2));
		add(_label);
		
		_state = STATE_UP;
		//_visible = true;
		_alpha = 1;
		_initialized = false;
		_touchPointID = -1;
		_buttonRect = new FlxRect(_x, _y, _width, _height);
		
		//FlxG.watch.add(this, "_state");
		
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
					_lEmitter.setColor(0xccffff, 0xffffff);
					_lEmitter.setXSpeed( -30, -20);
					_rEmitter.setColor(0xccffff, 0xffffff);
					_rEmitter.setXSpeed( 20, 30);
				case STATE_UP:
					_button_down.visible = false;
					_button_up.visible = true;
					_lEmitter.setColor(0x99ffff, 0xffffff);
					_lEmitter.setXSpeed( -20, -10);
					_rEmitter.setColor(0x99ffff, 0xffffff);
					_rEmitter.setXSpeed( 10, 20);
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