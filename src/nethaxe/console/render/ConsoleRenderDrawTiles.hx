package nethaxe.console.render;

import flash.display.Sprite;
import flash.events.Event;
import openfl.display.Tilesheet;

/**
 * ...
 * @author Kyle Stewart
 */
class ConsoleRenderDrawTiles extends Sprite implements ConsoleRender
{

	public var consoleData(default, null):Console;
	public var consoleFont(default, null):ConsoleFont;
	
	private var tileArray:Array<Float>;
	
	public function new(consoleData:Console, consoleFont:ConsoleFont) 
	{
		super();
		this.consoleData = consoleData;
		this.consoleFont = consoleFont;
		
		tileArray = [for (i in 0...(consoleData.width * consoleData.height * 6)) 0];
		
		addEventListener(Event.ENTER_FRAME, refresh, false, 0, true);
	}
	
	private function refresh(?e:Dynamic):Void {
		var i:Int=0;
		var arrayI:Int=0;
		for (y in 0...consoleData.height) {
			for (x in 0...consoleData.width) {
				var glyph:Int = consoleFont.getGlyphStatus(consoleData.ch[i]);
				tileArray[arrayI++] = x * consoleFont.glyphWidth;
				tileArray[arrayI++] = y * consoleFont.glyphHeight;
				tileArray[arrayI++] = glyph;
				tileArray[arrayI++] = 1;
				tileArray[arrayI++] = 1;
				tileArray[arrayI++] = 1;
				i++;
			}
		}
		graphics.clear();
		consoleFont.tileSheet.drawTiles(graphics, tileArray, false, Tilesheet.TILE_RGB);
		
		/*
		var tex:BitmapData = consoleFont.getTexture();
		var rect:Rectangle = new Rectangle(0, 0, consoleFont.glyphWidth, consoleFont.glyphHeight);
		//var point:Point = new Point();
		var matrix:Matrix = new Matrix();
		var i:Int = 0;
		for (y in 0...consoleData.height) {
			rect.y = y * consoleFont.glyphHeight;
			//point.y = rect.y;
			for (x in 0...consoleData.width) {
				rect.x = x * consoleFont.glyphWidth;
				//point.x = rect.x;
				graphics.beginFill(consoleData.bg[i]);
				graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				graphics.endFill();
				var glyph:Int = consoleFont.getGlyphStatus(consoleData.ch[i]);
				if (glyph >= 0) {
					var gRect:Rectangle = consoleFont.getTexureRect(glyph);
					matrix.tx = rect.x - gRect.x;
					matrix.ty = rect.y - gRect.y;
					graphics.beginBitmapFill(consoleFont.getTexture(), matrix, false, false);
					graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					graphics.endFill();
				}
				i++;
			}
		}
		*/
	}
	
}