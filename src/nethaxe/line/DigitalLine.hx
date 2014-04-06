package rogueutil.line;

/**
 * ...
 * @author Kyle Stewart
 */
class DigitalLine
{

	/**
	 * Call func(x:Int, y:Int, index:Int, line:Int):Bool on every point on every line in this digital line
	 * If the callback returns false then the current line is cancelled and the next is started immedately
	 * Returns the ratio of uninterruped lines, a return of 0 means all lines were canceled, 1 means the opposite
	 */
	public static function plot(x0:Int, y0:Int, x1:Int, y1:Int, func:Int -> Int -> Int -> Int -> Bool):Float {
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
		
		// x & y are now positive and on the low slope p/q
		var p:Int = y1;
		var q:Int = x1;
		var unbrokenLines:Int = q; // lines not canceled with a true returned from the callback
		for (var line:Int = 0; line < q; line++ ) {
			var eps:Int = line;
			var y:Int = 0;
			for (var x:Int = 0; x <= q; x++ ) {
				if (!func.bind(x * xx + y * yx + tx, x * xy + y * yy + ty, x, line)) {
					// canceled
					unbrokenLines--;
					break
				}
				eps += p;
				if (eps >= q) { eps -= q; y++ }
			}
		}
		return unbrokenLines / q;
	}
	
}