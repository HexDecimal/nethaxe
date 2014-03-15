package rogueutil.line 
{
	import flash.geom.Point;
	/**
	 * ...
	 * This is a modified Bresenham implementation from http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
	 * 
	 * @author Kyle Stewart
	 */
	public class Bresenham {
	
		/**
		 * A singleton to reduce allocations when calling getPoints
		 */
		private static var tempPoints:Vector.<Point>
		
		/**
		 * Return the length of a line between thses two points
		 */
		public static function length(x0:int, y0:int, x1:int, y1:int):int {
			return Math.abs(x1 - x0) + Math.abs(y1 - y0) + 1
		}
		
		/**
		 * Return a Vector of Points in this line, this is slow
		 */
		public static function getPoints(x0:int, y0:int, x1:int, y1:int):Vector.<Point> {
			tempPoints = new Vector.<Point>(length(x0, y0, x1, y1))
			plot(x0, y0, x1, y1, appendPoint)
			var points:Vector.<Point> = tempPoints
			tempPoints = null
			return points
		}
		
		private static function appendPoint(x:int, y:int, index:int):void {
			tempPoints[index] = new Point(x, y)
		}

		/**
		 * Call callback(x:int, y:int, index:int) on every point on this line
		 * The callback can return a true value to cancel the computation
		 * This function will return false if it was canceled and true otherwise
		 */
		public static function plot(x0:int, y0:int, x1:int, y1:int, callback:Function):Boolean {
			var dx:int = Math.abs(x1 - x0);
			var dy:int = Math.abs(y1 - y0);
			var sx:int = x0 < x1 ? 1 : -1;
			var sy:int = y0 < y1 ? 1 : -1;
			var err:int = dx - dy;
			var index:int = 0;

			while (true){
				if (callback(x0, y0, index++)) { return false }

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

}