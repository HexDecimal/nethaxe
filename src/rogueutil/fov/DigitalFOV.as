package rogueutil.fov 
{
	import rogueutil.line.DigitalLine;
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class DigitalFOV extends FOV 
	{
		
		public function DigitalFOV() 
		{
			super();
			
		}
		
		override protected function computeOctant():void {
			var x:int = _radiusI - 1
			var y:int
			// raycast to the the edge of the field
			for (y = x; y >= 0; y-- ) {
				DigitalLine.plot(0, 0, x, y, plot)
			}
			
		}
		
		private function plot(x:int, y:int, index:int, line:int):Boolean {
			if (!inRadius(x, y) || !getMapVisible(x, y)) { return true }
			setLocalVisible(x, y, true)
			return false
		}
	}

}