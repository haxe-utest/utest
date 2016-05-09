package utest;

import utest.Dispatcher;

/**
The Runner class performs a set of tests. The tests can be added using addCase or addFixtures.
Once all the tests are register they are axecuted on the run() call.
Note that Runner does not provide any visual output. To visualize the test results use one of
the classes in the utest.ui package.
@todo complete documentation
@todo AVOID CHAINING METHODS (long chains do not work properly on IE)
*/
class Runner {
  var fixtures(default, null) : Array<TestFixture>;

/**
Event object that monitors the progress of the runner.
*/
  public var onProgress(default, null) : Dispatcher<{ result : TestResult, done : Int, totals : Int }>;

/**
Event object that monitors when the runner starts.
*/
  public var onStart(default, null)    : Dispatcher<Runner>;

/**
Event object that monitors when the runner ends. This event takes into account async calls
performed during the tests.
*/
  public var onComplete(default, null) : Dispatcher<Runner>;

/**
Event object that monitors when a handler has executed a test case, and
is about to evaluate the results.  Useful for mocking certain
custom asynchronouse behavior in order for certain tests to pass.
*/
  public var onPrecheck(default, null) : Dispatcher<TestHandler<TestFixture>>;

/**
Event object that notifies when a handler is about to start executing.
*/
  public var onTestStart(default, null) : Dispatcher<TestHandler<TestFixture>>;

/**
Event object that notifies when a handler has completed executing.
*/
  public var onTestComplete(default, null) : Dispatcher<TestHandler<TestFixture>>;

/**
The number of fixtures registered.
*/
  public var length(default, null)      : Int;

/**
Global pattern to override the test pattern specified with `addCase`
*/
  public var globalPattern(default, default) : Null<EReg> = null;

/**
Instantiates a Runner onject.
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
Adds a new test case.
@param  test: must be a not null object
@param  setup: string name of the setup function (defaults to "setup")
@param  teardown: string name of the teardown function (defaults to "teardown")
@param  prefix: prefix for methods that are tests (defaults to "test")
@param  pattern: a regular expression that discriminates the names of test
      functions; when set,  the prefix parameter is meaningless
@param  setupAsync: string name of the asynchronous setup function (defaults to "setupAsync")
@param  teardownAsync: string name of the asynchronous teardown function (defaults to "teardownAsync")
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
    if(globalPattern == null && pattern == null) {
      for(field in fields) {
        if(!StringTools.startsWith(field, prefix)) continue;
        if(!isMethod(test, field)) continue;
        addFixture(new TestFixture(test, field, setup, teardown, setupAsync, teardownAsync));
      }
    } else {
      pattern = globalPattern != null ? globalPattern : pattern;
      for(field in fields) {
        if(!pattern.match(field)) continue;
        if(!isMethod(test, field)) continue;
        addFixture(new TestFixture(test, field, setup, teardown, setupAsync, teardownAsync));
      }
    }
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
#if (php || neko || python || java)
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
