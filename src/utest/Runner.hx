package utest;

import utest.exceptions.UTestException;
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

using utest.utils.AsyncUtils;
using utest.utils.AccessoriesUtils;

#if (haxe_ver < "4.1.0")
	#error 'Haxe 4.1.0 or later is required to run UTest'
#end

/**
 * The Runner class performs a set of tests. The tests can be added using addCase.
 * Once all the tests are register they are axecuted on the run() call.
 * Note that Runner does not provide any visual output. To visualize the test results use one of
 * the classes in the utest.ui package.
 * @todo complete documentation
 * @todo AVOID CHAINING METHODS (long chains do not work properly on IE)
 */
class Runner {
  var fixtures:Map<String,{caseInstance:ITest, setupClass:()->Async, dependencies:Array<String>, fixtures:Array<TestFixture>, teardownClass:()->Async}> = new Map();

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
   * @param testCase must be a not null object
   * @param pattern a regular expression that discriminates the names of test
   *       functions
   */
  public function addCase(testCase : ITest, ?pattern : EReg) {
    var className = Type.getClassName(Type.getClass(testCase));
    if(fixtures.exists(className)) {
      throw new UTestException('Cannot add the same test twice.');
    }
    var newFixtures = [];
    var init:TestData.InitializeUtest = (cast testCase:TestData.Initializer).__initializeUtest__();
    for(test in init.tests) {
      if(!isTestFixtureName(className, test.name, ['test', 'spec'], pattern, globalPattern)) {
        continue;
      }
      newFixtures.push(new TestFixture(testCase, test, init.accessories));
    }
    if(newFixtures.length > 0) {
      fixtures.set(className, {
        caseInstance:testCase,
        setupClass:init.accessories.getSetupClass(),
        dependencies:#if UTEST_IGNORE_DEPENDS [] #else init.dependencies #end,
        fixtures:newFixtures,
        teardownClass:init.accessories.getTeardownClass()
      });
      length += newFixtures.length;
    }
  }

  /**
   * Add all test cases located in specified package `path`.
   * Any module found in `path` is treated as a test case.
   * That means each module should contain a class with a constructor and with the same name as a module name.
   * @param path dot-separated path as a string or as an identifier/field expression. E.g. `"my.pack"` or `my.pack`
   * @param recursive recursively look for test cases in sub packages.
   * @param nameFilterRegExp regular expression to check modules names against. If the module name does not
   *              match this argument, the module will not be added.
   */
  macro public function addCases(eThis:Expr, path:Expr, recursive:Bool = true, nameFilterRegExp:String = '.*'):Expr {
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
    var nameFilter = new EReg(nameFilterRegExp, '');
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
        if(file.substr(-3) != '.hx' || file == 'import.hx') {
          continue;
        }
        var className = file.substr(0, file.length - 3);
        if(className == '' || !nameFilter.match(className)) {
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

  public function run() {
    onStart.dispatch(this);
    var iTestRunner = new ITestRunner(this);
    iTestRunner.run();
    waitForCompletion();
  }

  /**
   * Don't let the app to shutdown until all tests are finished.
   * @see https://github.com/HaxeFoundation/haxe/issues/8131
   * Can't reproduce it on a separated sample.
   */
  function waitForCompletion() {
    if(!complete) {
      haxe.Timer.delay(waitForCompletion, 100);
    }
  }

  function runFixture(fixture : TestFixture):TestHandler<TestFixture> {
    var handler = new TestHandler(fixture);
    handler.onComplete.add(testComplete);
    handler.onPrecheck.add(this.onPrecheck.dispatch);
    Print.startTest(fixture.name);
    onTestStart.dispatch(handler);
    handler.execute();
    return handler;
  }

  var executedFixtures:Int = 0;
  function testComplete(h : TestHandler<TestFixture>) {
    ++executedFixtures;
    onTestComplete.dispatch(h);
    onProgress.dispatch({ result : TestResult.ofHandler(h), done : executedFixtures, totals : length });
  }
}

@:access(utest.Runner.fixtures)
@:access(utest.Runner.runNext)
@:access(utest.Runner.runFixture)
@:access(utest.Runner.executedFixtures)
@:access(utest.Runner.complete)
private class ITestRunner {
  var runner:Runner;
  var cases:Iterator<String>;
  var currentCaseName:String;
  var currentCase:ITest;
  var currentCaseFixtures:Array<TestFixture>;
  var teardownClass:()->Async;
  var setupAsync:Async;
  var teardownAsync:Async;
  var failedTestsInCurrentCase:Array<String> = [];
  var executedTestsInCurrentCase:Array<String> = [];
  var failedCases:Array<String> = [];

  public function new(runner:Runner) {
    this.runner = runner;
    runner.onTestComplete.add(function(handler) {
      for (result in handler.results) {
        switch result {
          case Success(_):
          case _:
            failedTestsInCurrentCase.push(handler.fixture.name);
            failedCases.push(Type.getClassName(Type.getClass(handler.fixture.target)));
        }
      }
      executedTestsInCurrentCase.push(handler.fixture.name);
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
        var data = runner.fixtures.get(cls);
        if(stack.indexOf(cls) >= 0) {
            error(data.caseInstance, 'Circular dependencies among test classes detected: ' + stack.join(' -> '));
            return;
        }
        stack.push(cls);
        var dependencies = data.dependencies;
        for(dependency in dependencies) {
            if(runner.fixtures.exists(dependency)) {
              addClass(dependency, stack);
            } else {
              error(data.caseInstance, 'This class depends on $dependency, but it cannot be found. Was it added to test runner?');
              return;
            }
        }
        result.push(cls);
        added.set(cls, true);
    }
    for(cls in runner.fixtures.keys()) {
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
      var data = runner.fixtures.get(currentCaseName);
      currentCase = data.caseInstance;
      failedTestsInCurrentCase = [];
      executedTestsInCurrentCase = [];
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
      catch(e) {
        setupFailed(SetupError('setupClass failed: ${e.message}', e.stack));
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
    runner.complete = true;
    runner.onComplete.dispatch(runner);
  }

  function checkSetup() {
    if(setupAsync.timedOut) {
      setupFailed(SetupError('setupClass timeout', []));
    } else {
      if(runFixtures())
        runCases();
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
      checkFixtureDependencies(fixture);
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
    catch(e) {
      teardownFailed(TeardownError('teardownClass failed: ${e.message}', e.stack));
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

  function checkFixtureDependencies(fixture:TestFixture) {
    if(!fixture.ignoringInfo.isIgnored) {
      #if !UTEST_IGNORE_DEPENDS
      if(fixture.test.dependencies.length > 0) {
        var failedDeps = [];
        var ignoredDeps = [];
        for (dep in fixture.test.dependencies) {
          if(failedTestsInCurrentCase.contains(dep)) {
            failedDeps.push(dep);
          }
          if(!executedTestsInCurrentCase.contains(dep)) {
            ignoredDeps.push(dep);
          }
        }
        var failedDepsMsg = failedDeps.length == 0 ? null : IgnoredFixture.Ignored('Failed dependencies: ${failedDeps.join(', ')}');
        var ignoredDepsMsg = ignoredDeps.length == 0 ? null : IgnoredFixture.Ignored('Skipped dependencies: ${ignoredDeps.join(', ')}');
        var ignoringInfo = switch [failedDepsMsg, ignoredDepsMsg] {
          case [null, null]: IgnoredFixture.NotIgnored();
          case [_, null]: IgnoredFixture.Ignored(failedDepsMsg);
          case [null, _]: IgnoredFixture.Ignored(ignoredDepsMsg);
          case [_, _]: IgnoredFixture.Ignored('$failedDepsMsg. $ignoredDepsMsg');
        }
        fixture.setIgnoringInfo(ignoringInfo);
      }
      #end
    }
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
