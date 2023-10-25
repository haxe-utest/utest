import haxe.Exception;
import utest.Runner;
import utest.ui.Report;
import utest.TestAsyncITest;

class TestAll {
  static var testAsyncITest:TestAsyncITest = new TestAsyncITest();

  public static function addTests(runner : Runner) {
    runner.addCase(new utest.TestAssert());
    runner.addCase(new utest.TestDispatcher());
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
    runner.addCase(new utest.TestIgnored());
    runner.addCase(new utest.TestRunner());
  }

  public static function main() {
    var runner = new Runner();

    addTests(runner);

    #if !UTEST_PATTERN
    //Check test case dependencies
    runner.onComplete.add(_ -> {
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

    var report = Report.create(runner);
    report.displayHeader = AlwaysShowHeader;
    report.displaySuccessResults = NeverShowSuccessResults;

    var failed = false;
    runner.onProgress.add(r -> {
      if(!r.result.allOk()) {
        failed = true;
      }
    });

    runner.run();

    #if closure
    //Node's `process.exit` is not available in minified js because every attempt to access to it gets mangled.
    //this is the simplest workaround I could invent.
    runner.onComplete.add(_ -> {
      if(failed) {
        //delay to make sure the report is fully printed first.
        haxe.Timer.delay(() -> throw new Exception('Failed. See UTest report above.'), 10);
      }
    });
    #end
  }

  public function new(){}
}
