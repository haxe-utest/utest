package utest;

/**
Helper class to quickly generate test cases.
*/
class UTest {
  public static function run(cases : Array<{}>, ?callback : Void->Void) {

    var runner = new Runner();
    for(eachCase in cases)
      runner.addCase(eachCase);
    utest.ui.Report.create(runner);
    if(null != callback)
    runner.onComplete.add(function(_) callback());
    runner.run();
  }
}
