package rogueutil.console;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
/**
 * ...
 * @author Kyle Stewart
 */
class ConsoleTileRender extends Sprite
{
	
	public var consoleData(default, null):ConsoleData;
	public var consoleFont(default, null):ConsoleFont;
	
	private var _tiles:Array<Bitmap>;

	public function new(consoleData:ConsoleData, consoleFont:ConsoleFont) {
		this.consoleData = consoleData;
		this.consoleFont = consoleFont;
		super();
		
		addEventListener(Event.ENTER_FRAME, refresh, false, 0, true);
		
		_tiles = [for (_ in 0...(consoleData.width * consoleData.height)) new Bitmap()];
		var i:Int = 0;
		for (y in 0...consoleData.height) {
			for (x in 0...consoleData.width) {
				_tiles[i].x = x * consoleFont.glyphWidth;
				_tiles[i].y = y * consoleFont.glyphHeight;
				//_tiles[i].bitmapData = consoleFont.getTexture();
				//_tiles[i].opaqueBackground = 0xff;
				addChild(_tiles[i++]);
			}
		}
	}
	
	private function refresh(?e:Dynamic):Void {
		var rect:Rectangle = new Rectangle(0, 0, consoleFont.glyphWidth, consoleFont.glyphHeight);
		//var point:Point = new Point();
		//var matrix:Matrix = new Matrix();
		var color:ColorTransform = new ColorTransform();
		var i:Int = 0;
		for (y in 0...consoleData.height) {
			//rect.y = y * consoleFont.glyphHeight;
			//point.y = rect.y;
			for (x in 0...consoleData.width) {
				//rect.x = x * consoleFont.glyphWidth;
				//point.x = rect.x;
				//_tiles[i].scrollRect = rect;
				var glyph:BitmapData = consoleFont.getTile(consoleData.ch[i]);
				if (glyph != null) {
					_tiles[i].bitmapData = glyph;
					color.redOffset = consoleData.bg[i] >> 16 & 0xff;
					color.greenOffset = consoleData.bg[i] >> 8 & 0xff;
					color.blueOffset = consoleData.bg[i] & 0xff;
					color.redMultiplier = (consoleData.fg[i] >> 16 & 0xff) / 0xff;
					color.greenMultiplier = (consoleData.fg[i] >> 8 & 0xff) / 0xff;
					color.blueMultiplier = (consoleData.fg[i] & 0xff) / 0xff;
					_tiles[i].transform.colorTransform = color;
					//rect = consoleFont.getTexureRect(glyph);
					//_tiles[i].scrollRect = rect;
				}else {
				
				}
				i++;
			}
		}
		
	}
	
}