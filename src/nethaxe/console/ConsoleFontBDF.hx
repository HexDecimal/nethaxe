package nethaxe.console;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.Vector.Vector;
import haxe.io.Bytes;
import haxe.io.BytesData;

using StringTools;
using Std;
/**
 * ...
 * @author Kyle Stewart
 */
class ConsoleFontBDF extends ConsoleFont
{
	
	private var bdfIter:Iterator<String>;
	private var bdfLines:Array<String>;
	private var bdfIndex:Int = 0;

	public function new(bdfData:BytesData) 
	{
		
		bdfLines = StringTools.replace(StringTools.replace(bdfData.toString(), '\r\n', '\n'), '\r', '\n').split('\n');
		bdfIndex = 0;
		parse(bdfIter);
		super();
	}
	
	private function bdfNext():String {
		return bdfLines[bdfIndex++];
	}
	
	private function bdfHasNext():Bool {
		return bdfIndex < bdfLines.length;
	}
	
	private function parse(iter:Iterator<String>):Void {
		if (bdfNext() != 'STARTFONT 2.1') { throw "Invalid BDF data, bad STARTFONT"; }
		while (bdfHasNext()) { parseLine(); };
	}
	
	private function parseLine():Void {
		var str:String = bdfNext();
		
		if (str.lastIndexOf('STARTCHAR', 0) == 0) {
			parseChar();
		}else if (str.lastIndexOf('FONTBOUNDINGBOX', 0) == 0) {
			var args:Array<String> = str.split(' ');
			glyphWidth = Std.parseInt(args[1]);
			glyphHeight = Std.parseInt(args[2]);
			//_bitmapVectorCache = new Vector.<uint>(_tileHeight * _tileWidth)
		}
	}
	
	// parse an entire character
	private function parseChar():Void {
		var args:Array<String>;
		var char:Int=0;
		var width:Int=0;
		var height:Int=0;
		var x:Int=0;
		var y:Int=0;
		while (true) {
			var str:String = bdfNext();
			if (str.lastIndexOf('ENCODING', 0) == 0) {
				args = str.split(' ');
				char = Std.parseInt(args[1]); // get character code
			}else if (str.lastIndexOf('BBX', 0) == 0) { // bounding box (w, h, x, y)
				args = str.split(' ');
				width = Std.parseInt(args[1]);
				height = Std.parseInt(args[2]);
				x = Std.parseInt(args[3]);
				y = Std.parseInt(args[4]);
				//_bbox.setTo(parseInt(args[3]), parseInt(args[4]), parseInt(args[1]), parseInt(args[2]));
			}else if(str.lastIndexOf('BITMAP', 0) == 0){
				parseBitmap(char, width, height, x, y);
			}else if (str.lastIndexOf('ENDCHAR', 0) == 0) {
				break;
			}
		}
	}
	
	private function parseBitmap(char:Int, width:Int, height:Int, x:Int, y:Int):Void {
		var bitmapVectorCache:Vector<UInt> = new Vector<UInt>();
		var i:Int = 0;
		for (y in 0...height) {
			var bdfLine:String = bdfNext();
			var hexdec:Int=0;
			var bit:Int = -1;
			for (x in 0...width) {
				if (bit == -1) {
					bit = 3;
					
					hexdec = Std.parseInt('0x' + bdfLine.charAt(Math.floor(x / 4)));
				}
				bitmapVectorCache.push(hexdec & (1 << bit--) != 0?0xffffffff:0x00000000);
			}
		}
		var bitmap:BitmapData = new BitmapData(glyphWidth, glyphHeight, true, 0x00000000);
		
		bitmap.setVector(new Rectangle(0, 0, width, height), bitmapVectorCache);
		setGlyphWithBitmap(char, bitmap);
			
	}
	/*
		
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
		}*/
	
	private function nextLine():String {
		return bdfLines[bdfIndex++];
	}
	
}