package rogueutil.fov 
{
	/**
	 * Restrictive Precise Angle Shadowcasting implementation
	 * @author Kyle Stewart
	 */
	public class RestrictiveShadowcastFOV extends FOV 
	{
		
		public function RestrictiveShadowcastFOV() 
		{
			super();
			
		}
		
		override public function computeFOV(x:int, y:int, radius:Number, cbTransparency:Function):void 
		{
			setupFOV(x, y, radius, cbTransparency)
			setLocalVisible(0, 0, true)
			callOnQuads(computeQuad)
			//shadeWalls()
			shadeWallCorners()
		}
		
		protected var shadowCount:int
		protected var shadowLow:Vector.<Number> = new Vector.<Number>
		protected var shadowHigh:Vector.<Number> = new Vector.<Number>
		
		override protected function computeOctant():void 
		{
			// shadowLow & High are not reset
			shadowCount = 0
			for (var x:int = 1; x <= _radiusI; x++ ) {
				var height:int = x+1
				for (var y:int = x; y >= 0; y-- ) {
					setLocalVisible(x, y, inRadius(x, y) && !isInShadow(x, y))
				}
				
				y = 0
				while (y < height) {
					//setLocalVisible(x, y, inRadius(x, y) && !isInShadow(x, y))
					if (!getMapVisible(x, y)) {
						// get size of shadow
						var shadowHeight:int = 1
						while (inRadius(x, y) && y + shadowHeight < height && !getMapVisible(x, y + shadowHeight)) {
							shadowHeight++
						}
						if (y == 0 && shadowHeight == height) {
							return // octant is walled off, stop now
						}
						castShadow(x, y, shadowHeight)
					}
					y++
				}
			}
		}
		
		/**
		 * get the angle at to this position
		 */
		protected function getAngle(x:int, y:Number):Number {
			return 1.0 / (x+1) * y
		}
		
		/**
		 * check of the veiw angle of this position is in shadow
		 */
		protected function isInShadow(x:int, y:int):Boolean {
			var angle:Number = getAngle(x, y + 0.5)
			for (var i:int = shadowCount - 1; i >= 0; i-- ) {
				if(shadowLow[i] < angle && angle < shadowHigh[i]){return true}
			}
			return false
		}
		
		/**
		 * start casting a shadow over this area
		 */
		protected function castShadow(x:int, startY:int, height:int):Boolean {
			var lowAngle:Number = getAngle(x, startY)
			var highAngle:Number = getAngle(x, startY + height)
			for (var i:int = shadowCount - 1; i >= 0; i-- ) {
				// check if this area is already in shadow
				if (shadowLow[i] < lowAngle && highAngle < shadowHigh[i]) { return false}
			}
			// make edge cases wider
			if (lowAngle == 0) { lowAngle = -1 }
			if (highAngle == 1) { highAngle = 2 }
			
			shadowLow[shadowCount] = lowAngle
			shadowHigh[shadowCount] = highAngle
			shadowCount++
			return true
		}
		
	}

}