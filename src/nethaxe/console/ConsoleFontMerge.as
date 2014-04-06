package rogueutil.console 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author 
	 */
	public class ConsoleFontMerge extends ConsoleFont 
	{
		
		private var fontArray:Vector.<ConsoleFont>
		
		public function ConsoleFontMerge(...args) 
		{
			super();
			init.apply(null, args)
		}
		
		private function init(...args):void {
			fontArray = Vector.<ConsoleFont>(args)
			_tileWidth = fontArray[0].tileWidth
			_tileHeight = fontArray[0].tileHeight
			for (var i:int = 0; i < fontArray.length; i++ ) {
				if (fontArray[i].tileWidth != _tileWidth || fontArray[i].tileHeight != _tileHeight) {
					throw new Error('All fonts must have the same size')
				}
			}
		}
		
		override public function getGlyph(index:int):BitmapData 
		{
			for (var i:int = 0; i < fontArray.length; i++ ) {
				if (fontArray[i].glyphExists(index)) {
					return fontArray[i].getGlyph(index)
				}
			}
			return null;
		}
		override public function glyphExists(index:int):Boolean 
		{
			for (var i:int = 0; i < fontArray.length; i++ ) {
				if (fontArray[i].glyphExists(index)) {
					return true
				}
			}
			return null;
		}
	}

}