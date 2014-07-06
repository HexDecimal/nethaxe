package ;
import nethaxe.console.Console;

/**
 * ...
 * @author Kyle Stewart
 */
class PerformanceState extends State
{

	public function new() 
	{
		super();
		label = 'Performance';
	}
	
	override public function step(console:Console):Void {
		var i = 0;
		for (y in 0...console.height) {
			for (x in 0...console.width) {
				//console.drawTile(x, y, i++, 0xffffff, Math.floor(Math.random() * 0x88));
				console.drawTile(x, y, Math.floor(0x20 + Math.random() * 0x40), 0xffffff, Math.floor(Math.random() * 0x88));
			}
		}
	}
	
}