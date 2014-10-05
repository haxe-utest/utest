package utest.ui.macro;

#if macro
import haxe.macro.Context;
import neko.Lib;

#if haxe_211
import haxe.CallStack;
#else
import haxe.Stack;
#end

import utest.Runner;
import utest.TestResult;

using StringTools;

class MacroReport {
  public function new(runner : Runner) {
    runner.onStart.add(start);
    runner.onProgress.add(testDone);
    runner.onComplete.add(complete);
  }

  var startTime : Float;
  var totalTests : Int;
  var failedTests : Int;
  var testWarnings : Int;

  function start(e) {
    totalTests = 0;
    failedTests = 0;
    testWarnings = 0;

    startTime = haxe.Timer.stamp();
  }

  function dumpStack(stack : Array<StackItem>) {
    if (stack.length == 0)
      return "";

    var parts = Stack.toString(stack).split("\n");
    var r = [];
    for (part in parts) {
      if (part.indexOf(" utest.") >= 0) continue;
      r.push(part);
    }
    return r.join("\n");
  }

  /**
   * @todo When macro warnings work, use Context.warning() on Warning assertation.
   */
  function testDone(test : { result : TestResult, done : Int, totals : Int } ) {
    for (assertation in test.result.assertations) {
      totalTests++;
      failedTests++;

      switch(assertation) {
        case Success(pos):
          failedTests--;
        case Failure(msg, pos):
          trace(pos.fileName + ":" + pos.lineNumber + ": " + msg, Context.currentPos());
        case Error(e, s):
          trace(Std.string(e) + ", see output for stack.", Context.currentPos());
          Lib.print(dumpStack(s));
        case SetupError(e, s):
          trace(Std.string(e) + ", see output for stack.", Context.currentPos());
          Lib.print(dumpStack(s));
        case TeardownError(e, s):
          trace(Std.string(e) + ", see output for stack.", Context.currentPos());
          Lib.print(dumpStack(s));
        case TimeoutError(missedAsyncs, s):
          trace("missed async calls: " + missedAsyncs + ", see output for stack.", Context.currentPos());
          Lib.print(dumpStack(s));
        case AsyncError(e, s):
          trace(Std.string(e) + ", see output for stack.", Context.currentPos());
          Lib.print(dumpStack(s));
        case Warning(msg):
          failedTests--;
          testWarnings++;
          trace(msg);
      }
    }
  }

  function complete(runner : Runner) {
    var end = haxe.Timer.stamp();
    var time = Std.string(Std.int((end - startTime) * 1000) / 1000);

    if (time.endsWith("."))
      time = time.substr(0, -1);

    trace("uTest results: " + totalTests + " tests run, " + failedTests + " failed, " + testWarnings + " warnings. Execution time: " + time + "ms.");
  }
}
#end