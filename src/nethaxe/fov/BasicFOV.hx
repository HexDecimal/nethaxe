package nethaxe.fov;
import nethaxe.line.Bresenham;

/**
 * ...
 * @author Kyle Stewart
 */
class BasicFOV extends FOV
{

	public function new() 
	{
		super();
		
	}
	
	override private function computeQuadrant():void {
		var x:Int = _radiusI - 1
		var y:Int
		// raycast to the the edge of the field
		for (i in 0...x) {
			Bresenham.plot(0, 0, x, i, plot)
		}
		
		// follow up with adaptive raycasting
		var endX:int = _radiusI - 1
		//for (x = 1; x < endX; x++) {
		for (x in 1...endX) {
			//for (y = 0; y <= x; y++) {
			for(y in 0...(x+1)){
				if (getLocalVisible(x, y) || !inLocalRadius(x, y)) { continue }
				if (getLocalVisible(x - 1, y) || (y && getLocalVisible(x, y - 1))) {
					if (Bresenham.plot(0, 0, x, y, plotIsClear)) {
						setLocalVisible(x, y, true)
					}
				}
			}
		}
	}
	
	private function plot(x:Int, y:Int, ?_:Int):Bool {
		if (!inLocalRadius(x, y) || !getLocalMapTransparency(x, y)) { return false }
		setLocalVisible(x, y, true)
		return true
	}
	
	private function plotIsClear(x:Int, y:Int, ?_:Int):Bool {
		return getLocalTransparency(x, y)
	}
	
}