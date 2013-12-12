package ;
#if flash
import flixel.addons.display.FlxSpriteAniRot;
#end
import flixel.FlxSprite;
#if flash
class PointNode extends FlxSpriteAniRot
#end
#if !flash
class PointNode extends FlxSprite
#end
{
	private var _owner:Int;
	
	public function new(X:Float, Y:Float) 
	{
		#if !flash
		super(X, Y);
		loadGraphic("images/nodes.png", true, false, 24, 24);
		#end
		
		#if flash
		super("images/nodes.png", 360, X, Y);
		#end
		
		animation.add("neutral", [0]);
		animation.add("p1", [1]);
		animation.add("p2", [2]);
		animation.play("neutral");
		immovable = true;
		angularVelocity = 45;
		
		
	}
	
	override public function update():Void
	{
		if (alive && onScreen() && exists)
		{
			if (animation.name == "neutral" || animation.name == "p1" || animation.name == "p2")
			{
				if (_owner == 0)
					animation.play("neutral");
				else
					animation.play("p" + Std.string(_owner));
			}			
		}
		super.update();
		
	}
	
	function get_owner():Int 
	{
		return _owner;
	}
	
	function set_owner(value:Int):Int 
	{
		return _owner = value;
	}
	
	public var owner(get_owner, set_owner):Int;
	
}