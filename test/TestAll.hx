import utest.Runner;
import utest.ui.Report;
import utest.TestResult;
#if (haxe_ver >= "3.4.0")
import utest.TestITest;
#end

class TestAll {
  #if (haxe_ver >= "3.4.0")
  static var testITest:TestITest = new TestITest();
  #end

  public static function addTests(runner : Runner) {
    runner.addCase(new utest.TestAssert());
    runner.addCase(new utest.TestDispatcher());
    #if (haxe_ver >= "3.4.0")
    runner.addCase(new utest.TestAsync());
    runner.addCase(testITest);
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
      if(testITest.teardownClassRunning) {
        throw 'TestITest: missed teardownClass() async completion.';
      }
    });
    #end
    runner.run();
  }

  public function new(){}
}
