package ;

import flixel.effects.FlxTrail;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class Enemy extends FlxSprite
{

	var _etype:Int;
	var _dying:Bool;
	var _startingPos:FlxPoint;
	var _moveDir:Int;
	var _rotAngle:Float;
	var _score:Int;
	var _rotDir:Int;
	var _trail:FlxTrail;
	
	public function new(X:Float=0, Y:Float=0, EType:Int)
	{
		super(X, Y);
		
		_etype = EType;
		_dying = false;
		immovable = true;
		_startingPos = new FlxPoint(X,Y);
		_rotAngle = 0;
		_rotDir = 0;
		switch(_etype)
		{
			case 0:
				//makeGraphic(16, 16, FlxColor.RED);
				loadGraphic("images/Baddie 1 throwing star.png", true, false, 16, 16);
				animation.add("normal", [0, 1, 2], 6);
				animation.play("normal");
				_moveDir = FlxObject.UP;
				health = 1;
				_score = 15;
			case 1:
				//makeGraphic(16, 16, FlxColor.RED);
				loadGraphic("images/Baddie 1 throwing star.png", true, false, 16, 16);
				animation.add("normal", [0, 1, 2], 6);
				animation.play("normal");
				_moveDir = FlxObject.DOWN;
				health = 1;
				_score = 15;
			case 2:
				//makeGraphic(16, 16, FlxColor.BLUE);
				loadGraphic("images/Baddie-2-Ghost.png", true, true, 16, 16);
				animation.add("normal", [0, 1], 6);
				animation.play("normal");
				if (X < FlxG.width / 2)
				{
					_rotDir = -1;
					facing = FlxObject.RIGHT;
				}
				else
				{
					_rotDir = 1;
					facing = FlxObject.LEFT;
				}
				health = 1;
				_rotAngle = FlxRandom.intRanged( -180, 180);
				_score = 25;
				var pt:FlxPoint = FlxAngle.rotatePoint(_startingPos.x  + 32, _startingPos.y , _startingPos.x, _startingPos.y, _rotAngle);				
				x = pt.x;
				y = pt.y;
			case 3:
				makeGraphic(32, 32, FlxColor.YELLOW);
				health = 1;
				_score = 30;
				
		}
	}
	
	override public function update():Void
	{
		if (!alive || !exists) return;
		if (!Reg.Freeze)
		{
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
				
				switch(_etype)
				{
					case 0:
						if (_moveDir == FlxObject.UP)
						{
							if (y  <= _startingPos.y - 32)
							{
								_moveDir = FlxObject.DOWN;
								velocity.y = 0;
							}
							else
								velocity.y = -24;
						}
						else if (_moveDir == FlxObject.DOWN)
						{
							if (y  >= _startingPos.y + 32)
							{
								_moveDir = FlxObject.UP;
								velocity.y = 0;
							}
							else
								velocity.y = 24;
						}
					case 1:
						if (_moveDir == FlxObject.UP)
						{
							if (y  <= _startingPos.y - 32)
							{
								_moveDir = FlxObject.DOWN;
								velocity.y = 0;
							}
							else
								velocity.y = -24;
						}
						else if (_moveDir == FlxObject.DOWN)
						{
							if (y  >= _startingPos.y + 32)
							{
								_moveDir = FlxObject.UP;
								velocity.y = 0;
							}
							else
								velocity.y = 24;
						}
					case 2:
						var pt:FlxPoint = FlxAngle.rotatePoint(_startingPos.x  + 32, _startingPos.y , _startingPos.x, _startingPos.y, _rotAngle);				
						x = pt.x;
						y = pt.y;
						_rotAngle += FlxG.elapsed * 120 *_rotDir;
						if (_rotAngle > 360) _rotAngle-= _rotAngle;
					case 3:
						

				}
				
			}
		}
		else
		{
			velocity.x = 0;
			velocity.y = 0;
		}
		super.update();
	}
	
	override public function kill():Void
	{
		super.kill();
		if (_trail!= null)
			_trail.kill();
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
	
	function get_score():Int 
	{
		return _score;
	}
	
	public var score(get_score, null):Int;
	
	function set_trail(value:FlxTrail):FlxTrail 
	{
		return _trail = value;
	}
	
	public var trail(null, set_trail):FlxTrail;
	
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