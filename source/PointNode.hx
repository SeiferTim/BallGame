package ;
import flixel.addons.display.FlxSpriteAniRot;
import flixel.FlxSprite;

class PointNode extends FlxSpriteAniRot
{
	private var _owner:Int;
	
	public function new(X:Float, Y:Float) 
	{

		super("images/nodes.png", 360, X, Y);

		//loadGraphic("images/nodes.png", true, false, 16, 16);
		//loadRotatedGraphic("images/nodes.png", 360, -1, true, true);
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
			if (_owner == 0)
				animation.play("neutral");
			else
				animation.play("p" + Std.string(_owner));
			
			
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