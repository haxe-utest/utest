import utest.Runner;
import utest.ui.Report;
import utest.Assert;
import utest.TestResult;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		issue.TestAll.addTests(runner);
		cross.TestAll.addTests(runner);
		lang.TestAll.addTests(runner);
		platform.TestAll.addTests(runner);
		std.TestAll.addTests(runner);


		runner.addCase(new TestAll());
	}
	
// test that PHP doesn't emit warnings
// this also catches some parse errors
#if php
	public function testFinal(){
		var s:String = untyped __call__("ob_get_clean");
		Assert.equals("",s);
	}
#end
	
	public static function main()
	{
#if php
		untyped __call__("ob_start");
#end
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);

		// get test result to determine exit status
		var r:TestResult = null;
                runner.onProgress.add(function(o){ if (o.done == o.totals) r = o.result;});

		runner.run();
#if php
		php.Sys.exit(r.allOk() ? 0 : 1);
#end
	}
	
	public function new();
}