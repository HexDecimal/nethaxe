package rogueutil.console
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.text.engine.TextBlock;
	
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class ConsoleRender extends Sprite 
	{
		private var _consoleData:ConsoleData
		//private var _consoleFont:ConsoleFont
		
		/**
		 * false when this object needs to be rebuilt
		 */
		private var _synchedWithConsoleData:Boolean = false
		
		private var _width:int
		private var _height:int
		private var _length:int
		
		private var _fgColorCopy:Vector.<uint>;
		private var _bgColorCopy:Vector.<uint>;
		private var _charsCopy:Vector.<int>
		private var _fontsCopy:Vector.<ConsoleFont>
		
		private var _fontBitmaps:Vector.<Bitmap>
		
		private var _consoleFont:ConsoleFont
		
		//private var _foregroundBitmap:BitmapData
		//private var _bgBitmapCopy:BitmapData
		
		/**
		 * 
		 * @param	consoleData  
		 * @param	consoleFont
		 */
		public function ConsoleRender(consoleData:ConsoleData, consoleFont:ConsoleFont) 
		{
			super();
			_consoleFont = consoleFont
			this.consoleData = consoleData
			addEventListener(Event.ENTER_FRAME, update, false, 0, true)
			addEventListener(Event.RENDER, update, false, 0, true)
			mouseChildren = false
		}
		
		private function consoleRefresh():void 
		{
			while (numChildren) {
				removeChildAt(numChildren-1)
			}
			_width = consoleData.width
			_height = consoleData.height
			_length = _width * _height
			
			_fgColorCopy = new Vector.<uint>(_length)
			_bgColorCopy = new Vector.<uint>(_length)
			_charsCopy = new Vector.<int>(_length)
			_fontsCopy = new Vector.<ConsoleFont>(_length)
			
			//_bgBitmapCopy = new BitmapData(_width, _height, true)
			
			//var back:Bitmap = new Bitmap(_bgBitmapCopy, "auto", false)
			var back:Bitmap = new Bitmap(consoleData.bgColor, "auto", false)
			back.name = 'Back'
			
			addChildAt(back, 0)
			back.scaleX = _consoleFont.tileWidth
			back.scaleY = _consoleFont.tileHeight
			
			//_foregroundBitmap = new BitmapData(_width * consoleData.tileWidth, _height * consoleData.tileHeight, true, 0x00ffffff)
			
			//var fore:Bitmap = new Bitmap(_foregroundBitmap, "auto", false)
			//fore.visible = false
			//addChildAt(fore, 1)
			
			_fontBitmaps = new Vector.<Bitmap>(_length)
			var i:int=0
			for (var y:int = 0; y < _height; y++ ) {
				for (var x:int = 0; x < _width; x++) {
					_fontBitmaps[i] = new Bitmap()
					_fontBitmaps[i].x = x * _consoleFont.tileWidth
					_fontBitmaps[i].y = y * _consoleFont.tileHeight
					addChild(_fontBitmaps[i])
					i++
				}
			}
			
			_synchedWithConsoleData = true
		}
		
		private function update(e:Event = null):void {
			if(!_synchedWithConsoleData){consoleRefresh()}
			
			//var bgColorVector:Vector.<uint> = consoleData.bgColor.getVector(consoleData.bgColor.rect)
			var fgColorVector:Vector.<uint> = consoleData.fgColor.getVector(consoleData.fgColor.rect)
			
			//var updateBackgroundFlag:Boolean = false
			
			var color:ColorTransform = new ColorTransform()
			
			var chars:Vector.<int> = consoleData._chars
			//var fonts:Vector.<ConsoleFont> = _consoleData._fontData
			
			var i:int
			for (var y:int = 0; y < _height; y++) {
				for (var x:int = 0; x < _width; x++) {
					// moved everything inline for speed
					var glyphSpr:Bitmap = _fontBitmaps[i]
					if (_fgColorCopy[i] != fgColorVector[i]) {
						glyphSpr.visible = (fgColorVector[i] >> 24 & 0xff) != 0
						if (glyphSpr.visible) {
							color.redMultiplier = (fgColorVector[i] >> 16 & 0xff) / 0xff
							color.greenMultiplier = (fgColorVector[i] >> 8 & 0xff) / 0xff
							color.blueMultiplier = (fgColorVector[i] & 0xff) / 0xff
							color.alphaMultiplier = (fgColorVector[i] >> 24 & 0xff) / 0xff
							glyphSpr.transform.colorTransform = color
						}
						_fgColorCopy[i] = fgColorVector[i]
					}
					if(chars[i] != _charsCopy[i]){
						glyphSpr.bitmapData = _consoleFont.getGlyph(chars[i])
						_charsCopy[i] = chars[i]
					}
					/*if(_bgColorCopy[i] != bgColorVector[i]){
						glyphSpr.opaqueBackground = bgColorVector[i]
						_bgColorCopy[i] = bgColorVector[i]
					}*/
					i++
				}
			}
			if(Bitmap(getChildByName('Back')).bitmapData !== consoleData.bgColor){
				Bitmap(getChildByName('Back')).bitmapData = consoleData.bgColor
			}
			//if (updateBackgroundFlag) {
			//	_bgBitmapCopy.copyPixels(consoleData.bgColor, consoleData.bgColor.rect, new Point(0, 0))
			//}
			
		}
		
		public function get consoleData():ConsoleData 
		{
			return _consoleData;
		}
		
		public function set consoleData(value:ConsoleData):void 
		{
			_synchedWithConsoleData = false
			_consoleData = value;
		}
		
		/*public function get consoleFont():ConsoleFont 
		{
			return _consoleFont;
		}
		
		public function set consoleFont(value:ConsoleFont):void 
		{
			_synchedWithConsoleData = false
			_consoleFont = value;
		}*/
		
		
	}

}