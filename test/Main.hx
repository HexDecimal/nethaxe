package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.Assets;
import openfl.display.FPS;
import openfl.events.SystemEvent;
import rogueutil.console.ConsoleData;
import rogueutil.console.ConsoleDrawTilesRender;
import rogueutil.console.ConsoleFont;
import rogueutil.console.ConsoleFontBitmap;
import rogueutil.console.ConsoleBitmapRender;
import rogueutil.console.ConsoleGraphicRender;
import rogueutil.console.ConsoleTileRender;

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
	
	var cData:ConsoleData;
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		
		// (your code here)
		
		addEventListener(Event.ENTER_FRAME, update);
		
		var font:ConsoleFont = new ConsoleFontBitmap(Assets.getBitmapData('img/6x12.png'), 6, 12);
		
		cData = new ConsoleData(140, 80);
		//cData = new ConsoleData(30, 20);
		//cData.ch[1] = 'A'.charCodeAt(0);
		//addChild(new ConsoleBitmapRender(cData, font));
		//addChild(new ConsoleGraphicRender(cData, font));
		addChild(new ConsoleTileRender(cData, font));
		//addChild(new ConsoleDrawTilesRender(cData, font));
		var fps:FPS = new FPS(stage.stageWidth - 120, stage.stageHeight - 40);
		//fps.opaqueBackground = 0xffffff;
		fps.background = true;
		fps.backgroundColor = 0xffffff;
		addChild( fps);
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}
	
	private function update(?e:Dynamic):Void {
		var i:Int = 0;
		for (y in 0...cData.height) {
			for (x in 0...cData.width) {
				cData.ch[i] = Math.floor(Math.random() * 256);
				cData.fg[i] = Math.floor(Math.random() * 0xff) | 0xffff00;
				cData.bg[i] = Math.floor(Math.random() * 0xff);
				i++;
			}
		}
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
