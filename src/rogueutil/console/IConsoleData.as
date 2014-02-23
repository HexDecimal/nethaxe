package rogueutil.console 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Probably won't actally be used
	 * @author Kyle Stewart
	 */
	
	internal interface IConsoleData 
	{
		function get rect():Rectangle
		function get width():int
		function get height():int
		//function get fgColor():BitmapData
		//function get bgColor():BitmapData
		function clear():void
		function copy(source:ConsoleData, sourceRect:Rectangle, destPoint:Point, characterCopy:Boolean = true,
		                     foregroundCopy:Boolean = true, backgroundCopy:Boolean = true):void
		function getChar(x:int, y:int):int
		function setColor(fgColor:uint, bgColor:uint):void
		function drawChar(x:int, y:int, char:int):void
		function drawRect(rect:Rectangle, char:int):void
		function drawStr(x:int, y:int, str:String):void
		
	}
	
}