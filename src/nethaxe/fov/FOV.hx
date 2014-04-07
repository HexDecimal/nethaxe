package nethaxe.fov;
import nethaxe.fov.FOV.FOVShape;
import nethaxe.fov.FOV.FOVWallLighting;

/**
 * ...
 * @author Kyle Stewart
 */
class FOV
{
	/**
	 * A special matrix used to convert between global, local, octant, and quadrant points
	 */
	private var _matrix:MatrixFOV;
	
	/**
	 * Current visibility of the local map
	 */
	private var _visMap:Array<Bool>;
	
	/**
	 * Saved visiblity values from the map (so that the callback is used less)
	 */
	private var _cacheMap:Array<Int>;
	
	// _mapCache bitfield
	static inline var MAPCAHCE_CHECKED_BIT =  0x1;
	static inline var MAPCAHCE_TRANSPARENT_BIT = 0x2;
	
	/**
	 * Radius of current computation
	 */
	private var _radius:Float;
	/**
	 * Frequently used for quick radius bounds checking.
	 * Should always be _radius*_radius, obviously
	 */
	private var _radiusSquared:Float // 
	/**
	 * Intergel radious of current computation
	 * this should always be Math.ceil(_radius)
	 */
	private var _radiusI:Int
	
	/**
	 * A temporary stored user callback
	 */
	private var _funcIsTransparent:Int -> Int -> Bool;
		
	/**
	 * The array width of the local map.
	 * This array is always a square so this is considered the height as well.
	 * This should always be (_radiusI * 2 + 1)
	 */
	private var _width:Int;
	
	/**
	 * Stored shape of the FOV
	 */
	private var _shape:FOVShape = Sphere;
	/**
	 * Stored wall lighting behavior
	 */
	private var _wallLighting:FOVWallLighting = LightWalls;

	public function new() 
	{
		
	}
	
	public function computeFOV(x:Int, y:Int, radius:Float, funcIsTransparent:Int -> Int -> Bool):Void {
		initFOV(x, y, radius, funcIsTransparent, false);
		callOctants();
		callQuadrants();
		setLocalVisible(0, 0, true); // orgin is always visible
	}
	
	private function initFOV(x:Int, y:Int, radius:Float, funcIsTransparent:Int -> Int -> Bool, defaultVis:Bool):Void {
		// init temp constants
		_radius = radius;
		_radiusSquared = radius * radius;
		_radiusI = Math.ceil(radius);
		_width = _radiusI * 2 + 1;
		_funcIsTransparent = funcIsTransparent;
		
		// init maps
		_matrix.initTranslation(x, y, _radiusI);
		_cacheMap = [for _ in 0...(_width * _width) 0];
		_visMap = [for _ in 0...(_width * _width) defaultVis];
	}
	
	/**
	 * Get the index of the global array from the local coords x,y
	 */
	private inline function getLocalIndex(xLocal:Int, yLocal:Int):Int {
		// the array is in global space, transform coords to global
		return _matrix.getGlobalY(xLocal, yLocal) * _width + _matrix.getGlobalX(xLocal, yLocal);
	}
	
	/**
	 * Get the current setting of the visibility at local coords x,y
	 */
	private inline function getLocalVisible(xLocal:Int, yLocal:Int):Bool {
		return _visMap[getLocalIndex(xLocal, yLocal)];
	}
	
	/**
	 * Set visibility at local coords x,y
	 */
	private inline function setLocalVisible(xLocal:Int, yLocal:Int, visibility:Bool):Void {
		_visMap[getLocalIndex(xLocal, yLocal)] = visibility;
	}
	
	/**
	 * Get the transparency of the map from the local coords x,y
	 */
	private inline function getLocalTransparency(xLocal:Int, yLocal:Int):Bool {
		var index:Int = getLocalIndex(xLocal, yLocal);
		if (!(_cacheMap[index] & MAPCAHCE_CHECKED_BIT)) {
			// cache transparency of this index
			_cacheMap[index] |= MAPCAHCE_CHECKED_BIT;
			if (_funcIsTransparent(_matrix.getMapX(xLocal, yLocal), _matrix.getMapY(xLocal, yLocal)) {
				_cacheMap[index] |= MAPCAHCE_TRANSPARENT_BIT;
			}
		}
		return Bool(_cacheMap[index] & MAPCAHCE_TRANSPARENT_BIT);
	}
	
	/**
	 * Return true if this coord fits in the FOV shape
	 */
	private inline function inLocalRadius(xLocal:Int, yLocal:Int):Bool {
		// local coords are always a vector from the center
		return switch(_shape) {
			case Sphere: (xLocal * xLocal) + (yLocal * yLocal) <= _radiusSquared;
			case Square: Math.abs(xLocal) <= _radiusI || Math.abs(yLocal) <= _radiusI;
		}
		
	}
	
	/**
	 * Call computeQuadrant with the correct transformations
	 */
	private inline function callQuadrants():Void {
		_matrix.callOnQuads(computeQuadrant);
	}
	
	/**
	 * Call computeOctant with the correct transformations
	 */
	private inline function callOctants():Void {
		_matrix.callOnQuads(computeOctant);
	}
	
	/**
	 * Called on each quad
	 */
	private function computeQuadrant():Void {}
	
	/**
	 * Called on each oct
	 */
	private function computeOctant():Void {}
	
	/**
	 * Call func(x:Int, y:Int, visible:Bool):Void with the visibility of every tile in this FOV
	 */
	public function callbackWithVisibility(func:Int -> Int -> Bool -> Void):Void {
		for (y in -_radiusI...(_radiusI + 1)) {
			for (x in -_radiusI...(_radiusI + 1)) {
				// not sure about these transforms, could make this faster maybe
				func.bind(_matrix.getMapX(x, y),
				          _matrix.getMapY(x, y),
						  getLocalVisible(x, y))
			}
		}
	}
	
}
enum FOVShape { Square; Sphere; }
enum FOVWallLighting { LightWalls; CullWalls }

private class MatrixFOV {
	// 2x3 matrix for converting octant/quadrant local coords to global coords
	private var xx:Int = 1;
	private var xy:Int = 0;
	private var yx:Int = 0;
	private var yy:Int = 1;
	private var tx:Int = 0;
	private var ty:Int = 0;
	
	// a second translation only matrix, to convert a users global call to local coords and back
	private var tx2:Int = 0;
	private var ty2:Int = 0;
	
	/**
	 * Reset all but the translation sections to identity
	 */
	public inline function clearTransform():Void {
		xx = 1;
		xy = 0;
		yx = 0;
		yy = 1;
	}
	
	/**
	 * Set up the translation matrixes
	 */
	public inline function initTranslation(x:Int, y:Int, radiusI:Int):Void {
		// Local to Global translation
		tx = radiusI;
		ty = radiusI;
		// Global to Map translation
		tx2 = x;
		tx2 = y;
	}
	
	/**
	 * Get global x from local coords x,y
	 */
	public inline function getGlobalX(xLocal:Int, yLocal:Int):Int {
		return xLocal * xx + yLocal * yx + tx;
	}
	
	/**
	 * Get global y from local coords x,y
	 */
	public inline function getGlobalY(xLocal:Int, yLocal:Int):Int {
		return xLocal * xy + yLocal * yy + ty;
	}
	
	/**
	 * Get map x from local coords x,y
	 */
	public inline function getMapX(xLocal:Int, yLocal:Int):Int {
		return xLocal * xx + yLocal * yx + tx + tx2;
	}
	
	/**
	 * Get map y from local coords x,y
	 */
	public inline function getMapY(xLocal:Int, yLocal:Int):Int {
		return xLocal * xy + yLocal * yy + ty + ty2;
	}
	
	/**
	 * Get global x from map coord x
	 */
	public inline function mapToGlobalX(xMap:Int):Int {
		return xMap - tx2;
	}
	
	/**
	 * Get global y from map coord y
	 */
	public inline function mapToGlobalY(yMap:Int):Int {
		return yMap - ty2;
	}
	
	public inline function globalToMapX(xGlobal:Int):Int {
		return xGlobal + tx2;
	}
	
	public inline function globalToMapY(yGlobal:Int):Int {
		return yGlobal + ty2;
	}
	
	public inline function callOnQuads(func:Void -> Void) {
		for (i in 0...4) {
			xx = (i & 1 == 0)?1:-1;
			xy = 0
		    yx = 0
			yy = (i & 2 == 0)?1: -1;
			func.bind();
		}
		clearTransform();
	}
	
	public inline function callOnOctants(func:Void -> Void) {
		for (i in 0...8) {
			xx = (i & 1 == 0)?1:-1;
			xy = 0
		    yx = 0
			yy = (i & 2 == 0)?1: -1;
			if (i & 4 != 0) {
				xy = xx
				yx = yy
				xx = 0
				yy = 0
			}
			func.bind();
		}
		clearTransform();
	}
}