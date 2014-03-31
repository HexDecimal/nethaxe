package rogueutil.console;

/**
 * ...
 * @author Kyle Stewart
 */
class ConsoleRender
{

	public var consoleData(default, null):ConsoleData;
	public var consoleFont(default, null):ConsoleFont;
	
	public function new(consoleData:ConsoleData, consoleFont:ConsoleFont) 
	{
		this.consoleData = consoleData;
		this.consoleFont = consoleFont;
	}
	
}