package ;
import flash.geom.Rectangle;
import flixel.addons.text.FlxBitmapFont;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;


class ScoreBoardState extends FlxState
{

	
	private static inline var HeadingY:Int = 54;
	private static inline var P1Y:Int = 72;
	private static inline var P2Y:Int = 90;
	private static inline var firstItemWidth:Int = 130;
	private static inline var itemWidth:Int = 92;
	
	private var _grpTexts:FlxGroup;
	private var _grpBacks:FlxGroup;
	private var _txtHeadingMatchNos:Array<FlxBitmapFont>;
	private var _txtScoresP1:Array<FlxBitmapFont>;
	private var _txtScoresP2:Array<FlxBitmapFont>;
	private var _sprBacksP1:Array<FlxSprite>;
	private var _sprBacksP2:Array<FlxSprite>;
	private var _btnNextMatch:CustomButton;
	private var _btnQuit:CustomButton;
	
	private var _grpBlack:FlxSprite;
	private var _loaded:Bool;
	private var _state:Int;
	
	private var _fadeGroups:Array<Array<FlxSprite>>;
	
	private inline static var STATE_IN:Int = 0;
	private inline static var STATE_WAIT:Int = 1;
	private inline static var STATE_OUT:Int = 2;
	
	private var alphaLevel:Float = 0;
	
	private var doingQuit:Bool;
	
	
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		_state = STATE_IN;
		BuildScreen();
		
		_loaded = true;
		super.create();
	}
	
	
	
	private function BuildScreen():Void
	{
		_fadeGroups = new Array<Array<FlxSprite>>();
		_grpBacks = new FlxGroup();
		_grpTexts = new FlxGroup();
		add(_grpBacks);
		add(_grpTexts);
		var _p1wins:Int = 0;
		var _p2wins:Int = 0;
		
		var _startLeft:Float = (FlxG.width - ((Reg.numMatches * (itemWidth)) + firstItemWidth)) / 2;
		_txtHeadingMatchNos = new Array<FlxBitmapFont>();
		_txtScoresP1 = new Array<FlxBitmapFont>();
		_txtScoresP2 = new Array<FlxBitmapFont>();
		_sprBacksP1 = new Array<FlxSprite>();
		_sprBacksP2 = new Array<FlxSprite>();
		
		var _txtScoreboard:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		_txtScoreboard.setText("SCOREBOARD", false, 0, 0, FlxBitmapFont.ALIGN_CENTER, false);
		_txtScoreboard.x = (FlxG.width - _txtScoreboard.width) / 2;
		_txtScoreboard.y = 18;
		add(_txtScoreboard);
		_fadeGroups.push([_txtScoreboard]);
		
		var RoundWinner:Int = 0;
		
		for (i in 0...(Reg.numMatches+1))
		{
			if (i == 0)
			{
				
				_txtHeadingMatchNos.push(new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95));
				_txtHeadingMatchNos[i].setFixedWidth(firstItemWidth-2, FlxBitmapFont.ALIGN_RIGHT);
				_txtHeadingMatchNos[i].setText(" ");
				_txtHeadingMatchNos[i].setPosition(_startLeft + 1, HeadingY);
				
				
				_txtScoresP1.push(new FlxBitmapFont(Reg.FONT_BLUE, 16, 16, FlxBitmapFont.TEXT_SET1, 95));
				_txtScoresP1[i].setFixedWidth(firstItemWidth-2, FlxBitmapFont.ALIGN_RIGHT);
				_txtScoresP1[i].setText("Player 1", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT, true);
				_txtScoresP1[i].setPosition(_startLeft + 1, P1Y + 1);
				
				
				_txtScoresP2.push(new FlxBitmapFont(Reg.FONT_RED, 16, 16, FlxBitmapFont.TEXT_SET1, 95));
				_txtScoresP2[i].setFixedWidth(firstItemWidth-2, FlxBitmapFont.ALIGN_RIGHT);
				_txtScoresP2[i].setText("Player 2", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT, true);
				_txtScoresP2[i].setPosition(_startLeft + 1, P2Y + 1);
				
				_fadeGroups.push([_txtHeadingMatchNos[i], _txtScoresP1[i], _txtScoresP2[i]]);
				
			}
			else
			{
				
				if ( Reg.scores.length > i - 1)
				{
					if (Reg.scores[i - 1][0] == Reg.scores[i - 1][1])
					{
						//tie!
						RoundWinner = 3;
						_p1wins++;
						_p2wins++;
					}
					else if (Reg.scores[i - 1][0] > Reg.scores[i - 1][1])
					{
						RoundWinner = 1;
						_p1wins++;
					}
					else
					{
						RoundWinner = 2;
						_p2wins++;
					}
				}
				else
					RoundWinner = 0;
				
				if (RoundWinner == 1 || RoundWinner == 3)
				{
					_sprBacksP1.push(new FlxSprite(_startLeft + (itemWidth * (i - 1) + firstItemWidth), P1Y));
					_sprBacksP1[i-1].makeGraphic(itemWidth, 16, 0xffffff48);
					_sprBacksP1[i-1].pixels.fillRect(new Rectangle(1, 1, itemWidth -2, 14), 0x0);
					_sprBacksP1[i-1].dirty = true;
					_grpBacks.add(_sprBacksP1[i - 1]);
					
				}
				else
				{
					_sprBacksP1.push(new FlxSprite(_startLeft + (itemWidth * (i - 1) + firstItemWidth), P1Y));
					_sprBacksP1[i-1].makeGraphic(itemWidth, 16, 0x0);
					_grpBacks.add(_sprBacksP1[i - 1]);
					
				}
				
				
				if (RoundWinner == 2 || RoundWinner == 3)
				{
					_sprBacksP2.push(new FlxSprite(_startLeft + (itemWidth * (i - 1) + firstItemWidth), P2Y));
					_sprBacksP2[i - 1].makeGraphic(itemWidth, 16, 0xffffff48);
					_sprBacksP2[i-1].pixels.fillRect(new Rectangle(1, 1, itemWidth -2, 14), 0x0);
					_sprBacksP2[i-1].dirty = true;
					_grpBacks.add(_sprBacksP2[i - 1]);
					
				}
				else
				{
					_sprBacksP2.push(new FlxSprite(_startLeft + (itemWidth * (i - 1) + firstItemWidth), P1Y));
					_sprBacksP2[i-1].makeGraphic(itemWidth, 16, 0x0);
					_grpBacks.add(_sprBacksP2[i - 1]);
					
				}
					
				_txtHeadingMatchNos.push(new FlxBitmapFont(Reg.FONT_GREEN, 16, 16, FlxBitmapFont.TEXT_SET1, 95));
				_txtHeadingMatchNos[i].setFixedWidth(itemWidth-2, FlxBitmapFont.ALIGN_RIGHT);
				_txtHeadingMatchNos[i].setText(Std.string(i), false, 0, 0, FlxBitmapFont.ALIGN_RIGHT);
				_txtHeadingMatchNos[i].setPosition(_startLeft + (itemWidth * (i - 1) + firstItemWidth) + 1, HeadingY);
				
				
				_txtScoresP1.push(new FlxBitmapFont(RoundWinner == 0 ? Reg.FONT_LIGHTGREY : RoundWinner == 3 ? Reg.FONT_VIOLET : RoundWinner == 1 ? Reg.FONT_GOLD : Reg.FONT_DARKGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95));
				_txtScoresP1[i].setFixedWidth(itemWidth-2, FlxBitmapFont.ALIGN_RIGHT);
				_txtScoresP1[i].setText(Reg.scores.length > i - 1 ? Reg.scores[i - 1][0] : "-", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT);
				_txtScoresP1[i].setPosition(_startLeft + (itemWidth * (i - 1) + firstItemWidth) +1, P1Y + 1);
				
				
				_txtScoresP2.push(new FlxBitmapFont(RoundWinner == 0 ? Reg.FONT_LIGHTGREY : RoundWinner == 3 ? Reg.FONT_VIOLET : RoundWinner == 2 ? Reg.FONT_GOLD : Reg.FONT_DARKGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95));
				_txtScoresP2[i].setFixedWidth(itemWidth-2, FlxBitmapFont.ALIGN_RIGHT);
				_txtScoresP2[i].setText(Reg.scores.length > i - 1 ? Reg.scores[i - 1][1] : "-", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT);
				_txtScoresP2[i].setPosition(_startLeft + (itemWidth * (i - 1) + firstItemWidth) + 1, P2Y + 1);
				_fadeGroups.push([_txtHeadingMatchNos[i], _txtScoresP1[i], _txtScoresP2[i],_sprBacksP1[i-1],_sprBacksP2[i-1]]);
				
			}
			
			
			_grpTexts.add(_txtHeadingMatchNos[i]);
			_grpTexts.add(_txtScoresP1[i]);
			_grpTexts.add(_txtScoresP2[i]);
			

		}
		
		var WinText:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_CYAN, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		WinText.setText("Wins");
		WinText.setPosition((FlxG.width - WinText.width) / 2, FlxG.height - 198);
		add(WinText);
		_fadeGroups.push([WinText]);
		
		var p1WinText:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_BLUE, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		p1WinText.setText("Player 1: ", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT , true);
		p1WinText.setPosition((FlxG.width - (p1WinText.width + 16)) / 2, FlxG.height - 162);
		add(p1WinText);
		
		
		var p2WinText:FlxBitmapFont = new FlxBitmapFont(Reg.FONT_RED, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		p2WinText.setText("Player 2: ", false, 0, 0, FlxBitmapFont.ALIGN_RIGHT , true);
		p2WinText.setPosition((FlxG.width - (p2WinText.width + 16)) / 2, FlxG.height - 144);
		add(p2WinText);
		
		var p1Count:FlxBitmapFont = new FlxBitmapFont(_p1wins >= _p2wins ? Reg.FONT_GOLD : Reg.FONT_DARKGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		p1Count.setText(Std.string(_p1wins));
		p1Count.setPosition(p1WinText.x + p1WinText.width, p1WinText.y);
		add(p1Count);
		
		var p2Count:FlxBitmapFont = new FlxBitmapFont(_p2wins >= _p1wins ? Reg.FONT_GOLD : Reg.FONT_DARKGREY, 16, 16, FlxBitmapFont.TEXT_SET1, 95);
		p2Count.setText(Std.string(_p2wins));
		p2Count.setPosition(p2WinText.x + p2WinText.width, p2WinText.y);
		add(p2Count);
		_fadeGroups.push([p1WinText, p1Count]);
		_fadeGroups.push([p2WinText, p2Count]);
		
		_btnQuit = new CustomButton(16, FlxG.height - Reg.BUTTON_HEIGHT - 16,Reg.BUTTON_WIDTH,Reg.BUTTON_HEIGHT, "Exit", ClickQuit);//Plus(16, FlxG.height - 36, ClickQuit, null, "Exit", 100, 20);
		_btnQuit.visible = false;
		add(_btnQuit);
		
		
		if (Reg.curMatch < Reg.numMatches-1)
		{
			_btnNextMatch = new CustomButton(FlxG.width - Reg.BUTTON_WIDTH - 16, FlxG.height - Reg.BUTTON_HEIGHT - 16,Reg.BUTTON_WIDTH,Reg.BUTTON_HEIGHT, "Next Match", ClickNextMatch );//Plus(FlxG.width - 116, FlxG.height - 36, ClickNextMatch, null, "Next Match", 100, 20);
			add(_btnNextMatch);
			_btnNextMatch.visible = false;
		
		}
		
		
		for (i in 0..._fadeGroups.length)
		{
			for (j in 0..._fadeGroups[i].length)
			{
				_fadeGroups[i][j].alpha = 0;
			}
		}
		
		
	}
	
	override public function update():Void
	{
		if (_loaded && _state == STATE_IN)
		{
			if (_fadeGroups[_fadeGroups.length-1][0].alpha < 1)
			{
				alphaLevel += FlxG.elapsed * 6;
				
				for (i in 0..._fadeGroups.length)
				{
					for (j in 0..._fadeGroups[i].length)
					{
						_fadeGroups[i][j].alpha = alphaLevel - (i*.3);
					}
				}
			}
			else
			{
				alphaLevel = 1;
				_state = STATE_WAIT;
				if (_btnNextMatch != null)
					_btnNextMatch.visible = true;
				_btnQuit.visible = true;
			}
		}
		else if (_state == STATE_OUT)
		{
			if (_fadeGroups[_fadeGroups.length-1][0].alpha >0)
			{
				alphaLevel -= FlxG.elapsed * 6;
				
				for (i in 0..._fadeGroups.length)
				{
					for (j in 0..._fadeGroups[i].length)
					{
						_fadeGroups[i][j].alpha = alphaLevel + (i*.3);
					}
				}
			}
			else
			{
				if (doingQuit)
					FlxG.switchState(new MenuState());
				else
					FlxG.switchState(new PlayState());
			}
		}
		
		super.update();
	}
	
	private function ClickNextMatch():Void
	{
		if (_state == STATE_WAIT)
		doingQuit = false;
		Reg.curMatch++;
		_state = STATE_OUT;
		_btnNextMatch.visible = false;
		_btnQuit.visible = false;
	}
	
	private function ClickQuit():Void
	{
		if (_state == STATE_WAIT)
		doingQuit = true;
		_state = STATE_OUT;
		if (_btnNextMatch != null)
			_btnNextMatch.visible = false;
		_btnQuit.visible = false;
	}
	
}