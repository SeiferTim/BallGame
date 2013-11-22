package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

class Enemy extends FlxSprite
{

	var _etype:Int;
	var _dying:Bool;
	var _startingPos:FlxPoint;
	var _moveDir:Int;
	
	public function new(X:Float=0, Y:Float=0, EType:Int)
	{
		super(X, Y);
		makeGraphic(16, 16, FlxColor.RED);
		_etype = EType;
		_dying = false;
		immovable = true;
		_startingPos = new FlxPoint(X, Y);
		switch(_etype)
		{
			case 0:
				_moveDir = FlxObject.UP;
				health = 1;
			case 1:
				_moveDir = FlxObject.DOWN;
				health = 1;
				
		}
	}
	
	override public function update():Void
	{
		if (!alive || !exists) return;
		if (_dying)
		{
			if (alpha > 0)
			{
				//scale.x += FlxG.elapsed * 8; 
				//scale.y += FlxG.elapsed * 8;
				alpha -= FlxG.elapsed * 4;
			}
			else
				kill();
		}
		else
		{
			if (_moveDir == FlxObject.UP)
			{
				if (y <= _startingPos.y - 16)
				{
					_moveDir = FlxObject.DOWN;
					velocity.y = 0;
				}
				else
					velocity.y = -10;
			}
			else if (_moveDir == FlxObject.DOWN)
			{
				if (y >= _startingPos.y + 16)
				{
					_moveDir = FlxObject.UP;
					velocity.y = 0;
				}
				else
					velocity.y = 10;
			}
		}
		super.update();
	}
	
	function get_dying():Bool 
	{
		return _dying;
	}
	
	public var dying(get_dying, null):Bool;
	
	function get_etype():Int 
	{
		return _etype;
	}
	
	public var etype(get_etype, null):Int;
	
	override public function hurt(Damage:Float):Void
	{
		if (!alive || !exists || _dying) return;
		health = health - Damage;
		if (health <= 0)
		{
			allowCollisions = FlxObject.NONE;
			_dying = true;
		}
	}
	
}