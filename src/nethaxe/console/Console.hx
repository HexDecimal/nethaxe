package nethaxe.console;
import flash.display.Stage;
import nethaxe.console.render.ConsoleRender;
import nethaxe.console.render.ConsoleRenderShader;
import nethaxe.console.render.ConsoleRenderTiles;

/**
 * ...
 * @author Kyle Stewart
 */
class Console
{
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var ch:Array<Int>;
	public var fg:Array<UInt>;
	public var bg:Array<UInt>;
	
	public function new(width:Int, height:Int) 
	{
		this.width = width;
		this.height = height;
		
		ch = [for (_ in 0...(width * height)) -1];
		fg = [for (_ in 0...(width * height)) 0xffffffff];
		bg = [for (_ in 0...(width * height)) 0xff000000];
		
	}
	
	/**
	 * Return the 1D index on this console at the 2D index x,y
	 */
	public inline function getIndex(x:Int, y:Int):Int {
		return (y * width + x);
	}
	
	/**
	 * Try to return the fastest renderer for this console.
	 * Most of the renderers are for bechmarking and testing,
	 * this function should always get the best one for the platform you're on.
	 */
	public function getFastRenderer(font:ConsoleFont, ?stage:Stage):ConsoleRender {
		#if flash
		if (stage != null) {
			return new ConsoleRenderShader(this, font, stage.stage3Ds[0]);
		}else {
			return new ConsoleRenderTiles(this, font);
		}
		#else
		return new ConsoleRenderTiles(this, font);
		#end
	}
	
}