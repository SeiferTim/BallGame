package ;
import flixel.effects.FlxTrail;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class FakeBall extends FlxSprite
{

	private var _trail:FlxTrail;
	private var _grad:FlxTrail;
	private var _lastVel:FlxPoint;
	
	public function new(X:Int, Y:Int, VelX:Float, VelY:Float)
	{
		super(X, Y);
		loadGraphic("images/Ball.png", true, false, 16, 16);
		animation.add("neutral", [0, 1, 2, 1], 6);
		animation.play("neutral");
		
		elasticity = 1.025;
		maxVelocity.set(600, 600);
		velocity.x = VelX;
		velocity.y = VelY;
		_lastVel = new FlxPoint(VelX, VelY);
		
		
	}
	
	override public function update():Void
	{
		if (!onScreen()) kill();
		if (!Reg.Freeze)
		{
			if (velocity.x != 0 && velocity.y != 0)
			{
				_lastVel.x = velocity.x;
				_lastVel.y = velocity.y;
				
			}
			else
			{
				velocity.x = _lastVel.x;
				velocity.y =_lastVel.y;
			}
			if (velocity.x > -180 && velocity.x < 180)
				velocity.x = 180 * (velocity.x / Math.abs(velocity.x));
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
		_trail.kill();
		_grad.kill();
	}
	
	private function set_trail(value:FlxTrail):FlxTrail 
	{
		return _trail = value;
	}
	
	public var trail(null, set_trail):FlxTrail;
	
	private function set_grad(value:FlxTrail):FlxTrail 
	{
		return _grad = value;
	}
	
	public var grad(null, set_grad):FlxTrail;
	
}