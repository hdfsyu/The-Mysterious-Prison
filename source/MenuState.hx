package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var startButton:FlxButton;
	var titleText:FlxText;
	var optionsButton:FlxButton;
	#if desktop
	var exitButton:FlxButton;
	#end

	function clickStart()
	{
		FlxG.switchState(new PlayState());
	}

	function clickOptions()
	{
		FlxG.switchState(new OptionsState());
	}

	#if desktop
	function clickExit()
	{
		Sys.exit(0);
	}
	#end

	override public function create()
	{
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(AssetPaths.music__wav, 1, true);
		}
		titleText = new FlxText(20, 0, 0, "The\nMysterious\nPrison", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(X);
		add(titleText);
		startButton = new FlxButton(0, 0, "Start", clickStart);
		startButton.x = (FlxG.width / 2) - startButton.width - 10;
		startButton.y = FlxG.height - startButton.height - 10;
		add(startButton);
		startButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		optionsButton = new FlxButton(0, 0, "Options", clickOptions);
		optionsButton.x = (FlxG.width / 2) + 10;
		optionsButton.y = FlxG.height - optionsButton.height - 10;
		add(optionsButton);
		optionsButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		#if desktop
		exitButton = new FlxButton(FlxG.width - 28, 8, "X", clickExit);
		exitButton.loadGraphic(AssetPaths.button__png);
		add(exitButton);
		#end
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
