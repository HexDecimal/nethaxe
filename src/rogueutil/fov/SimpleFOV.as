package rogueutil.fov 
{
	import rogueutil.line.Bresenham;
	import rogueutil.line.DigitalLine;
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class SimpleFOV extends FOV 
	{
		
		public function SimpleFOV() 
		{
			super();
			
		}
		
		override protected function computeOctant():void {
			var x:int = _radiusI - 1
			var y:int
			// raycast to the the edge of the field
			for (y = x; y >= 0; y-- ) {
				Bresenham.plot(0, 0, x, y, plot)
			}
			
			// follow up with adaptive raycasting
			var endX:int = _radiusI - 1
			for (x = 1; x < endX; x++) {
				for (y = 0; y <= x; y++) {
					if (getLocalVisible(x, y) || !inRadius(x, y)) { continue }
					if (getLocalVisible(x - 1, y) || (y && getLocalVisible(x, y - 1))) {
						if (Bresenham.plot(0, 0, x, y, plotIsClear)) {
							setLocalVisible(x, y, true)
						}
					}
				}
			}
		}
		
		private function plot(x:int, y:int, index:int):Boolean {
			if (!inRadius(x, y) || !getMapVisible(x, y)) { return true }
			setLocalVisible(x, y, true)
			return false
		}
		
		private function plotIsClear(x:int, y:int, index:int):Boolean {
			return !getMapVisible(x, y)
		}
	}

}