package rogueutil.console 
{
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author 
	 */
	public class ConsoleFontRasterized extends ConsoleFont 
	{
		//private var _font:Font
		private var _textField:TextField
		
		private var _elementFormat:ElementFormat
		private var _textBlock:TextBlock
		//private var _generated:Vector.<int>
		//private var _bitmapCache:Vector.<BitmapData>
		private var _quality:String
		
		public function ConsoleFontRasterized(font:String='_typewriter', size:int=8, fontHeight:int=-1, quality:String=StageQuality.HIGH_16X16)
		{
			init(font, size, fontHeight, quality)
		}
		
		private function init(font:String, size:int, fontHeight:int, quality:String):void {
			_quality = quality
			_elementFormat = new ElementFormat(new FontDescription(font), size, 0xffffff)
			var textElement:TextElement = new TextElement(null, _elementFormat)
			_textBlock = new TextBlock(textElement)
			
			if (fontHeight == -1) {
				// Guess the height, not sure who to ust font metrics to just use something that works at the moment.
				fontHeight = Math.floor(_elementFormat.getFontMetrics().emBox.height * 2)
			}
			
			
			_textField = new TextField()
			_textField.defaultTextFormat = new TextFormat(font, size, 0xffffff)
			_textField.antiAliasType = AntiAliasType.ADVANCED
			//trace(_textField.defaultTextFormat.font)
			
			_tileWidth = size
			_tileHeight = fontHeight
			
			//configureBestArrangement(256, _tileWidth, _tileHeight)
			//_columns = getBestArrangement(256, _tileWidth, _tileHeight)
			//_rows = Math.ceil(256 / _columns)
			//_bitmapCache = new Vector.<BitmapData>(256)
			//_generated = new Vector.<int>(65536)
			//new TextFormat()
			
		}
		
		override protected function generateGlyph(index:int):BitmapData
		{
			//trace("Generate", String.fromCharCode(index), index, "on block", blockIndex, _bitmapCache[blockIndex])
			
			if (0xD800 <= index && index < 0xE000) {
				return null // Surrogates will throw an error, so ignore them
			}
			
			var textElement:TextElement = new TextElement(String.fromCharCode(index), _elementFormat)
			var textBlock:TextBlock = new TextBlock(textElement)
			var textLine:TextLine = textBlock.createTextLine(null, 0, 0, true)
			if (textLine == null) {
				//trace(index, "is null")
				return null
			}
			
			var bitmap:BitmapData = new BitmapData(_tileWidth, _tileHeight, true, 0x00000000)
			//_textField.text = String.fromCharCode(index)
			bitmap.drawWithQuality(textLine, new Matrix(1, 0, 0, 1, 0, -_elementFormat.getFontMetrics().emBox.y),
			                       null, null, new Rectangle(0, 0, _tileWidth, _tileHeight), false, _quality)
			return bitmap
		}
		
		
	}

}