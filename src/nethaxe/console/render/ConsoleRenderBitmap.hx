package nethaxe.console.render;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author Kyle Stewart
 */
class ConsoleRenderBitmap extends Bitmap implements ConsoleRender
{

	public var consoleData(default, null):Console;
	public var consoleFont(default, null):ConsoleFont;
	
	private var bgBitmap:BitmapData;
	
	public function new(consoleData:Console, consoleFont:ConsoleFont) 
	{
		this.consoleData = consoleData;
		this.consoleFont = consoleFont;
		
		//bgBitmap = new BitmapData(consoleData.width, consoleData.height);
		//super();
		super(new BitmapData(consoleData.width * consoleFont.glyphWidth,
		                     consoleData.height * consoleFont.glyphHeight, true, 0x00000000), PixelSnapping.AUTO, false);
		addEventListener(Event.ENTER_FRAME, refresh, false, 0, true);
	}
	
	private function refresh(?e:Dynamic):Void {
		//bgBitmap.setVector(bgBitmap.rect, consoleData.bg);
		var tex:BitmapData = consoleFont.getTexture();
		var rect:Rectangle = new Rectangle(0, 0, consoleFont.glyphWidth, consoleFont.glyphHeight);
		var point:Point = new Point();
		var matrix:Matrix = new Matrix();
		var color:ColorTransform = new ColorTransform();
		var i:Int = 0;
		for (y in 0...consoleData.height) {
			rect.y = y * consoleFont.glyphHeight;
			point.y = rect.y;
			for (x in 0...consoleData.width) {
				rect.x = x * consoleFont.glyphWidth;
				point.x = rect.x;
				//bitmapData.fillRect(rect, consoleData.bg[i]);
				var glyph:Int = consoleFont.getGlyphStatus(consoleData.ch[i]);
				if (glyph >= 0) {
					bitmapData.copyPixels(tex, consoleFont.getTexureRect(glyph), point, null, null, false);
					color.redOffset = consoleData.bg[i] >> 16 & 0xff;
					color.greenOffset = consoleData.bg[i] >> 8 & 0xff;
					color.blueOffset = consoleData.bg[i] & 0xff;
					color.redMultiplier = (consoleData.fg[i] >> 16 & 0xff) / 0xff;
					color.greenMultiplier = (consoleData.fg[i] >> 8 & 0xff) / 0xff;
					color.blueMultiplier = (consoleData.fg[i] & 0xff) / 0xff;
					bitmapData.colorTransform(rect, color);
					//var gRect:Rectangle = consoleFont.getTexureRect(glyph);
					//matrix.tx = rect.x - gRect.x;
					//matrix.ty = rect.y - gRect.y;
					//graphics.beginBitmapFill(consoleFont.getTexture(), matrix, false, false);
					//graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					//graphics.endFill();
				}else {
					bitmapData.fillRect(rect, consoleData.bg[i]);
				}
				i++;
			}
		}
		
	}
	
}
