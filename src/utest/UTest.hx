package utest;

import haxe.macro.Expr;

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

  /**
   * Runs all test cases from the given packages, including sub packages.
   * @param packages One or more dot paths as a string or field expression. Pass
   * multiple arguments if needed, not an array.
   * @see utest.Runner#addCases
   */
  macro public static function runCases(packages : Array<Expr>) {
    var cases:Array<Expr> = [];
    for(eachPackage in packages)
      cases.push(macro runner.addCases($eachPackage));
    return macro {
      var runner = new utest.Runner();
      $b{ cases }
      utest.ui.Report.create(runner);
      runner.run();
    };
  }
}
