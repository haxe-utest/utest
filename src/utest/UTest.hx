package utest;

#if (haxe_ver < "4.1.0")
	#error 'Haxe 4.1.0 or later is required to run UTest'
#end

/**
 * Helper class to quickly generate test cases.
 */
final class UTest {
  public static function run<T:ITest>(cases : Array<T>, ?callback : ()->Void) {
    var runner = new Runner();
    for(eachCase in cases)
      runner.addCase(eachCase);
    if(null != callback)
      runner.onComplete.add(function(_) callback());
    utest.ui.Report.create(runner);
    runner.run();
  }
}
