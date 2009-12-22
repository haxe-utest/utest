package std.haxe;

import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		std.haxe.io.TestAll.addTests(runner);
		
		runner.addCase(new std.haxe.TestMd5());
		runner.addCase(new std.haxe.TestSerializer());
		runner.addCase(new std.haxe.TestTemplate());
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}