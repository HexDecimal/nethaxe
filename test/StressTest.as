package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import net.hires.debug.Stats;
	import rogueutil.console.ConsoleBitmapRender;
	import rogueutil.console.ConsoleBlendMode;
	import rogueutil.console.ConsoleData;
	import rogueutil.console.ConsoleFont;
	import rogueutil.console.ConsoleRender;
	
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class StressTest extends Sprite 
	{
		
		protected var _cData:ConsoleData
		protected var _font:ConsoleFont
		
		public function StressTest() 
		{
			super();
			
			addEventListener(Event.EXIT_FRAME, step)
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keydown)
			stage.scaleMode = StageScaleMode.NO_SCALE
			stage.align = StageAlign.TOP_LEFT
			
			_cData = new ConsoleData(160, 80)
			_font = Assets.loadBDF(Assets.bdf6x13)
			
			//addChild(new ConsoleRender(_cData, _font))
			addChild(new ConsoleBitmapRender(_cData, _font))
			
			addChild(new Stats())
		}
		
		private var _randomCh:Boolean = true
		private var _randomFG:Boolean
		private var _randomBG:Boolean
		
		
		private function step(e:Event):void {
			//_cData.setBlendMode(ConsoleBlendMode.BlendAlpha)
			//_cData.fgColor.lock()
			
			if(_randomCh){
				for (var y:int = _cData.height - 1 ; y >= 0; y-- ) {
					for (var x:int = _cData.width - 1; x >= 0; x-- ) {
						//_cData.setColor(0xffffffff * Math.random(), 0xffffffff * Math.random())
						_cData.drawChar(x, y, Math.random() * 256)
					}
				}
			}
			if(_randomFG){
				_cData.fgColor.noise(int.MAX_VALUE * Math.random(), 0x80, 0xff)
			}
			if(_randomBG){
				_cData.bgColor.noise(int.MAX_VALUE * Math.random(), 0x00, 0x20)
			}
			
		}
		
		private function keydown(e:KeyboardEvent):void {
			if (e.keyCode == 'Z'.charCodeAt()) {
				_randomCh = !_randomCh
			}
			if (e.keyCode == 'X'.charCodeAt()) {
				_randomFG = !_randomFG
			}
			if (e.keyCode == 'C'.charCodeAt()) {
				_randomBG = !_randomBG
			}
		}
		
		
	}

}