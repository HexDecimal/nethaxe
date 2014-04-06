package nethaxe.console;

import flash.display.BitmapData;
import nethaxe.console.ConsoleFont;
/**
 * ...
 * @author Kyle Stewart
 */
class ConsoleFontBitmap extends ConsoleFont
{

	public function new(bitmap:BitmapData, tileWidth:Int, tileHeight:Int) 
	{
		_megaTexColumns = Math.floor(bitmap.width / tileWidth);
		_megaTexRows = Math.floor(bitmap.height / tileHeight);
		
		glyphWidth = tileWidth;
		glyphHeight = tileHeight;
		
		_megaTex = bitmap;
		super();
		for (y in 0..._megaTexRows) {
			for (x in 0..._megaTexColumns) {
				setGlyphDirectly(_nextFreeTex, _nextFreeTex);
				tileSheet.addTileRect(getTexureRect(_nextFreeTex));
				_nextFreeTex++;
			}
		}
	}
	
}