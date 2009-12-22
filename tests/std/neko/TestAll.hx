package std.neko;

import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new std.neko.TestNekoSerialization());
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}