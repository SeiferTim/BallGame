package ;
import flixel.FlxG;
import openfl.Assets;


class SoundAssets
{

	//inline static public var SND_MADEINSTL:String = "sounds/madeinsound.wav";
	inline static public var SND_BUTTONUP:String = "sounds/button_press.wav";
	//inline static public var SND_BUTTONDOWN:String = "sounds/boop.wav";
	
	static public var HIT_SOUNDS:Array<String>;
	
	inline static public var SND_HIT1:String = "sounds/hit-1.wav";
	inline static public var SND_HIT2:String = "sounds/hit-2.wav";
	inline static public var SND_HIT3:String = "sounds/hit-3.wav";
	inline static public var SND_HIT4:String = "sounds/hit-4.wav";
	inline static public var SND_HIT5:String = "sounds/hit-5.wav";
	inline static public var SND_HIT6:String = "sounds/hit-6.wav";
	
	static public var POP_SOUNDS:Array<String>;
	
	inline static public var SND_POP1:String = "sounds/pop-1.wav";
	inline static public var SND_POP2:String = "sounds/pop-2.wav";
	inline static public var SND_POP3:String = "sounds/pop-3.wav";
	inline static public var SND_POP4:String = "sounds/pop-4.wav";
	
	inline static public var SND_BOOOP:String = "sounds/booop.wav";
	inline static public var SND_BOOOOP:String = "sounds/booooop.wav";
	
	// MUSIC
	#if flash
	inline static public var MUS_BG1:String = "music/bg1.mp3";
	inline static public var MUS_BG2:String = "music/bg2.mp3";
	inline static public var MUS_MADEINSTL:String = "music/madeinstl.mp3";
	#end
	#if !flash
	inline static public var MUS_BG1:String = "music/bg1.ogg";
	inline static public var MUS_BG2:String = "music/bg2.ogg";
	inline static public var MUS_MADEINSTL:String = "music/madeinstl.ogg";
	#end
	
	/**
	 * Sound caching for android target
	 */
	static public function cacheSounds():Void
	{
		HIT_SOUNDS = new Array<String>();
		HIT_SOUNDS.push(SND_HIT1);
		HIT_SOUNDS.push(SND_HIT2);
		HIT_SOUNDS.push(SND_HIT3);
		HIT_SOUNDS.push(SND_HIT4);
		HIT_SOUNDS.push(SND_HIT5);
		HIT_SOUNDS.push(SND_HIT6);
		
		POP_SOUNDS = new Array<String>();
		POP_SOUNDS.push(SND_POP1);
		POP_SOUNDS.push(SND_POP2);
		POP_SOUNDS.push(SND_POP3);
		POP_SOUNDS.push(SND_POP4);	
		
		#if android
		FlxG.sound.add(SND_BUTTONUP);
		//FlxG.sound.add(SND_BUTTONDOWN);
		FlxG.sound.add(MUS_BG1);
		FlxG.sound.add(MUS_BG2);
		FlxG.sound.add(MUS_MADEINSTL);
		FlxG.sound.add(SND_BOOOP);
		FlxG.sound.add(SND_BOOOOP);
		
		for (sound in HIT_SOUNDS)
		{
			FlxG.sound.add(sound);
		}
		
		for (sound in POP_SOUNDS)
		{
			FlxG.sound.add(sound);
		}
		
		
		
		#end
		

	}
	
}