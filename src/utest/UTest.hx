package utest;

/**
 * Helper class to quickly generate test cases.
 */
@:final class UTest {
  public static function run<T:{}>(cases : Array<T>, ?callback : Void->Void) {
    var runner = new Runner();
    for(eachCase in cases)
      runner.addCase(eachCase);
    if(null != callback)
      runner.onComplete.add(function(_) callback());
    utest.ui.Report.create(runner);
    runner.run();
  }
}
