import utest.Runner;
import utest.ui.Report;
import utest.TestResult;

class TestAll {
  public static function addTests(runner : Runner) {
    //runner.globalPattern = ~/testBooleans/;
    runner.addCase(new utest.TestAssert());
    runner.addCase(new utest.TestDispatcher());
    runner.addCase(new utest.TestAsync());
  }

  public static function main() {
    var runner = new Runner();

    addTests(runner);

    Report.create(runner);

    // get test result to determine exit status
    var r:TestResult = null;
    runner.onProgress.add(function(o){ if (o.done == o.totals) r = o.result;});
    runner.run();
  }

  public function new(){}
}
