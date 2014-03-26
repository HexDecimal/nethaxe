package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import net.hires.debug.Stats;
	import rogueutil.console.ConsoleBitmapRender;
	import rogueutil.console.ConsoleData;
	import rogueutil.console.ConsoleRender;
	
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class StressTest extends Sprite 
	{
		
		protected var _cData:ConsoleData
		
		public function StressTest() 
		{
			super();
			
			addEventListener(Event.EXIT_FRAME, step)
			
			_cData = new ConsoleData(120, 60)
			
			//addChild(new ConsoleRender(_cData, Assets.loadBDF(Assets.bdf6x13)))
			addChild(new ConsoleBitmapRender(_cData, Assets.loadBDF(Assets.bdf6x13)))
			
			addChild(new Stats())
		}
		
		private function step(e:Event):void {
			for (var y:int = _cData.height - 1 ; y >= 0; y-- ) {
				for (var x:int = _cData.width - 1; x >= 0; x-- ) {
					_cData.setColor(0xffffff * Math.random(), 0xffffff * Math.random())
					_cData.drawChar(x, y, Math.random() * 256)
				}
			}
		}
		
		private function keydown(e:KeyboardEvent):void {
			
		}
		
		
	}

}