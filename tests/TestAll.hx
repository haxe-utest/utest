import utest.Runner;
import utest.ui.Report;
import utest.Assert;


// test that PHP doesn't emit warnings
// this also catches some parse errors
class TestFinal {
	public function new(){}

	public function testFinal(){
#if php
		var s:String = untyped __call__("ob_get_clean");
		Assert.equals("",s);
#end
	}

}

class TestAll
{
	public static function addTests(runner : Runner)
	{
		issue.TestAll.addTests(runner);
		cross.TestAll.addTests(runner);
		lang.TestAll.addTests(runner);
		platform.TestAll.addTests(runner);
		std.TestAll.addTests(runner);


		runner.addCase(new TestFinal());
	}
	
	public static function main()
	{
#if php
		untyped __call__("ob_start");
#end
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);

		runner.run();
	}
}