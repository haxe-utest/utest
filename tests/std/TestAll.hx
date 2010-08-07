package std;

import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		std.haxe.TestAll.addTests(runner);
#if neko
		std.neko.TestAll.addTests(runner);
#end
#if (neko || php || cpp)
// these tests requires to have mysql properly configured and take a long time to execute
//		std.neutral.TestAll.addTests(runner);
#end
		runner.addCase(new std.TestArray());
		runner.addCase(new std.TestDate());
		runner.addCase(new std.TestEReg());
		runner.addCase(new std.TestHash());
		runner.addCase(new std.TestIntHash());
		runner.addCase(new std.TestLambda());
		runner.addCase(new std.TestList());
		runner.addCase(new std.TestReflect());
		runner.addCase(new std.TestStd());
		runner.addCase(new std.TestString());
		runner.addCase(new std.TestStringTools());
		runner.addCase(new std.TestXml());
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}