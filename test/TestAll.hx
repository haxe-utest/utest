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
    runner.addCase(new utest.TestAsync.TestClassTimeout());
    runner.addCase(new utest.TestSyncITest());
    runner.addCase(new utest.TestSpec());
    runner.addCase(new utest.TestDependencies());
    runner.addCase(new utest.TestCaseDependencies.Case1());
    runner.addCase(new utest.TestCaseDependencies.Case2());
    runner.addCase(new utest.TestCaseDependencies.Case3());
    runner.addCase(new utest.TestCaseDependencies.Case4());
    runner.addCase(new utest.TestWithMacro());
    runner.addCase(testAsyncITest);
    #end
    runner.addCase(new utest.TestIgnored());
    runner.addCase(new utest.TestRunner());
  }

  public static function main() {
    var runner = new Runner();

    addTests(runner);

    // get test result to determine exit status
    var r:TestResult = null;
    runner.onProgress.add(function(o){ if (o.done == o.totals) r = o.result;});
    #if (haxe_ver >= "3.4.0")
    runner.onComplete.add(function(runner) {
      //check test case dependencies
      var expected = ['Case1', 'Case3', 'Case2', 'Case4'];
      for(i in 0...expected.length) {
        if(utest.TestCaseDependencies.caseExecutionOrder[i] != expected[i]) {
          throw 'TestCaseDependencies: invalid execution order: ${utest.TestCaseDependencies.caseExecutionOrder}';
        }
      }
      //check asynchronous tearDown
      if(testAsyncITest.teardownClassRunning) {
        throw 'TestAsyncITest: missed teardownClass() async completion.';
      }
    });
    #end

    Report.create(runner);
    runner.run();
  }

  public function new(){}
}
