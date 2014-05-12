package nethaxe.console;

/**
 * ...
 * @author Kyle Stewart
 */
class VirtualCursor
{
	private var console:Console;
	
	public var x:Int;
	public var y:Int;
	
	public var printX:Int=0;
	public var printY:Int=0;

	public function new(console:Console, x:Int=0, y:Int=0) 
	{
		this.console = console;
		move(x, y);
	}
	
	
	public inline function move(x:Int, y:Int):Void {
		this.x = x;
		//trueX = x;
		this.y = y;
		//trueY = x;
	}
	
	/**
	 * Advance the cursor a single step
	 */
	public inline function step():Void {
		normalize();
		x++;
	}
	
	public inline function newline():Void {
		x = 0;
		y++;
	}
	
	public inline function normalize():Void {
		while (x >= console.width) {
			x -= console.width;
			y++;
		}
	}
	
}