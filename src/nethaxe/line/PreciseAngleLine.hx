package nethaxe.line;

/**
 * ...
 * @author Kyle Stewart
 */
class PreciseAngleLine
{
	
	public static function plot(x0:int, y0:int, x1:int, y1:int, func:Int -> Int -> Int -> Bool):Bool {
		// make an identity matrix
		var xx:Int = 1;
		var xy:Int = 0;
		var yx:Int = 0;
		var yy:Int = 1;
		
		// center starting point on 0,0
		var tx:Int = x0;
		var ty:Int = y0;
		x1 -= tx;
		y1 -= ty;
		
		// flip end point to low upper right slope
		if (x1 < 0) { xx = -1; x1 *= -1 }
		if (y1 < 0) { yy = -1; y1 *= -1 }
		
		if ( x1 < y1) { // flip octant
			xy = yy;
			yx = xx;
			xx = 0;
			yy = 0;
			
			var tmp:Int;
			tmp = x1;
			x1 = y1;
			y1 = tmp;
		}
		
		// x & y are now positive and on a low slope
		// get the angle
		var angle:Float = 1.0 / (x1 + 1) * (y1 + 0.5);
		for (var x:Int = 0; x <= x1;x++ ){
			// get y from x at angle
			var y:Int = angle / (1.0 / (x + 1))
			if (!func.bind(x * xx + y * yx + tx, x * xy + y * yy + ty, x)) { return false; }
		}
		return true;
	}
	
}