package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	import rogueutil.console.ConsoleData;
	import rogueutil.console.ConsoleFont;
	import rogueutil.console.ConsoleFontBDF;
	import rogueutil.console.ConsoleRender;
	import rogueutil.fov.FOV;
	import rogueutil.fov.PermissiveShadowcastFOV;
	import rogueutil.line.Bresenham;
	import rogueutil.line.DigitalLine;
	import rogueutil.line.PreciseAngle;
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class LineTest extends Sprite
	{
		
		protected var _font:ConsoleFont
		protected var _cData:ConsoleData
		protected var _cells:Vector.<int>
		protected var _width:int
		protected var _height:int
		protected var _actorX:int
		protected var _actorY:int
		
		public function LineTest() 
		{
			init()
		}
		
		private function init():void {
			_width = 80
			_height = 40
			_cData = new ConsoleData(_width, _height)
			_font = new ConsoleFontBDF(new Assets.bdf10x20())
			addChild(new ConsoleRender(_cData, _font))
			
			addEventListener(Event.EXIT_FRAME, update)
			addEventListener(MouseEvent.CLICK, click)
			
			_cells = new Vector.<int>(_width * _height)
			var x:int
			var y:int
			var barray:ByteArray = ByteArray(new Assets.arena())
			while (barray.bytesAvailable) {
				var char:String = barray.readUTFBytes(1)
				if (char == '\n') {
					y++
					x = 0
					continue
				}else if (char == ' ') {
					_cells[index(x, y)] = 0
				}else if (char == '#') {
					_cells[index(x, y)] = 1
				}
				x++
			}
		}
		
		private function index(x:int, y:int):int {
			return y * _width + x
		}
		
		private function click(e:MouseEvent):void {
			_actorX = mouseCellX
			_actorY = mouseCellY
		}
		
		private function update(e:Event):void {
			var fov:FOV = new PermissiveShadowcastFOV()
			fov.computeFOV(mouseCellX, mouseCellY, 20, isTransparent)
			for (y = _height - 1; y >= 0; y-- ) {
				for (x = _width - 1; x >= 0; x-- ) {
					_cData.setColor(0xffffff, fov.isVisible(x, y)?0x888800:0x000088)
					_cData.drawChar(x, y, _cells[index(x,y)]?'#'.charCodeAt():0x20)
				}
			}
			//DigitalLine.plot(_actorX, _actorY, mouseCellX, mouseCellY, plotLine)
			PreciseAngle.plot(_actorX, _actorY, mouseCellX, mouseCellY, plotLine)
		}
		
		private function plotLine(x:int, y:int, index:int, line:int=0):Boolean {
			_cData.bgColor.setPixel(x, y, 0x008888)
			return !isTransparent(x, y)
		}
		
		private function inBounds(x:int, y:int):Boolean {
			return (0 <= x && 0 <= y && x < _width && y < _height)
		}
		
		private function isTransparent(x:int, y:int, index:int = 0):Boolean {
			return inBounds(x, y) && !_cells[this.index(x,y)]
		}
		
		private function get mouseCellX():int {
			return mouseX / _font.tileWidth
		}
		
		private function get mouseCellY():int {
			return mouseY / _font.tileHeight
		}
		
	}

}