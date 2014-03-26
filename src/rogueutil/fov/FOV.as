package rogueutil.fov 
{
	import rogueutil.line.Bresenham;
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class FOV 
	{
		
		// matrix stuff, used to make quad and octant calls easier
		private var _xx:int
		private var _xy:int
		private var _yx:int
		private var _yy:int
		private var _ax_local:int
		private var _ay_local:int
		private var _ax_cb:int
		private var _ay_cb:int
		/**
		 * Current visibility of the map
		 */
		protected var _fovMap:Vector.<Boolean>
		/**
		 * Saved visiblity values from the map (so that the callback is used less)
		 */
		private var _mapCache:Vector.<Boolean>
		private var _mapIsCached:Vector.<Boolean>
		protected var _width:int
		protected var _height:int
		/**
		 * Radius of current computation
		 */
		protected var _radius:Number
		/**
		 * Intergel radious of current computation
		 */
		protected var _radiusI:int
		private var _radiusSquared:Number // used for quick bounds check
		/**
		 * User callback
		 */
		private var _cbTransparency:Function
		
		public function FOV() 
		{
			
		}
		
		protected function setupFOV(x:int, y:int, radius:Number, cbTransparency:Function):void {
			_cbTransparency = cbTransparency
			_radiusSquared = radius*radius
			_radiusI = Math.ceil(radius)
			_width = 1 + _radiusI * 2
			_height = _width
			// translation for local map
			_ax_local = _radiusI
			_ay_local = _radiusI
			// translation for callback
			_ax_cb = x
			_ay_cb = y
			
			_fovMap = new Vector.<Boolean>(_width * _height)
			_mapCache = new Vector.<Boolean>(_width * _height)
			_mapIsCached = new Vector.<Boolean>(_width * _height)
			
			for (var i:int = _mapCache.length - 1; i >= 0; i-- ) {
				_mapCache[i] = -1
			}
			
		}
		
		public function computeFOV(x:int, y:int, radius:Number, cbTransparency:Function):void {
			setupFOV(x, y, radius, cbTransparency)
			callOnQuads(computeQuad)
			setLocalVisible(0, 0, true) // orgin point always lit
			shadeWalls()
		}
		
		/**
		 * call a function on all quads
		 */
		protected function callOnQuads(func:Function, ...args):void {
			for (var i:int = 0; i < 4; i++) { // pick octants using bitfield
				_xx = i & 1? 1 : -1
				_yy = i & 2? 1 : -1
				_xy = 0
				_yx = 0
				func.apply(args)
			}
			_xx = 1
			_yy = 1
			_xy = 0
			_yx = 0
		}
		
		/**
		 * Set all tiles to be lit, this is usally for shadowcasting
		 */
		protected function lightByDefault():void {
			for (var i:int = _fovMap.length - 1; i >= 0; i-- ) {
				_fovMap[i] = true
			}
		}
		
		/**
		 * Add lighting to the walls as a post process effect
		 * Light to spread to light blocking tiles to the sides and diagonally
		 */
		protected function shadeWalls():void {
			var wallLight:Vector.<Boolean> = new Vector.<Boolean>(_fovMap.length)
			for (var y:int = -_radiusI; y <= _radiusI; y++) {
				for (var x:int = -_radiusI; x <= _radiusI; x++) {
					if(getMapVisible(x, y) || !inRadius(x, y)){continue}
					var index:int = localIndex(x, y)
					if (x) { wallLight[index] ||= getLocalVisible(x + (x < 0?1:-1), y) }
					if (y) { wallLight[index] ||= getLocalVisible(x, y + (y < 0?1:-1)) }
					if (x && y) { wallLight[index] ||= getLocalVisible(x + (x < 0?1:-1), y + (y < 0?1:-1)) }
				}
			}
			for (var i:int = wallLight.length -1; i >= 0; i-- ) {
				_fovMap[i] ||= wallLight[i]
				//_fovMap[i] = _fovMap[i] || (wallLight[i] && inRadius(i % _width + _radiusI, i / _width + _radiusI))
			}
		}
		
		/**
		 * Like shadeWalls but only lights walls at the far corner of a lit tile
		 */
		protected function shadeWallCorners():void {
			var wallLight:Vector.<Boolean> = new Vector.<Boolean>(_fovMap.length)
			for (var y:int = -_radiusI; y <= _radiusI; y++) {
				for (var x:int = -_radiusI; x <= _radiusI; x++) {
					if(getMapVisible(x, y) || !inRadius(x, y)){continue}
					var index:int = localIndex(x, y)
					if (x && y) {
						wallLight[index] ||= getMapVisible(x + (x < 0?1: -1), y + (y < 0?1: -1)) && getLocalVisible(x + (x < 0?1: -1), y + (y < 0?1: -1))
						}
				}
			}
			for (var i:int = wallLight.length -1; i >= 0; i-- ) {
				_fovMap[i] ||= wallLight[i]
				//_fovMap[i] = _fovMap[i] || (wallLight[i] && inRadius(i % _width + _radiusI, i / _width + _radiusI))
			}
		}
		
		/**
		 * Inspect if this cell is visible after the last computation
		 */
		public function isVisible(x:int, y:int):Boolean {
			x = x - _ax_cb + _ax_local
			y = y - _ay_cb + _ax_local
			if (x < 0 || _width <= x || y < 0 || _height <= y) { return false }
			return _fovMap[y * _width + x]
		}
		
		/**
		 * Give a callback with the x,y coordinates of tiles in light or darkness
		 * function should be func(x:int, y:int, isLight:Boolean):void
		 */
		public function callWithVisibility(callback):void {
			if(!_fovMap){return}
			for (var y:int = -_radiusI; y <= _radiusI; y++) {
				for (var x:int = -_radiusI; x <= _radiusI; x++) {
					cbVisible(x + _ax_cb, y + _ay_cb, getLocalVisible(x, y))
				}
			}
			
		}
		
		protected function localIndex(x:int, y:int):int {
			return (x * _xy + y * _yy + _ay_local) * _width + (x * _xx + y * _yx + _ax_local)
		}
		
		/**
		 * True if x,y are inside of the radius
		 */
		protected function inRadius(x:int, y:int):Boolean {
			return (x*x + y*y <= _radiusSquared)
		}
		
		/**
		 * Privately set the visibility of a local cell
		 */
		protected function setLocalVisible(x:int, y:int, visibility:Boolean):void {
			_fovMap[localIndex(x, y)] = visibility
		}
		
		/**
		 * Privately get the visibility of a local cell
		 */
		protected function getLocalVisible(x:int, y:int):Boolean {
			return _fovMap[localIndex(x, y)]
		}
		
		/**
		 * Get the visibility of the map using the callback and the current context matrix
		 */
		protected function getMapVisible(x:int, y:int):Boolean {
			var index:int = localIndex(x, y)
			var visibility:Boolean = _mapCache[index]
			if (!_mapIsCached[index]) {
				_mapCache[index] = _cbTransparency(x * _xx + y * _yx + _ax_cb, x * _xy + y * _yy + _ay_cb)
			}
			return _mapCache[index]
		}
		
		protected function computeQuad():void {
			// defaults to calling computeOctant
			computeOctant()
			_xy = _xx
			_yx = _yy
			_xx = 0
			_yy = 0
			computeOctant()
		}
		
		protected function computeOctant():void {
			// default to line of sight
			var x:int
			var y:int
			for (x = _radiusI - 1; x > 0; x-- ) {
				for (y = x; y >= 0; y-- ) {
					if(inRadius(x, y) && getLocalVisible(x, y) < 1){
						Bresenham.plot(0, 0, x, y, plot)
					}
				}
			}
		}
		
		private function plot(x:int, y:int, index:int):Boolean {
			if (!inRadius(x, y) || !getMapVisible(x, y)) { return true }
			setLocalVisible(x, y, true)
			return false
		}
	}

}