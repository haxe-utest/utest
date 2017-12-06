package utest;

import utest.Dispatcher;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.io.Path;

using sys.FileSystem;
using StringTools;
using haxe.macro.Tools;
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
  var fixtures(default, null) : Array<TestFixture>;

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
    fixtures   = new Array();
    onProgress = new Dispatcher();
    onStart    = new Dispatcher();
    onComplete = new Dispatcher();
    onPrecheck = new Dispatcher();
    onTestStart = new Dispatcher();
    onTestComplete = new Dispatcher();
    length = 0;
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
      if(!isTestFixtureName(field, prefix, pattern, globalPattern)) continue;
      addFixture(new TestFixture(test, field, setup, teardown, setupAsync, teardownAsync));
    }
  }

  /**
   *  Add all test cases located in specified package `path`.
   *  Any module found in `path` is treated as a test case.
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

  private function isTestFixtureName(name:String, prefix:String, ?pattern:EReg, ?globalPattern:EReg):Bool {
    if (pattern == null && globalPattern == null) {
      return StringTools.startsWith(name, prefix);
    }
    if (pattern == null) pattern = globalPattern;
    return pattern.match(name);
  }

  public function addFixture(fixture : TestFixture) {
    fixtures.push(fixture);
    length++;
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
#if (php || neko || python || java || lua)
  public function run() {
    onStart.dispatch(this);
    for (i in 0...fixtures.length)
    {
      var h = runFixture(fixtures[i]);
      onTestComplete.dispatch(h);
      onProgress.dispatch({ result : TestResult.ofHandler(h), done : i+1, totals : length });
    }
    onComplete.dispatch(this);
  }

  function runFixture(fixture : TestFixture) {
    var handler = new TestHandler(fixture);
    handler.onPrecheck.add(this.onPrecheck.dispatch);
    onTestStart.dispatch(handler);
    handler.execute();
    return handler;
  }
#else
  var pos : Int;
  public function run() {
    pos = 0;
    onStart.dispatch(this);
    runNext();
  }

  function runNext() {
    if(fixtures.length > pos)
      runFixture(fixtures[pos++]);
    else
      onComplete.dispatch(this);
  }

  function runFixture(fixture : TestFixture) {
    // cast is required by C#
    var handler = new TestHandler(cast fixture);
    handler.onComplete.add(testComplete);
    handler.onPrecheck.add(this.onPrecheck.dispatch);
    onTestStart.dispatch(handler);
    handler.execute();
  }

  function testComplete(h : TestHandler<TestFixture>) {
    onTestComplete.dispatch(h);
    onProgress.dispatch({ result : TestResult.ofHandler(h), done : pos, totals : length });
    runNext();
  }
#end
}
