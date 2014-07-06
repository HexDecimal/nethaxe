package nethaxe.console.render;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DProfile;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.textures.Texture;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector.Vector;
import nethaxe.console.Console;
import nethaxe.console.ConsoleFont;
import hxsl.Shader;

/**
 * ...
 * @author Kyle Stewart
 */
class ConsoleRenderShader extends Sprite implements ConsoleRender
{

	public var consoleData(default, null):Console;
	public var consoleFont(default, null):ConsoleFont;
	
	private var uvWidth:Float;
	private var uvHeight:Float;
	
	private var stage3d:Stage3D;
	private var context3d:Context3D;
	
	private var texTiles:Texture; // tileset
	private var texFG:Texture;
	private var texBG:Texture;
	private var shader:ConsoleShader;
	
	private var vertexData:VertexBuffer3D;
	private var indexes:IndexBuffer3D;

	public function new(consoleData:Console, consoleFont:ConsoleFont, stage3d:Stage3D) {
		this.consoleData = consoleData;
		this.consoleFont = consoleFont;
		super();
		
		//addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onDraw);
		this.stage3d = stage3d;
		stage3d.addEventListener( Event.CONTEXT3D_CREATE, onReady );
		//stage3d.requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.BASELINE_CONSTRAINED);
		//stage3d.requestContext3D(null, Context3DProfile.BASELINE_CONSTRAINED);
		stage3d.requestContext3D();
	}
	
	/**
	 * Total number of vertices, 4 for each console character
	 */
	private inline function getVertexTotal():Int {
		return consoleData.width * consoleData.height * 4;
	}
	
	private function onReady(?_:Dynamic):Void {
		context3d = stage3d.context3D;
		#if debug
		context3d.enableErrorChecking = false; // no more debugging needed
		#end
		context3d.configureBackBuffer(consoleData.width * consoleFont.glyphWidth,
		                              consoleData.height * consoleFont.glyphHeight, 0, false, false);
		// TODO: make this renderer aware of texture changes
		var tileset:BitmapData = consoleFont.getTexture();
		var buffer:BitmapData = new BitmapData(getPowerOfTwo(tileset.width), getPowerOfTwo(tileset.height), true, 0);
		buffer.copyPixels(tileset, tileset.rect, new Point());
		uvWidth = (tileset.width / buffer.width) / consoleFont.getTextureColumns();
		uvHeight = (tileset.height / buffer.height) / consoleFont.getTextureRows();
		
		
		texTiles = context3d.createTexture(buffer.width, buffer.height,
		                                   Context3DTextureFormat.BGRA, false);
		texTiles.uploadFromBitmapData(buffer);
		
		//context3d.createRectangleTexture(consoleData.width, consoleData.height, Context3DTextureFormat.BGRA, false);
		texBG = context3d.createTexture(getTexWidth(), getTexHeight(),
		                                Context3DTextureFormat.BGRA, false);
		texFG = context3d.createTexture(getTexWidth(), getTexHeight(),
		                                Context3DTextureFormat.BGRA, false);
		
		context3d.setTextureAt(0, texTiles);
		context3d.setTextureAt(1, texBG);
		context3d.setTextureAt(2, texFG);
		
		vertexData = context3d.createVertexBuffer(getVertexTotal(), 4);
		indexes = context3d.createIndexBuffer(consoleData.width * consoleData.height * 6);
		arrangeVertices();
		
		shader = new ConsoleShader();
		shader.consoleMatrix.identity();
		shader.consoleMatrix.appendScale(2 / consoleData.width, -2 / consoleData.height, 1);
		shader.consoleMatrix.appendTranslation( -1, 1, 0);
		
		shader.colorMatrix.identity();
		shader.colorMatrix.appendScale(1 / getTexWidth(), 1 / getTexHeight(), 1);
		
		shader.texTile = texTiles;
		shader.bgTex = texBG;
		shader.fgTex = texFG;
	}
	
	/**
	 * Upload the static arrangement, mostly just the triangle indexes
	 */
	private function arrangeVertices():Void {
		var buffer:ByteArray = new ByteArray();
		var i:Int = 0;
		buffer.position = 0;
		buffer.endian = Endian.LITTLE_ENDIAN;
		buffer.length = consoleData.width * consoleData.height * 6 * (2 * 2);
		for (_ in 0...(consoleData.width * consoleData.height)) {
			buffer.writeShort(i);
			buffer.writeShort(i + 1);
			buffer.writeShort(i + 2);
			buffer.writeShort(i + 1);
			buffer.writeShort(i + 2);
			buffer.writeShort(i + 3);
			i += 4;
		}
		indexes.uploadFromByteArray(buffer, 0, 0, consoleData.width * consoleData.height * 6);
	}
	
	/**
	 * Round up to nearest power of 2
	 */
	private function getPowerOfTwo(value:Int):Int {
		// check if already power of two
		if (value & (value - 1) == 0) { return value; }
		var pow:Int=0;
		while (value > 0) {
			value >>= 1;
			pow++;
		}
		return 1 << pow;
	}
	
	// width and height of the consoleData instance using a power of 2
	private inline function getTexWidth():Int {
		return getPowerOfTwo(consoleData.width);
	}
	private inline function getTexHeight():Int {
		return getPowerOfTwo(consoleData.height);
	}
	
	/**
	 * Update and upload new vertex data
	 */
	private function uploadUV():Void {
		var buffer:ByteArray = new ByteArray();
		buffer.endian = Endian.LITTLE_ENDIAN;
		buffer.length = getVertexTotal() * (4 * 4); // 4 floats in each vertex
		var i:Int = 0;
		for (y in 0...consoleData.height) {
			for (x in 0...consoleData.width) { 
				// Z shape
				var glyph:Int = consoleFont.getGlyphStatus(consoleData.ch[i++]);
				var pos:Point = consoleFont.getTilePos(glyph);
				pos.x *= uvWidth;
				pos.y *= uvHeight;
				//var uv:Rectangle = consoleFont.getTexureRect(glyph);
				writeVertexData(buffer, x, y, 0, 0, pos.x, pos.y);
				writeVertexData(buffer, x, y, 1, 0, pos.x + uvWidth, pos.y);
				writeVertexData(buffer, x, y, 0, 1, pos.x, pos.y + uvHeight);
				writeVertexData(buffer, x, y, 1, 1, pos.x + uvWidth, pos.y + uvHeight);
			}
		}
		vertexData.uploadFromByteArray(buffer, 0, 0, getVertexTotal());
		
	}
	
	private inline function writeVertexData(buffer:ByteArray, x:Int, y:Int, subX:Int, subY:Int, u:Float, v:Float):Void {
		// vertex pos, 2 floats
		buffer.writeFloat(x + subX);
		buffer.writeFloat(y + subY);
		
		// vertex uv, 2 floats
		buffer.writeFloat(u);
		buffer.writeFloat(v);
	}
	
	private function uploadBuffer(colorBuffer:Array<UInt>, texture:Texture):Void {
		var buffer:BitmapData = new BitmapData(getTexWidth(), getTexHeight(), false, 0);
		var bufferRect:Rectangle = new Rectangle(0, 0, consoleData.width, consoleData.height);
		buffer.setVector(bufferRect,Vector.ofArray(colorBuffer));
		texture.uploadFromBitmapData(buffer);
	}
	
	private function onDraw(?_:Dynamic):Void {
		context3d.clear(0, 0, 0, 1);
		context3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO); // disable alpha
		
		uploadBuffer(consoleData.bg, texBG);
		uploadBuffer(consoleData.fg, texFG);
		uploadUV();
		
		shader.bind(context3d, vertexData);
		context3d.drawTriangles(indexes);
		context3d.present();
	}
	
}

private class ConsoleShader extends hxsl.Shader {

	static var SRC = {
		var input : { pos: Float2, uv: Float2 };
		var tileUV: Float2; // color UV
		var colorUV: Float4; // tile UV
		function vertex(consoleMatrix:M44, colorMatrix:M44) {
			out = input.pos.xyzw * consoleMatrix;
			colorUV = input.pos.xyzw * colorMatrix;
			tileUV = input.uv.xy;
		}
		function fragment(texTile: Texture, bgTex: Texture, fgTex: Texture) {
			// perform a simple lerp using a mask from a tileset
			var bg:Float4 = bgTex.get(colorUV.xy, nearest, clamp);
			var fg:Float4 = fgTex.get(colorUV.xy, nearest, clamp);
			var mask:Float4 = texTile.get(tileUV, nearest);
			out = bg * (1 - mask) + fg * mask; // lerp
		}
	};

}