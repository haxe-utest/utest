package utest;

import haxe.CallStack;
import utest.Dispatcher;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.io.Path;

using sys.FileSystem;
using StringTools;
using haxe.macro.Tools;
#end

#if (haxe_ver >= "3.4.0")
using utest.utils.AsyncUtils;
#end

/**
 * The Runner class performs a set of tests. The tests can be added using addCase or addFixtures.
 * Once all the tests are register they are axecuted on the run() call.
 * Note that Runner does not provide any visual output. To visualize the test results use one of
 * the classes in the utest.ui package.
 * @todo complete documentation
 * @todo AVOID CHAINING METHODS (long chains do not work properly on IE)
 */
class Runner {
  var fixtures(default, null) : Array<TestFixture> = [];
  #if (haxe_ver >= "3.4.0")
  var iTestFixtures:Map<ITest,Array<TestFixture>> = new Map();
  #end

  /**
   * Event object that monitors the progress of the runner.
   */
  public var onProgress(default, null) : Dispatcher<{ result : TestResult, done : Int, totals : Int }>;

  /**
   * Event object that monitors when the runner starts.
   */
  public var onStart(default, null)    : Dispatcher<Runner>;

  /**
   * Event object that monitors when the runner ends. This event takes into account async calls
   * performed during the tests.
   */
  public var onComplete(default, null) : Dispatcher<Runner>;

  /**
   * Event object that monitors when a handler has executed a test case, and
   * is about to evaluate the results.  Useful for mocking certain
   * custom asynchronouse behavior in order for certain tests to pass.
   */
  public var onPrecheck(default, null) : Dispatcher<TestHandler<TestFixture>>;

  /**
   * Event object that notifies when a handler is about to start executing.
   */
  public var onTestStart(default, null) : Dispatcher<TestHandler<TestFixture>>;

  /**
   * Event object that notifies when a handler has completed executing.
   */
  public var onTestComplete(default, null) : Dispatcher<TestHandler<TestFixture>>;

  /**
   * The number of fixtures registered.
   */
  public var length(default, null)      : Int;

  /**
   * Global pattern to override the test pattern specified with `addCase`
   */
  public var globalPattern(default, default) : Null<EReg> = null;

  /**
   * Instantiates a Runner onject.
   */
  public function new() {
    onProgress = new Dispatcher();
    onStart    = new Dispatcher();
    onComplete = new Dispatcher();
    onPrecheck = new Dispatcher();
    onTestStart = new Dispatcher();
    onTestComplete = new Dispatcher();
    length = 0;

    var envPattern = getEnvSetting('UTEST_PATTERN');
    if(envPattern != null) {
      globalPattern = new EReg(envPattern, '');
    }
  }

  /**
   * Get the value for a setting provided by haxe define flag (-D name=value) or by an environment variable at compile time.
   * If both -D and env var are provided, then the value provided by -D is used.
   * @param name - the name of a defined value or of an environment variable.
   */
  macro static function getEnvSetting(name:String):ExprOf<Null<String>> {
    var value = Context.definedValue(name);
    if(value == null) {
      value = Sys.getEnv(name);
  }
    return macro $v{value};
  }

  /**
   * Adds a new test case.
   * @param  test: must be a not null object
   * @param  setup: string name of the setup function (defaults to "setup")
   * @param  teardown: string name of the teardown function (defaults to "teardown")
   * @param  prefix: prefix for methods that are tests (defaults to "test")
   * @param  pattern: a regular expression that discriminates the names of test
   *       functions; when set,  the prefix parameter is meaningless
   * @param  setupAsync: string name of the asynchronous setup function (defaults to "setupAsync")
   * @param  teardownAsync: string name of the asynchronous teardown function (defaults to "teardownAsync")
   */
  public function addCase(test : Dynamic, setup = "setup", teardown = "teardown", prefix = "test", ?pattern : EReg, setupAsync = "setupAsync", teardownAsync = "teardownAsync") {
    #if (haxe_ver >= "3.4.0")
    if(Std.is(test, ITest)) {
      addITest(test, pattern);
    } else {
      addCaseOld(test, setup, teardown, prefix, pattern, setupAsync, teardownAsync);
    }
    #else
    addCaseOld(test, setup, teardown, prefix, pattern, setupAsync, teardownAsync);
    #end
  }

  #if (haxe_ver >= "3.4.0")
  function addITest(testCase:ITest, pattern:Null<EReg>) {
    if(iTestFixtures.exists(testCase)) {
      throw 'Cannot add the same test twice.';
    }
    var tests:Array<TestData> = (testCase:Dynamic).__initializeUtest__();
    for(test in tests) {
      if(!isTestFixtureName(test.name, ['test', 'spec'], pattern, globalPattern)) {
        continue;
      }
      addFixture(TestFixture.ofData(testCase, test));
    }
  }
  #end

  function addCaseOld(test:Dynamic, setup = "setup", teardown = "teardown", prefix = "test", ?pattern : EReg, setupAsync = "setupAsync", teardownAsync = "teardownAsync") {
    if(!Reflect.isObject(test)) throw "can't add a null object as a test case";
    if(!isMethod(test, setup))
      setup = null;
    if(!isMethod(test, setupAsync))
      setupAsync = null;
    if(!isMethod(test, teardown))
      teardown = null;
    if(!isMethod(test, teardownAsync))
      teardownAsync = null;
    var fields = Type.getInstanceFields(Type.getClass(test));
      for (field in fields) {
        if(!isMethod(test, field)) continue;
        if(!isTestFixtureName(field, [prefix], pattern, globalPattern)) continue;
        addFixture(new TestFixture(test, field, setup, teardown, setupAsync, teardownAsync));
      }
  }

  /**
   *  Add all test cases located in specified package `path`.
   *  Any module found in `path` is treated as a test case.
   *  That means each module should contain a class with a constructor and with the same name as a module name.
   *  @param path - dot-separated path as a string or as an identifier/field expression. E.g. `"my.pack"` or `my.pack`
   *  @param recursive - recursively look for test cases in sub packages.
   */
  macro public function addCases(eThis:Expr, path:Expr, recursive:Bool = true):Expr {
    if(Context.defined('display')) {
      return macro {};
    }
    var path = switch(path.expr) {
      case EConst(CString(s)): s;
      case _: path.toString();
    }
    var pos = Context.currentPos();
    if(~/[^a-zA-Z0-9_.]/.match(path)) {
      Context.error('The first argument for utest.Runner.addCases() should be a valid package path.', pos);
    }
    var pack = path.split('.');
    var relativePath = Path.join(pack);
    var exprs = [];
    function traverse(dir:String, path:String) {
      if(!dir.exists()) return;
      for(file in dir.readDirectory()) {
        var fullPath = Path.join([dir, file]);
        if(fullPath.isDirectory() && recursive){
          traverse(fullPath, '$path.$file');
          continue;
        }
        if(file.substr(-3) != '.hx') {
          continue;
        }
        var className = file.substr(0, file.length - 3);
        if(className == '') {
          continue;
        }
        var testCase = Context.parse('new $path.$className()', pos);
        exprs.push(macro @:pos(pos) $eThis.addCase($testCase));
      }
    }
    for(classPath in Context.getClassPath()) {
      traverse(Path.join([classPath, relativePath]), path);
    }
    return macro @:pos(pos) $b{exprs};
  }

  private function isTestFixtureName(name:String, prefixes:Array<String>, ?pattern:EReg, ?globalPattern:EReg):Bool {
    if (pattern == null && globalPattern == null) {
      for(prefix in prefixes) {
        if(StringTools.startsWith(name, prefix)) {
          return true;
        }
      }
      return false;
    }
    if (pattern == null) pattern = globalPattern;
    return pattern.match(name);
  }

  public function addFixture(fixture : TestFixture) {
    fixtures.push(fixture);
    length++;
    if(fixture.isITest) {
      var testCase:ITest = cast fixture.target;
      var fixtures = iTestFixtures.get(testCase);
      if(fixtures == null) {
        fixtures = [];
        iTestFixtures.set(testCase, fixtures);
      }
      fixtures.push(fixture);
    }
  }

  public function getFixture(index : Int) {
    return fixtures[index];
  }

  function isMethod(test : Dynamic, name : String) {
    try {
      return Reflect.isFunction(Reflect.field(test, name));
    } catch(e : Dynamic) {
      return false;
    }
  }

  public function run() {
    onStart.dispatch(this);
    var iTestRunner = new ITestRunner(this);
    iTestRunner.run();
  }

  var pos:Int = 0;
  var executedFixtures:Int = 0;
  function runNext(?finishedHandler:TestHandler<TestFixture>) {
    for(i in pos...fixtures.length) {
      var fixture = fixtures[pos++];
      if(fixture.isITest) continue;
      var handler = runFixture(fixture);
      if(!handler.finished) {
        handler.onComplete.add(runNext);
        //wait till current test is finished
        return;
      }
    }
    onComplete.dispatch(this);
  }

  function runFixture(fixture : TestFixture):TestHandler<TestFixture> {
    // cast is required by C#
    #if (haxe_ver >= "3.4.0")
    var handler = (fixture.isITest ? new ITestHandler(fixture) : new TestHandler(fixture));
    #else
    var handler = new TestHandler(cast fixture);
    #end
    handler.onComplete.add(testComplete);
    handler.onPrecheck.add(this.onPrecheck.dispatch);
    onTestStart.dispatch(handler);
    handler.execute();
    return handler;
  }

  function testComplete(h : TestHandler<TestFixture>) {
    ++executedFixtures;
    onTestComplete.dispatch(h);
    onProgress.dispatch({ result : TestResult.ofHandler(h), done : executedFixtures, totals : length });
  }
}

#if (haxe_ver >= "3.4.0")
@:access(utest.Runner.iTestFixtures)
@:access(utest.Runner.runNext)
@:access(utest.Runner.runFixture)
@:access(utest.Runner.executedFixtures)
private class ITestRunner {
  var runner:Runner;
  var cases:Iterator<ITest>;
  var currentCase:ITest;
  var currentCaseFixtures:Array<TestFixture>;
  var setupAsync:Async;
  var teardownAsync:Async;

  public function new(runner:Runner) {
    this.runner = runner;
  }

  public function run() {
    cases = runner.iTestFixtures.keys();
    runCases();
  }

  function runCases() {
    while(cases.hasNext()) {
      currentCase = cases.next();
      currentCaseFixtures = runner.iTestFixtures.get(currentCase);
      try {
        setupAsync = currentCase.setupClass().orResolved();
      } catch(e:Dynamic) {
        setupFailed(SetupError('setupClass failed: $e', CallStack.exceptionStack()));
        return;
      }
      if(setupAsync.resolved) {
        if(!runFixtures()) return;
      } else {
        setupAsync.then(checkSetup);
        return;
      }
    }
    //run old-fashioned tests
    runner.runNext();
  }

  function checkSetup() {
    if(setupAsync.timedOut) {
      setupFailed(SetupError('setupClass timeout', []));
    } else {
      runFixtures();
    }
  }

  function setupFailed(assertation:Assertation) {
    runner.executedFixtures += currentCaseFixtures.length;
      runner.onProgress.dispatch({
        totals: runner.length,
        result: TestResult.ofFailedSetupClass(currentCase, assertation),
        done: runner.executedFixtures
      });
      runCases();
  }

  /**
   * Returns `true` if all fixtures were executed synchronously.
   */
  function runFixtures(?finishedHandler:TestHandler<TestFixture>):Bool {
    while(currentCaseFixtures.length > 0) {
      var handler = runner.runFixture(currentCaseFixtures.pop());
      if(!handler.finished) {
        handler.onComplete.add(runFixtures);
        return false;
      }
    }
    //no fixtures left in the current case
    teardownAsync = Async.getResolved();
    try {
      teardownAsync = currentCase.teardownClass().orResolved();
    } catch(e:Dynamic) {
      teardownFailed(TeardownError('tearDown failed: $e', CallStack.exceptionStack()));
    }
    //case was executed synchronously from `runCases()`
    if(teardownAsync.resolved && finishedHandler == null) {
      return true;
    }
    teardownAsync.then(checkTeardown);
    return false;
  }

  function checkTeardown() {
    if(teardownAsync.timedOut) {
      teardownFailed(TeardownError('teardownClass timeout', []));
    }
    runCases();
  }

  function teardownFailed(assertation:Assertation) {
    runner.onProgress.dispatch({
      totals: runner.length,
      result: TestResult.ofFailedTeardownClass(currentCase, assertation),
      done: runner.executedFixtures
    });
  }
}
#end