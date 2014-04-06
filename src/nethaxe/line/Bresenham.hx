package nethaxe.line;

/**
 * ...
 * @author Kyle Stewart
 */
class Bresenham
{
	
	/**
	 * Call func(x:Int, y:Int, index:Int):Bool on every point on this line
	 * The function callback should return true to continue to the next point,
	 * but can return false to cancel the computation early
	 * This function will return false if it was canceled and true otherwise
	 */
	public static function plot(x0:Int, y0:Int, x1:Int, y1:Int, func:Int -> Int -> Int -> Bool):Bool {
			var dx:Int = Math.abs(x1 - x0);
			var dy:Int = Math.abs(y1 - y0);
			var sx:Int = x0 < x1 ? 1 : -1;
			var sy:Int = y0 < y1 ? 1 : -1;
			var err:Int = dx - dy;
			var index:Int = 0;

			while (true){
				if (!func.bind(x0, y0, index++)) { return false; }

				if (x0==x1 && y0==y1)
					break;

				var e2:int = err * 2;
				if (e2 > -dx) {
					err -= dy;
					x0 += sx;
				}
				if (e2 < dx){
					err += dx;
					y0 += sy;
				}
			}
			return true;
		}
	
}