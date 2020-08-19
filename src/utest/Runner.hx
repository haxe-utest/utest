package utest;

import utest.utils.Misc;
import utest.utils.Print;
import haxe.CallStack;
import haxe.macro.Compiler;
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
using utest.utils.AccessoriesUtils;
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
  var iTestFixtures:Map<String,{caseInstance:ITest, setupClass:Void->Async, dependencies:Array<String>, fixtures:Array<TestFixture>, teardownClass:Void->Async}> = new Map();
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
   * Indicates if all tests are finished.
   */
  var complete:Bool = false;

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

    var envPattern = Compiler.getDefine('UTEST_PATTERN');
    if(envPattern != null) {
      globalPattern = new EReg(envPattern, '');
    }
  }

  /**
   * Adds a new test case.
   * @param test must be a not null object
   * @param setup string name of the setup function (defaults to "setup")
   * @param teardown string name of the teardown function (defaults to "teardown")
   * @param prefix prefix for methods that are tests (defaults to "test")
   * @param pattern a regular expression that discriminates the names of test
   *       functions; when set,  the prefix parameter is meaningless
   * @param setupAsync string name of the asynchronous setup function (defaults to "setupAsync")
   * @param teardownAsync string name of the asynchronous teardown function (defaults to "teardownAsync")
   */
  public function addCase(test : Dynamic, setup = "setup", teardown = "teardown", prefix = "test", ?pattern : EReg, setupAsync = "setupAsync", teardownAsync = "teardownAsync") {
    #if (haxe_ver >= "3.4.0")
    if(Misc.isOfType(test, ITest)) {
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
    var className = Type.getClassName(Type.getClass(testCase));
    if(iTestFixtures.exists(className)) {
      throw 'Cannot add the same test twice.';
    }
    var fixtures = [];
  #if as3
  // AS3 can't handle the ECheckType cast. Let's dodge the issue.
  var tmp:TestData.Initializer = cast testCase;
  var init:TestData.InitializeUtest = tmp.__initializeUtest__();
  #else
    var init:TestData.InitializeUtest = (cast testCase:TestData.Initializer).__initializeUtest__();
  #end
    for(test in init.tests) {
      if(!isTestFixtureName(className, test.name, ['test', 'spec'], pattern, globalPattern)) {
        continue;
      }
      var fixture = TestFixture.ofData(testCase, test, init.accessories);
      addFixture(fixture);
      fixtures.push(fixture);
    }
    if(fixtures.length > 0) {
      iTestFixtures.set(className, {
        caseInstance:testCase,
        setupClass:init.accessories.getSetupClass(),
        dependencies:init.dependencies,
        fixtures:fixtures,
        teardownClass:init.accessories.getTeardownClass()
      });
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
    var className = Type.getClassName(Type.getClass(test));
      for (field in fields) {
        if(!isMethod(test, field)) continue;
        if(!isTestFixtureName(className, field, [prefix], pattern, globalPattern)) continue;
        addFixture(new TestFixture(test, field, setup, teardown, setupAsync, teardownAsync));
      }
  }

  /**
   * Add all test cases located in specified package `path`.
   * Any module found in `path` is treated as a test case.
   * That means each module should contain a class with a constructor and with the same name as a module name.
   * @param path dot-separated path as a string or as an identifier/field expression. E.g. `"my.pack"` or `my.pack`
   * @param recursive recursively look for test cases in sub packages.
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
    var packageExists = false;
    function traverse(dir:String, path:String) {
      if(!dir.exists()) return;
      packageExists = true;
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
    if(!packageExists) {
      Context.error('Package $path does not exist', pos);
    }
    return macro @:pos(pos) $b{exprs};
  }

  private function isTestFixtureName(caseName:String, testName:String, prefixes:Array<String>, ?pattern:EReg, ?globalPattern:EReg):Bool {
    if (pattern == null && globalPattern == null) {
      for(prefix in prefixes) {
        if(StringTools.startsWith(testName, prefix)) {
          return true;
        }
      }
      return false;
    }
    if (pattern == null) pattern = globalPattern;
    return pattern.match('$caseName.$testName');
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

  public function run() {
    onStart.dispatch(this);
    #if (haxe_ver >= "3.4.0")
    var iTestRunner = new ITestRunner(this);
    iTestRunner.run();
    #else
    runNext();
    #end
    waitForCompletion();
  }

  /**
   * Don't let the app to shutdown until all tests are finished.
   * @see https://github.com/HaxeFoundation/haxe/issues/8131
   * Can't reproduce it on a separated sample.
   */
  function waitForCompletion() {
    #if (haxe_ver >= "3.4.0")
    if(!complete) {
      haxe.Timer.delay(waitForCompletion, 100);
    }
    #end
  }

  var pos:Int = 0;
  var executedFixtures:Int = 0;
  function runNext(?finishedHandler:TestHandler<TestFixture>) {
    var currentCase = null;
    for(i in pos...fixtures.length) {
      var fixture = fixtures[pos++];
      if(fixture.isITest) continue;
      if(currentCase != fixture.target) {
        currentCase = fixture.target;
        Print.startCase(Type.getClassName(Type.getClass(currentCase)));
      }
      var handler = runFixture(fixture);
      if(!handler.finished) {
        handler.onComplete.add(runNext);
        //wait till current test is finished
        return;
      }
    }
    complete = true;
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
    Print.startTest(fixture.method);
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
  var cases:Iterator<String>;
  var currentCaseName:String;
  var currentCase:ITest;
  var currentCaseFixtures:Array<TestFixture>;
  var teardownClass:Void->Async;
  var setupAsync:Async;
  var teardownAsync:Async;
  var failedTestsInCurrentCase:Array<String> = [];
  var failedCases:Array<String> = [];

  public function new(runner:Runner) {
    this.runner = runner;
    runner.onTestComplete.add(function(handler) {
      for (result in handler.results) {
        switch result {
          case Success(_):
          case _:
            failedTestsInCurrentCase.push(handler.fixture.method);
            failedCases.push(Type.getClassName(Type.getClass(handler.fixture.target)));
        }
      }
    });
  }

  public function run() {
    cases = orderClassesByDependencies();
    runCases();
  }

  function orderClassesByDependencies():Iterator<String> {
    var result = [];
    function error(testCase:ITest, msg:String) {
        runner.onProgress.dispatch({
            totals: runner.length,
            result: TestResult.ofFailedSetupClass(testCase, SetupError(msg, [])),
            done: runner.executedFixtures
        });
    }
    var added = new Map();
    function addClass(cls:String, stack:Array<String>) {
        if(added.exists(cls))
            return;
        var data = runner.iTestFixtures.get(cls);
        if(stack.indexOf(cls) >= 0) {
            error(data.caseInstance, 'Circular dependencies among test classes detected: ' + stack.join(' -> '));
            return;
        }
        stack.push(cls);
        var dependencies = data.dependencies;
        for(dependency in dependencies) {
            if(runner.iTestFixtures.exists(dependency)) {
              addClass(dependency, stack);
            } else {
              error(data.caseInstance, 'This class depends on $dependency, but it cannot be found. Was it added to test runner?');
              return;
            }
        }
        result.push(cls);
        added.set(cls, true);
    }
    for(cls in runner.iTestFixtures.keys()) {
        addClass(cls, []);
    }
    return result.iterator();
  }

  function failedDependencies(data:{dependencies:Array<String>}):Bool {
      for(dependency in data.dependencies) {
          if(failedCases.indexOf(dependency) >= 0)
            return true;
      }
      return false;
  }

  function runCases() {
    while(cases.hasNext()) {
      currentCaseName = cases.next();
      var data = runner.iTestFixtures.get(currentCaseName);
      currentCase = data.caseInstance;
      failedTestsInCurrentCase = [];
      if(failedDependencies(data)) {
        failedCases.push(currentCaseName);
        continue;
      }
      Print.startCase(currentCaseName);
      currentCaseFixtures = data.fixtures;
      teardownClass = data.teardownClass;
      try {
        setupAsync = data.setupClass();
      }
      #if !UTEST_FAILURE_THROW
      catch(e:Dynamic) {
        setupFailed(SetupError('setupClass failed: $e', CallStack.exceptionStack()));
        return;
      }
      #end
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
      var fixture = currentCaseFixtures.shift();
      for (dep in fixture.test.dependencies) {
        if(failedTestsInCurrentCase.indexOf(dep) >= 0) {
          @:privateAccess fixture.ignoringInfo = IgnoredFixture.Ignored('Failed dependencies');
          break;
        }
      }
      var handler = runner.runFixture(fixture);
      if(!handler.finished) {
        handler.onComplete.add(runFixtures);
        return false;
      }
    }
    //no fixtures left in the current case
    try {
      teardownAsync = teardownClass();
    }
    #if !UTEST_FAILURE_THROW
    catch(e:Dynamic) {
      teardownFailed(TeardownError('teardownClass failed: $e', CallStack.exceptionStack()));
      return true;
    }
    #end
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
