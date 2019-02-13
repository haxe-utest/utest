import utest.Runner;
import utest.ui.Report;
import utest.TestResult;
#if (haxe_ver >= "3.4.0")
import utest.TestAsyncITest;
#end

class TestAll {
  #if (haxe_ver >= "3.4.0")
  static var testAsyncITest:TestAsyncITest = new TestAsyncITest();
  #end

  public static function addTests(runner : Runner) {
    runner.addCase(new utest.TestAssert());
    runner.addCase(new utest.TestDispatcher());
    #if (haxe_ver >= "3.4.0")
    runner.addCase(new utest.TestAsync());
    runner.addCase(new utest.TestSyncITest());
    runner.addCase(new utest.TestSpec());
    runner.addCase(new utest.TestWithMacro());
    runner.addCase(testAsyncITest);
    #end
    runner.addCase(new utest.TestIgnored());
    runner.addCase(new utest.TestRunner());
  }

  public static function main() {
    var runner = new Runner();

    addTests(runner);

    Report.create(runner);

    // get test result to determine exit status
    var r:TestResult = null;
    runner.onProgress.add(function(o){ if (o.done == o.totals) r = o.result;});
    #if (haxe_ver >= "3.4.0")
    runner.onComplete.add(function(runner) {
      if(testAsyncITest.teardownClassRunning) {
        throw 'TestAsyncITest: missed teardownClass() async completion.';
      }
    });
    #end
    runner.run();
  }

  public function new(){}
}
