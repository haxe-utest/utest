package utest.ui.common;

import utest.Dispatcher;
import utest.Runner;
import utest.TestResult;

class ResultAggregator {
  var runner : Runner;
  var flattenPackage : Bool;
  public var root(default, null) : PackageResult;

  public var onStart(default, null) : Notifier;
  public var onComplete(default, null) : Dispatcher<PackageResult>;
  public var onProgress(default, null) : Dispatcher<{ done : Int, totals : Int }>;

  public function new(runner : Runner, flattenPackage = false) {
    if(runner == null) throw "runner argument is null";
    this.flattenPackage = flattenPackage;
    this.runner = runner;
    runner.onStart.add(start);
    runner.onProgress.add(progress);
    runner.onComplete.add(complete);

    onStart = new Notifier();
    onComplete = new Dispatcher();
    onProgress = new Dispatcher();
  }

  function start(runner : Runner) {
    checkNonITest();
    root = new PackageResult(null);
    onStart.dispatch();
  }

  function checkNonITest() {
    var first = null;
    var total = 0;
    for(i in 0...runner.length) {
      var fixture = runner.getFixture(i);
      if(!fixture.isITest) {
        total++;
        if(first == null) {
          first = Type.getClassName(Type.getClass(fixture.target));
        }
      }
    }
    if(total > 0) {
      var baseMsg = 'implement utest.ITest. Non-ITest tests are deprecated. Implement utest.ITest or extend utest.Test.';
      var msg = switch(total) {
        case 1: '$first doesn\'t $baseMsg';
        case 2: '$first and 1 other don\'t $baseMsg';
        case _: '$first and $total others don\'t $baseMsg';
      }
      trace(msg);
    }
  }

  function getOrCreatePackage(pack : String, flat : Bool, ?ref : PackageResult) {
    if(ref == null) ref = root;
    if(pack == null || pack == '') return ref;
    if(flat) {
      if(ref.existsPackage(pack))
        return ref.getPackage(pack);
      var p = new PackageResult(pack);
      ref.addPackage(p);
      return p;
    } else {
      var parts = pack.split('.');
      for(part in parts) {
        ref = getOrCreatePackage(part, true, ref);
      }
      return ref;
    }
  }

  function getOrCreateClass(pack : PackageResult, cls : String, setup : String, teardown : String) {
    if(pack.existsClass(cls)) return pack.getClass(cls);
    var c = new ClassResult(cls, setup, teardown);
    pack.addClass(c);
    return c;
  }

  function createFixture(result : TestResult) {
    var f = new FixtureResult(result.method, result.executionTime);
    for(assertation in result.assertations)
      f.add(assertation);
    return f;
  }

  function progress(e) {
    root.addResult(e.result, flattenPackage);
    onProgress.dispatch(e);
  }

  function complete(runner : Runner) {
    if(root.isEmpty) {
      root.addResult(createNoTestsResult(), false);
    }
    onComplete.dispatch(root);
  }

  function createNoTestsResult():TestResult {
    var result = new TestResult();
    result.pack = '';
    result.cls = '';
    result.method = '';
    result.assertations = new List();
    var pos = {fileName:'', lineNumber:1, className:'utest.Runner', methodName:'run'};
    result.assertations.add(Failure('No tests executed.', pos));
    return result;
  }
}