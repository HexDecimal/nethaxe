package rogueutil.console 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author 
	 */
	public class ConsoleFontBDF extends ConsoleFont 
	{
		private var _bitmapVectorCache:Vector.<uint>
		
		/**
		 * Iterator for thr BDF file
		 */
		private var _file:LineIterator
		
		private var _bbox:Rectangle = new Rectangle()
		
		public function ConsoleFontBDF(bdfData:ByteArray)
		{
			init(bdfData)
		}
		
		private function init(bdfData:ByteArray):void {
			_tileHeight = 0
			_tileWidth = 0
			
			var loops:int = 1 // used for profiling
			while (loops--) {
				bdfData.position = 0
				//var iter:LineIterator = new LineIterator(bdfData.readUTFBytes(bdfData.bytesAvailable))
				_file = new LineIterator(bdfData.readUTFBytes(bdfData.bytesAvailable))
				
				if (_file.next().toUpperCase() != 'STARTFONT 2.1') {
					throw new Error("Invalid BDF data, bad STARTFONT")
				}
			
				//var startTime:int = getTimer()
				
				// BUG For some weird reason the lazy parsing fails without reading these 5 lines first
				var preInitLines:int = 5
				while(preInitLines--){
					parseNext()
				}
				//trace('parse time is', getTimer() - startTime, 'ms')
			}
		}
		
		private function parseAll():void {
			while (parseNext()){}
		}
		
		private function parseNext():Boolean {
			var args:Array
			if(!_file.hasNext()){return false}
			var str:String = _file.next()//bdfLines.pop()//bdfLines[index]
			if (str.lastIndexOf('STARTCHAR', 0) == 0) { parseChar()
			}else if (str.lastIndexOf('FONTBOUNDINGBOX', 0) == 0) {
				args = str.split(' ')
				_tileWidth = int(args[1])
				_tileHeight = int(args[2])
				_bitmapVectorCache = new Vector.<uint>(_tileHeight * _tileWidth)
			
			//}else if (str.lastIndexOf('FONT', 0) == 0) {
				
			//}else if (str.lastIndexOf('CHARSET_REGISTRY', 0) == 0) {
			//}else if (str.lastIndexOf('CHARSET_ENCODING', 0) == 0) {
			//}else if (str.lastIndexOf('CHARS', 0) == 0) {
				//args = str.split(' ')
				//trace(args[1], 'characters total')
					
			//}else if (str.lastIndexOf('COMMENT', 0) == 0) { trace.apply(null, args.slice(1))
			//}else if (str.lastIndexOf('STARTPROPERTIES', 0) == 0) {
				
			//}else if (str.lastIndexOf('ENDFONT', 0) == 0) { return // End of font
			}
			return true
		}
		
		private function parseProperties(props:int):void {
			var args:Array
			while (props--) {
				args = _file.next().split(' ')
				//trace('Prop', args[0], 'is', args[1])
			}
			if (_file.next() != 'ENDPROPERTIES') {
				throw new Error('Property data invalid')
			}
		}
		
		private function parseChar():void {
			var args:Array
			var char:int
			//var bbox:Rectangle = new Rectangle()
			while (_file.hasNext()) {
				
				//args = bdfLines.pop().split(' ')
				var str:String = _file.next()
				if (str.lastIndexOf('ENCODING', 0) == 0) {
					args = str.split(' ')
					char = args[1] // get character code
				}else if (str.lastIndexOf('BBX', 0) == 0) { // bounding box (w, h, x, y)
					args = str.split(' ')
					_bbox.setTo(int(args[3]), int(args[4]), int(args[1]), int(args[2]))
				}else if(str.lastIndexOf('BITMAP', 0) == 0){
					parseBitmap(char)
				}else if (str.lastIndexOf('ENDCHAR', 0) == 0) {
					return
				}else {
					//trace("Ignored arg ", args[0])
				}
			}
		}
		
		private function parseBitmap(char:int):void {
			var scanlines:int = _bbox.height
			var width:int = _bbox.width
			//var bitmapVector:Vector.<uint> = new Vector.<uint>(width * scanlines)
			//var bitmapVector:Vector.<uint> = _bitmapVectorCache
			var bitmap:BitmapData = new BitmapData(_tileWidth, _tileHeight, true, 0x00ffffff)
			var i:int=0
			for (var y:int; y < scanlines; y++ ) {
				// moved inline for performance
				var bdfLine:String = _file.next()
				var hexdec:int
				var bit:int=-1
				for (var x:int = 0; x < width; x++ ) {
					// tons of optimization done here
					if (bit == -1) {
						bit = 3
						hexdec = parseInt(bdfLine.charAt(int(x / 4)), 16)
					}
					_bitmapVectorCache[i++] = hexdec & (1 << bit--)?0xffffffff:0x00ffffff
				}
			}
			_bbox.x = 0
			_bbox.y = 0
			bitmap.setVector(_bbox, _bitmapVectorCache)
			setGlyph(char, bitmap)
		}
		
		override protected function lazyGenerateGlyph(index:int):void  {
			index &= 0x1ffff // remove special bits
			if (_glyphStatus[index] != 0) { return } // glyph already generated or does not exist
			while (parseNext()) {
				if (_glyphStatus[index] != 0) { return } // glyph found in BDF
			}
			_glyphStatus[index] = -1 // glyph not in BDF
		}
	}

}

class LineIterator {
	private var _array:Array
	private var _index:int
	private var _length:int
	
	public function LineIterator(str:String) {
		_array = str.replace('\r\n', '\n').replace('\r', '\n').split('\n')
		_index = 0
		_length = _array.length
	}
	
	public function next():String {
		return _array[_index++]
	}
	
	public function hasNext():Boolean {
		return(_index != _length)
	}
	
	public function empty():Boolean {
		return(_index == _length)
	}
}