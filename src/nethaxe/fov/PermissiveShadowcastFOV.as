package rogueutil.fov 
{
	/**
	 * A modified version of Restrictive Precise Angle Shadowcasting, a tile is only in shadow if no angle can get to it.
	 * I guess you'd effectively call it Permissive Precise Angle Shadowcasting
	 * 
	 * Some clear artifiacts seem to crop up with permissiveness near zero but otherwise looks very nice
	 * @author Kyle Stewart
	 */
	public class PermissiveShadowcastFOV extends RestrictiveShadowcastFOV 
	{
		
		public function PermissiveShadowcastFOV() 
		{
			super();
			
		}
		
		override public function computeFOV(x:int, y:int, radius:Number, cbTransparency:Function):void 
		{
			setupFOV(x, y, radius, cbTransparency)
			setLocalVisible(0, 0, true)
			callOnQuads(computeQuad)
			//shadeWalls()
			//shadeWallCorners()
		}
		
		protected var _permissiveness:Number = 1
		
		/**
		 * check of the veiw angle of this position is in shadow
		 */
		override protected function isInShadow(x:int, y:int):Boolean {
			// this is the veiw angle of this tile, if angleLow is still less then angleHigh then this tile is visible
			var angleHigh:Number = getAngle(x, y + 1)
			var angleLow:Number = getAngle(x, y)
			
			var minView:Number = (1 - _permissiveness) / (x+1)
			
			for (var i:int = shadowCount - 1; i >= 0; i-- ) {
				// if true this tile is in a complete shadow
				if (shadowLow[i] < angleLow && angleHigh < shadowHigh[i]) { return true }
				// partial shadows cut into the veiw
				if (shadowLow[i] < angleLow) { angleLow = Math.max(angleLow, shadowHigh[i]) }
				if (angleHigh < shadowHigh[i]) { angleHigh = Math.min(angleHigh, shadowLow[i]) }
				// the min view size can be changed with _permissiveness
				if(angleHigh - angleLow < minView){return true}
			}
			return false
		}
		
		public function get permissiveness():Number 
		{
			return _permissiveness;
		}
		
		public function set permissiveness(value:Number):void 
		{
			_permissiveness = Math.max(0, Math.min(value, 1));
		}
		
	}

}