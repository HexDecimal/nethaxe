package rogueutil.console {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class ConsoleFont {
		
		//protected var _bitmapCache:BitmapData
		protected var _tileWidth:int
		protected var _tileHeight:int
		
		//protected var _glyphsPerBitmap:int = 256;
		
		protected var _bitmapCache:Vector.<BitmapData> = new Vector.<BitmapData>(256)
		
		/**
		 * glyph status
		 * 0 = not generated
		 * 1+ = index in the cache
		 * -1 = does not exist
		 */
		protected var _glyphStatus:Vector.<int> = new Vector.<int>(0x10000)
		private var _glyphs:Vector.<BitmapData> = new Vector.<BitmapData>(0x10000)
		
		protected var _columns:int;
		protected var _rows:int;
		
		public function ConsoleFont() {
		}
		
		private function waste1d(range:int):int {
			return Math.pow(2, Math.ceil(Math.log(range) / Math.LN2)) - range
		}
		
		protected function wasteAtSize(width:int, height:int):int {
			var hozWaste:int = waste1d(width)
			var verWaste:int = waste1d(height)
			return width * verWaste + height * hozWaste + hozWaste * verWaste
		}
		
		private function wasteFromArrangement(rows:int, columns:int, tileWidth:int, tileHeight:int):int {
			return wasteAtSize(columns * tileWidth, rows * tileHeight)
		}
		
		/** prepare the best arrangement of tiles, sets the cache size
		 */
		protected function configureBestArrangement(tiles:int, tileWidth:int, tileHeight:int):void {
			var bestWaste:int = int.MAX_VALUE
			var bestAwnser:int = Math.floor(tiles/2)
			for (var columns:int = 1; columns <= tiles; columns++) {
				var waste:int = wasteFromArrangement(int(tiles / columns), columns, tileWidth, tileHeight)
				if (waste < bestWaste) {
					try { // test to make sure that this kind of bitmap can be made
						new BitmapData(Math.max(int(tiles / columns) * tileWidth, columns * tileHeight), 1)
					}catch (e:Error) {continue} // catch failure and skip this result
					bestWaste = waste
					bestAwnser = columns
				}
			}
			_columns = bestAwnser
			_rows = Math.ceil(tiles / _columns)
			//return bestAwnser
		}
		
		/**
		 * Customizable glyph generator
		 * @param	index charactor code of the glyph to generate
		 * @return the bitmap data of the glyph, null or all 0x00000000 then the glyph is marked as not existing
		 */
		protected function generateGlyph(index:int):BitmapData {
			return null
		}
		
		/**
		 * Force the glyphs at this range to be generated now rather than automatically later.
		 * @param	startIndex
		 * @param	range
		 */
		public function forceCache(startIndex:int, range:int):void {
			var endIndex:int = startIndex + range
			for (var i:int = startIndex; i < endIndex; i++ ) {
				lazyGenerateGlyph(i)
			}
		}
		
		/**
		 * Check if this glyph exists.  And isn't blank.
		 * This will try to generate the glyph to find this information, sometimes taking up extra time and memory.
		 * @param	index charactor code of the glyph
		 * @return true if the glyph can be gotten from this object, flase of the glyph is blank (such as the space glyph)
		 */
		public function glyphExists(index:int):Boolean {
			index &= 0xffff // remove special bits
			lazyGenerateGlyph(index)
			return _glyphStatus[index] > 0
		}
		
		public function setGlyph(index:int, glyph:BitmapData):void {
			if (glyph.width != _tileWidth || glyph.height != _tileHeight) { throw new Error("bitmapData does not match tile size") }
			_glyphStatus[index] = index
			_glyphs[index] = glyph
		}
		
		protected function isBitmapBlank(bitmapData:BitmapData):Boolean {
			var bitmapVector:Vector.<uint> = bitmapData.getVector(bitmapData.rect)
			var len:int = bitmapVector.length
			for (var i:int; i < len; i++ ) {
				if (bitmapVector[i] != 0x00000000) { return false }
			}
			return true
		}
		
		private function lazyGenerateGlyph(index:int):void {
			index &= 0xffff // remove special bits
			if (_glyphStatus[index] != 0) { return } // glyph already generated or does not exist
			
			var glyph:BitmapData = generateGlyph(index)
			if (glyph == null) { _glyphStatus[index] = -1; return} // generator returned null
			if (glyph.width != _tileWidth || glyph.height != _tileHeight) {
				throw new Error("Glyph generator is making bitmaps of the wrong size")
			}
			if (isBitmapBlank(glyph)) { _glyphStatus[index] = -1; return } // glyph is blank
			
			// actually configure this glyph
			setGlyph(index, glyph)
		}
		
		/**
		 * Width of each tile
		 */
		public function get tileWidth():int {
			return _tileWidth
		}
		
		/**
		 * Height of each tile
		 */
		public function get tileHeight():int {
			return _tileHeight
		}
		
		protected function get _cacheWidth():int {
				return _columns * _tileWidth
		}
		
		protected function get _cacheHeight():int {
				return _rows * _tileHeight
		}
		
		public function getGlyph(index:int):BitmapData {
			lazyGenerateGlyph(index)
			index &= 0xffff
			return _glyphs[index]
		}
	}

}