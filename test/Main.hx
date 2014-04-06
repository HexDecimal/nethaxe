package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.Assets;
import openfl.display.FPS;
import openfl.events.SystemEvent;
import nethaxe.console.Console;
import nethaxe.console.ConsoleFont;
import nethaxe.console.ConsoleFontBitmap;
import nethaxe.console.render.ConsoleRenderDrawTiles;
import nethaxe.console.render.ConsoleRenderBitmap;
import nethaxe.console.render.ConsoleRenderGraphic;
import nethaxe.console.render.ConsoleRenderShader;
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
	
	var cData:Console;
	
	private var font:ConsoleFont;
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		
		// (your code here)
		
		addEventListener(Event.ENTER_FRAME, update);
		
		font = new ConsoleFontBitmap(Assets.getBitmapData('img/6x12.png'), 6, 12);
		cData = new Console(120, 40);
		//cData = new ConsoleData(30, 20);
		//cData.ch[1] = 'A'.charCodeAt(0);
		//addChild(new ConsoleRenderBitmap(cData, font));
		//addChild(new ConsoleRenderGraphic(cData, font));
		//addChild(new ConsoleRenderTiles(cData, font));
		//addChild(new ConsoleRenderDrawTiles(cData, font));
		addChild(new ConsoleRenderShader(cData, font, stage.stage3Ds[0]));
		//addChild(new ConsoleRenderAGAL(cData, font, stage.stage3Ds[0]));
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
	
	private var tick:Int = 0;
	
	private function update(?e:Dynamic):Void {
		tick++;
		var i:Int = 0;
		for (y in 0...cData.height) {
			for (x in 0...cData.width) {
				cData.ch[i] = Math.floor(Math.random() * 256);
				//cData.fg[i] = Math.floor(Math.random() * 0xff) | 0xffff00;
				cData.fg[i] = 0xffffff;
				cData.bg[i] = Math.floor(Math.random() * 0xff);
				i++;
			}
		}
		//cData.bg[tick % cData.bg.length] = 0xff0000;
		//cData.bg[cData.getIndex(5, 2)] = 0xff0000;
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
