package std.neutral;

import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new std.neutral.TestFile());
		runner.addCase(new std.neutral.TestFileSystem());
		runner.addCase(new std.neutral.TestHost());
		runner.addCase(new std.neutral.TestProcess());
		runner.addCase(new std.neutral.TestSocket());
#if (php || neko)
		std.neutral.db.TestAll.addTests(runner);
#end
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}