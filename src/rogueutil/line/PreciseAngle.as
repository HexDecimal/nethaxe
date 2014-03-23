package rogueutil.line 
{
	/**
	 * A line of sight algorithm based on Restrictive Precise Angle Shadowcasting
	 * @author Kyle Stewart
	 */
	public class PreciseAngle 
	{
		
		public function PreciseAngle() 
		{
			
		}
		
		public static function plot(x0:int, y0:int, x1:int, y1:int, callback:Function):Boolean {
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
			
			// x & y are now positive and on a low slope
			// get the angle
			var angle:Number = 1.0 / (x1 + 1) * y1
			if (callback(_ax, _ay, x)) { return false }
			for (var x:int = 1; x <= x1;x++ ){
				// get y from angle
				var y:int = Math.round(angle / (1.0 / (x + 1)))
				if (callback(_xx * x + _yx * y + _ax, _xy * x + _yy * y + _ay, x)) { return false }
			}
			return true
		}
	}

}