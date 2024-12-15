package;

import GameJolt.GJToastManager;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;
import openfl.utils.Assets;

#if debug
// import flixel.addons.studio.FlxStudio;
#end
class Main extends Sprite
{
	var initialState:Class<FlxState> = SpecsDetector; // The FlxState the game starts with.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	#if cpp
	var memoryMonitor:MemoryMonitor = new MemoryMonitor(10, 3, 0xffffff);
	#end
	var fpsCounter:FPSMonitor = new FPSMonitor(10, 3, 0xFFFFFF);

	////Indie cross vars
	public static var dataJump:Int = 8; // The j
	public static var menuOption:Int = 0;

	public static var unloadDelay:Float = 0.5;

	public static var appTitle:String = 'Indie Cross';

	public static var menuMusic:String = 'freakyMenu';
	public static var menubpm:Float = 117;

	public static var curSave:String = 'save';

	public static var logAsked:Bool = false;
	public static var focusMusicTween:FlxTween;

	public static var hiddenSongs:Array<String> = ['gose', 'gose-classic', 'saness'];

	public static var gjToastManager:GJToastManager;

	public static var transitionDuration:Float = 0.5;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function keepRatio(width:Int, height:Int): { width:Int, height:Int }
	{
		// Calculate the possible width and height based on the 16:9 ratio
		var ratioWidth = (height * 16) / 9;
		var ratioHeight = (width * 9) / 16;

		// Check if the calculated width or height exceeds the provided limits
		if (ratioWidth <= width)
		{
			return { width: Std.int(ratioWidth), height: height }; // fits within width
		}
		else
		{
			return { width: width, height: Std.int(ratioHeight) }; // fits within height
		}
	}

	private function setupGame():Void
	{
		var newRes = keepRatio(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

		game = new FlxGame(newRes.width, newRes.height, initialState, framerate, framerate, skipSplash, startFullscreen);

		function resizeHandler(event:Event):Void {
			var newerRes = keepRatio(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
			FlxG.resizeGame(newerRes.width, newerRes.height);
			trace('using resolution ' + newerRes.width + 'x' +  newerRes.height);
		}

		// FlxG.stage.addEventListener(Event.RESIZE, resizeHandler);

		#if (debug && poly)
		FlxStudio.create();
		#end

		addChild(game);

		#if cpp
		addChild(memoryMonitor);
		#end

		addChild(fpsCounter);

		gjToastManager = new GJToastManager();
		addChild(gjToastManager);

		#if debug
		// debugging shit
		FlxG.console.registerObject("Paths", Paths);
		FlxG.console.registerObject("Conductor", Conductor);
		FlxG.console.registerObject("PlayState", PlayState);
		FlxG.console.registerObject("Note", Note);
		FlxG.console.registerObject("PlayStateChangeables", PlayStateChangeables);

		FlxG.console.registerObject("MainMenuState", MainMenuState);
		#end

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
	}

	var game:FlxGame;
	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	public static var focused:Bool = true;

	// thx for ur code ari
	function onWindowFocusOut()
	{
		focused = false;

		// Lower global volume when unfocused
		if (Type.getClass(FlxG.state) != PlayState) // imagine stealing my code smh
		{
			oldVol = FlxG.sound.volume;
			if (oldVol > 0.3)
			{
				newVol = 0.3;
			}
			else
			{
				if (oldVol > 0.1)
				{
					newVol = 0.1;
				}
				else
				{
					newVol = 0;
				}
			}

			trace("Game unfocused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();
			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);

			// Conserve power by lowering draw framerate when unfocuced
			FlxG.drawFramerate = 30;
		}
	}

	function onWindowFocusIn()
	{
		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			focused = true;
		});

		// Lower global volume when unfocused
		if (Type.getClass(FlxG.state) != PlayState)
		{
			trace("Game focused");

			// Normal global volume when focused
			if (focusMusicTween != null)
				focusMusicTween.cancel();

			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);

			// Bring framerate back when focused
			FlxG.drawFramerate = 120;
		}
	}

	// you tried lol
	public static var persistentAssets:Array<FlxGraphic> = [];
	public static var idk:Array<String> = ['', 'assets/'];

	public static function dumpCache()
	{
		// /*
		if (Main.dumping)
		{
			trace('removed ur mom');
			// haya's stuff again lol
			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null && !persistentAssets.contains(obj))
				{
					Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					openfl.Assets.cache.removeBitmapData(key);
				}
			}

			// clear gpu vram
			GPUFunctions.disposeAllTextures();
			// clear songs
			for (i in 0...idk.length)
			{
				Assets.cache.clear(idk[i] + "songs");
				Assets.cache.clear(idk[i] + "sans/sounds");
				Assets.cache.clear(idk[i] + "cuphead/sounds");
				Assets.cache.clear(idk[i] + "bendy/sounds");
				Assets.cache.clear(idk[i] + "shared/sounds");
			}
			openfl.Assets.cache.clear("songs");
			openfl.Assets.cache.clear("assets/songs");
			// garbage disposal
			System.gc();
		}
		Main.dumping = false;
		// */
	}

	public static var dumping:Bool = false;

	public static function switchState(target:FlxState)
	{
		dumping = true;
		FlxG.switchState(target);
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		fpsCounter.visible = fpsEnabled;
	}

	public function toggleMemCounter(enabled:Bool):Void
	{
		#if cpp
		memoryMonitor.visible = enabled;
		#end
	}

	public function changeDisplayColor(color:FlxColor)
	{
		#if cpp
		fpsCounter.textColor = color;
		memoryMonitor.textColor = color;
		#end
	}

	public function setFPSCap(cap:Float)
	{
		Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}
}
