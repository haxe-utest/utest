import utest.TestITest;
import utest.Runner;
import utest.ui.Report;
import utest.TestResult;

class TestAll {
  static var testITest:TestITest = new TestITest();

  public static function addTests(runner : Runner) {
    runner.addCase(new utest.TestAssert());
    runner.addCase(new utest.TestDispatcher());
    #if (haxe_ver >= "3.4.0")
    runner.addCase(new utest.TestAsync());
    #end
    runner.addCase(new utest.TestIgnored());
    runner.addCase(new utest.TestRunner());
    runner.addCase(testITest);
  }

  public static function main() {
    var runner = new Runner();

    addTests(runner);

    Report.create(runner);

    // get test result to determine exit status
    var r:TestResult = null;
    runner.onProgress.add(function(o){ if (o.done == o.totals) r = o.result;});
    runner.onComplete.add(function(runner) {
      if(testITest.teardownClassRunning) {
        throw 'TestITest: missed teardownClass() async completion.';
      }
    });
    runner.run();
  }

  public function new(){}
}
