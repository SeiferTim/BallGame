package ;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxRect;

class BoundedParticle extends FlxParticle
{

	var _bounds:FlxRect;
	
	
	override public function onEmit():Void
	{
		super.onEmit();
		if (x + width > _bounds.x + _bounds.width) x = _bounds.x + _bounds.width - width;
		if (x < _bounds.x) x = _bounds.x;
		if (y + height > _bounds.y + _bounds.height) y = _bounds.y + _bounds.height - height;
		if (y < _bounds.y) y = _bounds.y;
	}
	
	function get_bounds():FlxRect 
	{
		return _bounds;
	}
	
	function set_bounds(value:FlxRect):FlxRect 
	{
		return _bounds = value;
	}
	
	public var bounds(get_bounds, set_bounds):FlxRect;

	
}