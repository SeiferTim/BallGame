package ;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;


class ScoreBoardState extends FlxState
{

	private var _txtHeadingMatchNos:Array<FlxText>;
	//private var _txtHeadingP1:FlxText;
	//private var _txtHeadingP2:FlxText;
	private var _txtScoresP1:Array<FlxText>;
	private var _txtScoresP2:Array<FlxText>;
	private var _sprBacksP1:Array<FlxSprite>;
	private var _sprBacksP2:Array<FlxSprite>;
	private var _btnNextMatch:FlxButtonPlus;
	
	private static inline var itemWidth:Int = 110;
	
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		BuildScreen();
		
		super.create();
	}
	
	private function BuildScreen():Void
	{
		var _startLeft:Float = (FlxG.width - ((Reg.numMatches + 1) * itemWidth)) / 2;
		_txtHeadingMatchNos = new Array<FlxText>();
		_txtScoresP1 = new Array<FlxText>();
		_txtScoresP2 = new Array<FlxText>();
		trace((Reg.numMatches + 1));
		for (i in 0...(Reg.numMatches+1))
		{
			if (i == 0)
			{
				//_txtHeadingMatchNos.push(cast add(new FlxText(_startLeft + (itemWidth * i), 16, itemWidth, "Match", 16)));
				_txtScoresP1.push(cast add(new FlxText(_startLeft + (itemWidth * i), 32, itemWidth, "Player 1", 16)));
				_txtScoresP2.push(cast add(new FlxText(_startLeft + (itemWidth * i), 48, itemWidth, "Player 2", 16)));
				
			}
			else
			{
				_txtHeadingMatchNos.push(cast add(new FlxText(_startLeft + (itemWidth * i), 16, itemWidth, Std.string(i), 16)));
				_txtScoresP1.push(cast add(new FlxText(_startLeft + (itemWidth * i), 32, itemWidth, Reg.scores.length > i-1 ? Reg.scores[i-1][0] : "-", 16)));
				_txtScoresP2.push(cast add(new FlxText(_startLeft + (itemWidth * i), 48, itemWidth, Reg.scores.length > i-1 ? Reg.scores[i-1][1] : "-", 16)));
				_txtHeadingMatchNos[i].alignment = "right";
			}
			
			
			_txtScoresP1[i].alignment = "right";
			_txtScoresP2[i].alignment = "right";

		}
	}
	
}