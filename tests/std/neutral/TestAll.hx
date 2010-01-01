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
		std.neutral.db.TestAll.addTests(runner);
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}