package nethaxe.console;
import flash.display.DisplayObject;
import flash.display.Stage;
import nethaxe.console.render.ConsoleRender;
import nethaxe.console.render.ConsoleRenderTiles;
import nethaxe.console.render.ConsoleRenderBitmap;


#if flash
import nethaxe.console.render.ConsoleRenderShader;
#end

/**
 * ...
 * @author Kyle Stewart
 */
class Console
{
	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var parent(default, null):Console = null;
	
	/**
	 * Direct access to the character array buffer, this is a 1-dimentional array.
	 * Use Console.getIndex to get an index on this array.
	 * 
	 * Exists only on a root console.
	 */
	public var ch(default, null):Array<Int>;
	/**
	 * Direct access to the foreground array buffer, this is a 1-dimentional array.
	 * Use Console.getIndex to get an index on this array.
	 * 
	 * Exists only on a root console.
	 */
	public var fg(default, null):Array<UInt>;
	/**
	 * Direct access to the background array buffer, this is a 1-dimentional array.
	 * Use Console.getIndex to get an index on this array.
	 * 
	 * Exists only on a root console.
	 */
	public var bg(default, null):Array<UInt>;
	
	/**
	 * A VirtualCursor instanced used for "printing" methods, each console has its own cursor.
	 */
	private var vcursor:VirtualCursor;
	
	
	public function new(width:Int, height:Int, parent=null, x:Int=0, y:Int=0) 
	{
		
		this.width = width;
		this.height = height;
		this.vcursor = new VirtualCursor(this);
		if (parent == null) {
			clear();
		}else {
			this.parent = parent;
			this.x = x;
			this.y = y;
		}
	}
	
	/**
	 * Clear the console to these values.
	 * @param	ch
	 * @param	fg
	 * @param	bg
	 */
	public inline function clear(ch:Int = 0x20, fg:UInt = 0xffffffff, bg:UInt = 0xff000000):Void {
		if (parent != null) { parent.drawRect(x, y, width, height, ch, fg, bg); return; }
		this.ch = [for (_ in 0...(width * height)) ch];
		this.fg = [for (_ in 0...(width * height)) fg];
		this.bg = [for (_ in 0...(width * height)) bg];
	}
	
	private inline function setTile(index:Int, ch:Int, fg:UInt, bg:UInt):Void {
		this.ch[index] = ch;
		this.fg[index] = fg;
		this.bg[index] = bg;
	}
	
	/**
	 * Draw a single character "ch" on this console at "x,y"
	 * @param	x position to draw on the console
	 * @param	y position to draw on the console
	 * @param	ch character index as an integer, you can use "?".charCodeAt() to get this value
	 * @param	fg foreground color as an 24-bit RGB value
	 * @param	bg background color as an 24-bit RGB value
	 */
	public inline function drawTile(x:Int, y:Int, ch:Int, fg:UInt=0xffffffff, bg:UInt=0xff000000):Void {
		if (parent != null) { return parent.drawTile(x + this.x, y + this.y, ch, fg, bg); }
		setTile(getIndex(x, y), ch, fg, bg);
	}
	
	/**
	 * Parse a string using a specific virutal cursor.
	 * This function is just to keep all string parsing in one place
	 */
	private inline function parseStrWithCursor(vcursor, string:String, fg:UInt, bg:UInt) {
		var i:Int = 0;
		while(i < string.length) {
			var ch:Int = string.charCodeAt(i);
			switch(ch) {
				case 10: { // newline
					vcursor.newline();
				}
				default:{
					vcursor.normalize();
					drawTile(vcursor.x, vcursor.y, ch, fg, bg);
					vcursor.step();
				}
			}
			i++;
		}
	}
	
	/**
	 * Draw a string starting at x,y
	 * @param	x
	 * @param	y
	 * @param	string
	 * @param	fg
	 * @param	bg
	 */
	public inline function drawStr(x:Int, y:Int, string:String, fg:UInt = 0xffffffff, bg:UInt = 0xff000000):Void {
		parseStrWithCursor(new VirtualCursor(this, x, y), string, fg, bg);
	}
	
	/**
	 * Fill a rectangle
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @param	ch
	 * @param	fg
	 * @param	bg
	 */
	public inline function drawRect(x:Int, y:Int, width:Int, height:Int, ch:Int, fg:UInt=0xffffffff, bg:UInt=0xff000000):Void {
		if (parent != null) { return parent.drawRect(x + this.x, y + this.y, width, height, ch, fg, bg); }
		for (drawY in y...y + height) {
			var index:Int = getIndex(x, drawY);
			for (drawX in 0...width) {
				setTile(index++, ch, fg, bg);
			}
		}
	}
	
	/**
	 * Return the 1D index on this console from the 2D coords at x,y
	 */
	private inline function getIndex(x:Int, y:Int):Int {
		return y * width + x;
	}
	
	/**
	 * Try to return the fastest renderer for this console.
	 * Most of the renderers are for bechmarking and testing,
	 * this function should always get the best one for the platform you're on.
	 */
	public function getFastRenderer(font:ConsoleFont, ?stage:Stage):DisplayObject {
		#if flash
		if (stage != null) {
			return new ConsoleRenderShader(this, font, stage.stage3Ds[0]);
		}else {
			return new ConsoleRenderTiles(this, font);
		}
		#elseif js
		return new ConsoleRenderTiles(this, font);
		#else
		return new ConsoleRenderBitmap(this, font);
		#end
	}
	
}