package  
{
	import rogueutil.console.ConsoleFontBDF;
	/**
	 * ...
	 * @author Kyle Stewart
	 */
	public class Assets 
	{
		
		[Embed(source="../fonts/bdf/6x13.bdf", mimeType="application/octet-stream")]
		public static const bdf6x13:Class
		
		[Embed(source="../fonts/bdf/10x20.bdf", mimeType="application/octet-stream")]
		public static const bdf10x20:Class
		
		[Embed(source="arena.txt", mimeType="application/octet-stream")]
		public static const arena:Class
		
		
		
		public static function loadBDF(bdfAsset:Class):ConsoleFontBDF {
			return new ConsoleFontBDF(new bdfAsset())
		}
	}

}