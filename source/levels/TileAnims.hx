package levels;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTileSpecial.AnimParams;
import haxe.xml.Fast;
import openfl.Assets;

typedef AnimData = { name:String, speed:Float, randomizeSpeed:Float, frames:Array<Int>, ?framesData:Array<AnimParams> };

class TileAnims
{

	public static function getClouds(Data:Dynamic):Array<Int>
	{
		var source:Fast;
		if (Std.is(Data, String))
		{
			source = new Fast(Xml.parse(Assets.getText(Data)));
		} else if (Std.is(Data, Xml)) {
			source = new Fast(Data);
		} else {
			throw "No *.tanim file";
		}
		
		source = source.node.clouds;
		var clouds:Array<Int> = new Array<Int>();
		var node:Fast;
		
		var firstGID:Int = 0;
		
		for (tileset in source.nodes.tileset)
		{
			firstGID = 0;
			if (tileset.has.firstGID)
			{
				firstGID = Std.parseInt(tileset.att.firstGID);
			}
			for (node in tileset.nodes.tile)
			{
				clouds.push(Std.parseInt(node.att.id) + firstGID);
			}
		}
		
		return clouds;
	}
	
	public static function getAnimations(Data:Dynamic):Map < Int, Array<AnimData> >
	{
		var source:Fast;
		if (Std.is(Data, String))
		{
			source = new Fast(Xml.parse(Assets.getText(Data)));
		} else if (Std.is(Data, Xml)) {
			source = new Fast(Data);
		} else {
			throw "No *.tanim file";
		}
		
		source = source.node.animations;
		
		var anims:Map <Int, Array<AnimData>> = new Map();
		var node:Fast;
		
		var startTileID:Int = -1;
		var name:String;
		var speed:Float = 0;
		var animsData:Array<AnimData>;
		var firstGID:Int = 0;
		for (tileset in source.nodes.tileset)
		{
			firstGID = 0;
			if (tileset.has.firstGID)
			{
				firstGID = Std.parseInt(tileset.att.firstGID);
			}
			
			for (node in tileset.nodes.tile)
			{
				startTileID = Std.parseInt(node.att.id) + firstGID;
				animsData = new Array<AnimData>();
				for (animation in node.nodes.animation)
				{
					var name:String = "[animation]";
					if (animation.has.id)
					{
						name = animation.att.id;
					}
					var randomizeSpeed:Float = 0;
					if (animation.has.randomizeSpeed)
					{
						randomizeSpeed = Std.parseFloat(animation.att.randomizeSpeed);
					}
					var data:AnimData = {
						name: name,
						speed: Std.parseFloat(animation.att.speed),
						randomizeSpeed: randomizeSpeed,
						frames: new Array<Int>(),
						framesData: new Array<AnimParams>()
					};
					for (frame in animation.nodes.frame)
					{
						data.frames.push(Std.parseInt(frame.att.id) + firstGID);
						if (frame.has.flipHorizontal || frame.has.flipVertical || frame.has.rotation)
						{
							var params:AnimParams = {
								flipHorizontal:false,
								flipVertical:false,
								rotate:FlxTileSpecial.ROTATE_0
							};
							
							if (frame.has.flipHorizontal && frame.att.flipHorizontal == "true")
							{
								params.flipHorizontal = true;
							}
							
							if (frame.has.flipVertical && frame.att.flipVertical == "true")
							{
								params.flipVertical = true;
							}
							
							if (frame.has.rotation)
							{
								var rotation:Int = Std.parseInt(frame.att.rotation);
								switch(rotation) {
									case 90:
										params.rotate = FlxTileSpecial.ROTATE_90;
									case 270:
										params.rotate = FlxTileSpecial.ROTATE_270;
									default:
										params.rotate = FlxTileSpecial.ROTATE_0;
								}
							}
							
							data.framesData.push(params);
						} else {
							data.framesData.push(null);
						}
					}
					
					animsData.push(data);
				}
				
				anims.set(startTileID, animsData);
			}
		}
		
		return anims;
		
	}
	
}