package rogueutil.console
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class ConsoleFontBitmap extends ConsoleFont
	{
		
		public function ConsoleFontBitmap(bitmapData:BitmapData, tileWidth:int, tileHeight:int) 
		{
			init(bitmapData, tileWidth, tileHeight)
		}
		
		private function init(bitmapData:BitmapData, tileWidth:int, tileHeight:int):void {
			_tileWidth = tileWidth
			_tileHeight = tileHeight
			bitmapData = processBitmapData(bitmapData)
			var coloums:int = bitmapData.width / tileWidth
			var rows:int = bitmapData.height / tileHeight
			for (var y:int = 0; y < rows; y++ ) {
				for (var x:int = 0; x < coloums; x++) {
					var charData:BitmapData = new BitmapData(tileWidth, tileHeight, true)
					charData.copyPixels(bitmapData, new Rectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight), new Point(0, 0))
					setGlyph(x + y * coloums, charData)
				}
			}
			/*
			//trace("Waste per glyph", wasteAtSize(_tileWidth, _tileHeight))
			//_bitmapCache[0] = processBitmapData(bitmapData)
			//_columns = bitmapData.width / tileWidth
			//_rows = bitmapData.height / tileHeight
			//_glyphsPerBitmap = _columns * _rows
			for (var i:int = 0; i < _glyphsPerBitmap; i++ ) {
				// if a glyph is blank its status is set to -1 for better performance
				_glyphStatus[i] = i // set status first so that the glyph can assume to exist
				var bitmapVector:Vector.<uint> = _bitmapCache[0].getVector(getGlyphRect(i))
				if (!bitmapVector.some(isNonZeroVector)) {
					_glyphStatus[i] = -1 // glyph is blank
				}
			}*/
		}
		
		private function processBitmapData(bitmapData:BitmapData):BitmapData {
			var newBitmap:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, true)
			var colorData:Vector.<uint> = bitmapData.getVector(bitmapData.rect)
			var transparent:Boolean = false
			var color:Boolean = false
			var i:int
			var len:int = colorData.length
			for (i=0; i < len; i++) {
				if (colorData[i] & 0xff000000 < 0xff000000) {
					transparent = true
					break
				}
			}
			for (i=0; i < len; i++) {
				if ((colorData[i] & 0xff) != (colorData[i] >> 16 & 0xff) ||
				    (colorData[i] & 0xff) != (colorData[i] >> 8 & 0xff)){
					color = true
					break
				}
			}
			if(!transparent && !color){ // greyscale to alpha
				for (i=0; i < len; i++) {
					colorData[i] = ((colorData[i] & 0x00ff0000) << 8) | 0x00ffffff
				}
			}
			newBitmap.setVector(newBitmap.rect, colorData)
			return newBitmap
		}
		
	}

}

function isNonZeroVector(i:uint, index:int, vector:Vector.<uint>):Boolean {
	return i != 0
}
