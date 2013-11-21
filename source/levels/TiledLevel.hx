package levels;

import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.system.debug.ConsoleCommands;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import haxe.io.Path;

class TiledLevel extends TiledMap
{

	private inline static var TILESHEET_PATH:String = "images/";
	
	private var _wallTiles:FlxGroup;
	
	
	private var _enemies:FlxGroup;
	private var _objects:FlxGroup;
	
	private var _bounds:FlxRect;

	
	
	public function new(level:Dynamic, animFile:Dynamic) 
	{
		
		super(level);
		
		// background and foreground groups
		_wallTiles = new FlxGroup();
		_enemies = new FlxGroup();
		_objects = new FlxGroup();
		
		// The bound of the map for the camera
		_bounds = new FlxRect((fullWidth - FlxG.width) / 2, (fullHeight - FlxG.height) / 2, FlxG.width, FlxG.height);
		var tileset:TiledTileSet;
		var tilemap:FlxTilemapExt;
		var layer:TiledLayer;
		
		// Prepare the tile animations
		var animations = TileAnims.getAnimations(animFile);
		//var clouds = TileAnims.getClouds(animFile);
		
		for (layer in layers) {
				if (layer.properties.contains("tileset")) {
						tileset = this.getTileSet(layer.properties.get("tileset"));
				} else {
						throw "Each layer needs a tileset property with the tileset name";
				}
				
				if (tileset == null) {
						throw "The tileset is null";
				}
				
				tilemap = new FlxTilemapExt();
				
				// need to set the width and height in tiles because we are loading the map with an array
				tilemap.widthInTiles = layer.width;
				tilemap.heightInTiles = layer.height;
				
				var imagePath = new Path(tileset.imageSource);
				
				tilemap.loadMap(
						layer.tileArray,                                                
						TILESHEET_PATH + imagePath.file + "." + imagePath.ext,        
						tileset.tileWidth,                                                // each tileset can have a different tile width or height
						tileset.tileHeight,
						FlxTilemap.OFF,                                                        // disable auto map
						tileset.firstGID,                                                // IMPORTANT! set the starting tile id to the first tile id of the tileset
						tileset.firstGID,
						tileset.firstGID
				);
				
				//tilemap.setClouds(clouds);
				
				var specialTiles:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
				var tile:TiledTile;
				var animData;
				var specialTile:FlxTileSpecial;
				// For each tile in the layer
				for ( i in 0...layer.tiles.length) { 
						tile = layer.tiles[i];
						if (tile != null && isSpecialTile(tile, animations)) {
								specialTile = new FlxTileSpecial(tile.tilesetID, tile.isFlipHorizontally, tile.isFlipVertically, tile.rotate);
								// add animations if exists
								if (animations.exists(tile.tilesetID)) {
										// Right now, a special tile only can have one animation.
										animData = animations.get(tile.tilesetID)[0];
										// add some speed randomization to the animation
										var randomize:Float = FlxRandom.floatRanged(-animData.randomizeSpeed, animData.randomizeSpeed);
										var speed:Float = animData.speed + randomize;
										
										specialTile.addAnimation(animData.frames, speed, animData.framesData);
								}
								specialTiles[i] = specialTile;
						} else {
								specialTiles[i] = null;
						}
				}
				// set the special tiles (flipped, rotated and/or animated tiles)
				tilemap.setSpecialTiles(specialTiles);
				// set the alpha of the layer
				tilemap.alpha = layer.opacity;
				
				
				//if (layer.properties.contains("fg")) {
				//		_foregroundTiles.add(tilemap);
				//} else {
				_wallTiles.add(tilemap);
				//}
		}
		
		loadObjects();
	}
	
	public var wallTiles(get, set):FlxGroup;
	
	public function get_wallTiles():FlxGroup
	{
		return _wallTiles;
	}
	
	public function set_wallTiles(Value:FlxGroup):FlxGroup
	{
		_wallTiles = Value;
		return _wallTiles;
	}
	
	public var objects(get, set):FlxGroup;
	
	public function get_objects():FlxGroup
	{
		return _objects;
	}
	
	public function set_objects(Value:FlxGroup):FlxGroup
	{
		_objects = Value;
		return _objects;
	}
	
	public var bounds(get, null):FlxRect;
	
	
	function get_enemies():FlxGroup 
	{
		return _enemies;
	}
	
	public var enemies(get_enemies, null):FlxGroup;
	public function get_bounds():FlxRect
	{
		return _bounds;
	}
	
	public function loadObjects():Void 
	{
		for (group in objectGroups)
		{
			for (obj in group.objects)
			{
				loadObject(obj, group);
			}
		}
	}
	
	public function loadObject(o:TiledObject, g:TiledObjectGroup):Void
	{
		var x:Float = o.x; // Std.int((Math.floor(o.x) / 16)) * 16;
		var y:Float = o.y; // Std.int((Math.floor(o.y) / 16)) * 16;
		var width:Float = o.width;
		var height:Float = o.height;
		
		/*switch(o.type.toLowerCase())
		{
			case "enemy":
				var enemy:Enemy = new Enemy(x,y,  Std.parseInt(o.name));
				_enemies.add(enemy);
			
		}*/
	}
	
	
	
	
	
	public inline function isSpecialTile(tile:TiledTile, animations:Dynamic):Bool 
	{
		return (tile.isFlipHorizontally || tile.isFlipVertically || tile.rotate != FlxTileSpecial.ROTATE_0 || animations.exists(tile.tilesetID));
	}
	
	
	
}