package rogueutil.console 
{
	/**
	 * ...
	 * @author 
	 */
	public class ConsoleBlendMode 
	{
		
		public static function BlendNone(source:uint, dest:uint):uint {
			return dest
		}
		
		public static function BlendSet(source:uint, dest:uint):uint {
			return source | (dest & 0xff000000)
		}
		
		public static function BlendAlpha(source:uint, dest:uint):uint {
			var sourceAlpha:int = source >> 24 & 0xff
			if (sourceAlpha == 0) { return dest }
			if (sourceAlpha == 0xff) { return source }
			var destAlpha:int = 0xff - sourceAlpha
			return ((((source >> 16 & 0xff) * sourceAlpha) + (dest >> 16 & 0xff) * destAlpha) / 0xff << 16 |
			        (((source >> 8 & 0xff) * sourceAlpha) + (dest >> 8 & 0xff) * destAlpha) / 0xff << 8 |
					(((source & 0xff) * sourceAlpha) + (dest & 0xff) * destAlpha) / 0xff | 0xff000000)
					
		}
	}

}