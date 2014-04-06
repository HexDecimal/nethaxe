package nethaxe.console;

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
	
	public inline function getIndex(x:Int, y:Int):Int {
		return (y * width + x);
	}
	
}