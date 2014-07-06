package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import nethaxe.console.ConsoleFontBDF;
import openfl.Assets;
import openfl.display.FPS;
import openfl.events.SystemEvent;
import nethaxe.console.Console;
import nethaxe.console.ConsoleFont;
import nethaxe.console.ConsoleFontAssets;
import nethaxe.console.ConsoleFontBitmap;
import nethaxe.console.render.ConsoleRenderDrawTiles;
import nethaxe.console.render.ConsoleRenderBitmap;
import nethaxe.console.render.ConsoleRenderGraphic;
import nethaxe.console.render.ConsoleRenderTiles;

/**
 * ...
 * @author Kyle Stewart
 */

class Main extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	var states:Array<State> = [new PerformanceState()];
	var stateIndex:Int = 0;
	
	var rootConsole:Console;
	var sideConsole:Console;
	var mainConsole:Console;
	
	var oldTime:Float;
	
	private var font:ConsoleFont;
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		
		// (your code here)
		
		addEventListener(Event.ENTER_FRAME, update);
		
		//font = new ConsoleFontBitmap(Assets.getBitmapData('img/6x12.png'), 6, 12);
		font = new ConsoleFontBDF(Assets.getBytes('fonts/bdf/6x12.bdf'));
		rootConsole = new Console(120, 40);
		var SIDEBAR_WIDTH = 30;
		sideConsole = new Console(SIDEBAR_WIDTH, rootConsole.height, rootConsole, 0, 0);
		mainConsole = new Console(rootConsole.width - SIDEBAR_WIDTH, rootConsole.height, rootConsole, SIDEBAR_WIDTH, 0);
		
		addChild(rootConsole.getFastRenderer(font, stage));
		//addChild(new ConsoleRenderBitmap(rootConsole, font));
		//addChild(new ConsoleRenderGraphic(rootConsole, font));
		//addChild(new ConsoleRenderTiles(rootConsole, font));
		
		var fps:FPS = new FPS(stage.stageWidth - 120, stage.stageHeight - 40);
		fps.background = true;
		fps.backgroundColor = 0xffffff;
		addChild( fps);
		
		oldTime = Date.now().getTime();
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}
	
	private function update(?e:Dynamic):Void {
		
		states[stateIndex].step(mainConsole);
		//mainConsole.drawStr(0, 0, "Hello World\nTest");
		//Date.now().getTime()
		sideConsole.clear();
		sideConsole.drawStr(0, sideConsole.height - 1, '${checkTime()}ms');
		
		
		//mainConsole.drawStr(0, 0, Date.now().toString());
	}
	
	private function checkTime():Int {
		var newTime = Date.now().getTime();
		var returnTime = newTime - oldTime;
		oldTime = newTime;
		return Math.floor(returnTime);
	}
	

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
