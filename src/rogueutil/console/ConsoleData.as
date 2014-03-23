package rogueutil.console
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	
	 
	
	 
	public class ConsoleData
	{
		private var _width:int
		private var _height:int
		
		private var _fgColor:BitmapData
		private var _bgColor:BitmapData
		
		//private var _fgColorVector:Vector.<uint>
		//private var _bgColorVector:Vector.<uint>
		
		//private var _fgColorVectorMode:Boolean = false
		//private var _bgColorVectorMode:Boolean = false
		
		//private var _currentFont:ConsoleFont
		private var _currentColorFG:uint = 0x00ffffff
		private var _currentColorBG:uint = 0x00000000
		
		private var _blendMode:Function = ConsoleBlendMode.BlendSet
		
		//internal var _fontData:Vector.<ConsoleFont>
		
		internal var _chars:Vector.<int>
		
		public function get width():int {
			return _width
		}
		
		public function get height():int 
		{
			return _height;
		}
		
		public function get rect():Rectangle {
			return new Rectangle(0, 0, _width, _height)
		}
		
		/*public function get tileWidth():int {
			return _currentFont.tileWidth
		}
		
		public function get tileHeight():int {
			return _currentFont.tileHeight
		}*/
		
		public function get fgColor():BitmapData 
		{
			return _fgColor;
		}
		
		public function get bgColor():BitmapData 
		{
			return _bgColor;
		}
		
		public function ConsoleData(width:int, height:int)
		{
			init(width, height)
		}
		
		private function init(width:int, height:int):void {
			_width = width
			_height = height
			_fgColor = new BitmapData(_width, _height, true, 0xffffffff)
			_bgColor = new BitmapData(_width, _height, true, 0xff000000)
			_chars = new Vector.<int>(_width * _height)
			//_fontData = new Vector.<ConsoleFont>(_width * _height)
			//_currentFont = consoleFont
			//_fontWidth = consoleFont.tileWidth
			//_fontHeight = consoleFont.tileHeight
			for (var i:int = 0; i < _width * _height; i++ ) {
				_chars[i] = 0x20
			}	
		}
		
		protected function index(x:int, y:int):int {
			return x + y * _width
		}
		
		/**
		 * Clear this console to white on black spaces.
		 * 
		 * Drawing colors and blend mode will also be reset to defaults.
		 */
		public function clear():void {
			setColor(0xffffffff, 0xff000000)
			setBlendMode(ConsoleBlendMode.BlendSet)
			
			_fgColor.fillRect(_fgColor.rect, 0xffffffff)
			_bgColor.fillRect(_bgColor.rect, 0xff000000)
			for (var i:int = 0; i < _width * _height; i++ ) {
				_chars[i] = 0x20
				//_fontData[i] = null
			}
		}
		
		public function getChar(x:int, y:int):int {
			return _chars[index(x, y)]
		}
		
		public function setColor(fgColor:uint, bgColor:uint):void {
			_currentColorFG = fgColor
			_currentColorBG = bgColor
		}
		
		public function setBlendMode(blendMode:Function):void {
			_blendMode = blendMode
		}
		
		/*
		public function copy(source:ConsoleData, sourceRect:Rectangle, destPoint:Point, characterCopy:Boolean = true,
		                     foregroundCopy:Boolean = true, backgroundCopy:Boolean = true):void {
			//sourceRect = sourceRect.intersection(source.rect).intersection(this.rect)
			if (characterCopy) {
				var endX:int = sourceRect.right
				var endY:int = sourceRect.bottom
				for (var y:int = sourceRect.y; y < endY; y++ ) {
					var sourceI:int = (y + sourceRect.y) * source.width + sourceRect.x
					var destI:int = (y + destPoint.y) * this.width + destPoint.x
					for (var x:int = sourceRect.x; x < endX; x++ ) {
						_chars[destI++] = source._chars[sourceI++]
					}
				}
			}
			if (foregroundCopy) { _fgColor.copyPixels(source.fgColor, sourceRect, destPoint) }
			if (backgroundCopy) { _bgColor.copyPixels(source.bgColor, sourceRect, destPoint) }
		}*/
		
		public function drawChar(x:int, y:int, char:int):void {
			var index:int = index(x, y)
			//_fontData[index] = _currentFont
			_chars[index] = (char < 0 ? 0x20 : char)
			_fgColor.setPixel32(x, y, _blendMode(_currentColorFG, _fgColor.getPixel32(x, y)))
			_bgColor.setPixel32(x, y, _blendMode(_currentColorBG, _bgColor.getPixel32(x, y)))
		}
		
		public function drawRect(rect:Rectangle, char:int):void {
			var right:int = rect.right
			var bottom:int = rect.bottom
			
			for (var y:int = rect.y; y < bottom; y++ ){
				for (var x:int = rect.x; x < right; x++) {
					drawChar(x, y, char)
				}
			}
		}
		
		public function drawStr(x:int, y:int, str:String):void {
			var i:int = 0
			while (i < str.length) {
				while (x >= _width) {
					x -= _width
					y++
				}
				if (y >= _height) {
					return
				}
				if (str.charAt(i) == '\r') {
					x = 0
				}else if (str.charAt(i) == '\n') {
					x = 0
					y++
				}else {
					drawChar(x, y, str.charCodeAt(i))
					x++
				}
				i++
			}
		}
		
	}
}