package std.neutral;

import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
// TODO commented cases cause Segmentation Fault in linux
		runner.addCase(new std.neutral.TestFile());
//		runner.addCase(new std.neutral.TestFileSystem());
//		runner.addCase(new std.neutral.TestHost());
//		runner.addCase(new std.neutral.TestMysqlDb());
//		runner.addCase(new std.neutral.TestProcess());
//		runner.addCase(new std.neutral.TestSocket());
//		runner.addCase(new std.neutral.TestSPOD());
//		runner.addCase(new std.neutral.TestSPOD2());
//		runner.addCase(new std.neutral.TestSPOD3());
//		runner.addCase(new std.neutral.TestSPOD4());
//		runner.addCase(new std.neutral.TestSQLiteDb());
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}