package rogueutil.line 
{
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class DigitalLine 
	{
		/**
		 * Call callback(x:int, y:int, index:int, line:int) on every point on every line in this digital line
		 * If the callback returns true then the current line is cancelled and the next is started immedately
		 * Returns the ratio of uninterruped lines, a return of 0 means all lines were canceled, 1 means the opposite
		 */
		public static function plot(x0:int, y0:int, x1:int, y1:int, callback:Function):Number {
			// make an identity matrix
			var _xx:int = 1
			var _xy:int = 0
			var _yx:int = 0
			var _yy:int = 1
			
			// center starting point on 0,0
			var _ax:int = x0
			var _ay:int = y0
			x1 -= _ax
			y1 -= _ay
			
			// flip end point to low upper right slope
			if (x1 < 0) { _xx = -1; x1 *= -1 }
			if (y1 < 0) { _yy = -1; y1 *= -1 }
			if ( x1 < y1) { // flip octant
				_xy = _yy
				_yx = _xx
				_xx = 0
				_yy = 0
				
				var tmp:int
				tmp = x1
				x1 = y1
				y1 = tmp
			}
			
			// x & y are now positive and on the low slope p/q
			var p:int = y1
			var q:int = x1
			var unbrokenLines:int = q // lines not canceled with a true returned from the callback
			for (var line:int = 0; line < q; line++ ) {
				var eps:int = line
				var y:int = 0
				for (var x:int = 0; x <= q; x++ ) {
					if (callback(_xx * x + _yx * y + _ax, _xy * x + _yy * y + _ay, x, line)) {
						// canceled
						unbrokenLines--
						break
					}
					eps += p
					if (eps >= q) { eps -= q; y++ }
				}
			}
			return Number(unbrokenLines) / q
		}
	}

}