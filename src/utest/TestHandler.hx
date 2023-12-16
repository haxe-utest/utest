package utest;

import haxe.Exception;
import haxe.ValueException;
import utest.exceptions.UTestException;
import haxe.CallStack;
import haxe.Timer;
import utest.Assertation;

class TestHandler<T> {
  private static inline var POLLING_TIME = 10;
  public var results(default, null) : List<Assertation>;
  public var fixture(default, null) : TestFixture;
  public var finished(default, null) : Bool = false;
  public var executionTime(default, null) : Float = 0;
  var asyncStack : List<Any>;
  var startTime:Float = 0;

  public var onTested(default, null) : Dispatcher<TestHandler<T>>;
  public var onTimeout(default, null) : Dispatcher<TestHandler<T>>;
  public var onComplete(default, null) : Dispatcher<TestHandler<T>>;
  public var onPrecheck(default, null) : Dispatcher<TestHandler<T>>;

  public var precheck(default, null) : ()->Void;

  private var wasBound:Bool = false;

  var testCase:ITest;
  var test:TestData;
  var setupAsync:Null<Async>;
  var testAsync:Null<Async>;
  var teardownAsync:Null<Async>;

  public function new(fixture : TestFixture) {
    if(fixture == null) throw "fixture argument is null";
    this.fixture  = fixture;
    results       = new List();
    asyncStack    = new List();
    onTested   = new Dispatcher();
    onTimeout  = new Dispatcher();
    onComplete = new Dispatcher();
    onPrecheck = new Dispatcher();

    if (fixture.ignoringInfo.isIgnored) {
      results.add(Ignore(fixture.ignoringInfo.ignoreReason));
    }

    testCase = fixture.target;
    test = fixture.test;
    if(test == null) {
      throw 'Fixture is missing test data';
    }
  }

  public function execute() {
    startTime = Timer.stamp();
    if (fixture.ignoringInfo.isIgnored) {
      executeFinally();
      return;
    }
    bindHandler();
    runSetup();
  }

  function runSetup() {
    inline function handleCatch(e:Any, stack:CallStack) {
      results.add(SetupError(e, stack));
      completedFinally();
    }
    try {
      setupAsync = fixture.setupMethod();
    }
    #if !UTEST_FAILURE_THROW
    catch(e:ValueException) {
      handleCatch(e.value, e.stack);
      return;
    } catch(e) {
      handleCatch(e, e.stack);
      return;
    }
    #end

    setupAsync.then(checkSetup);
  }

  function checkSetup() {
    if(setupAsync.timedOut) {
      results.add(SetupError('Setup timeout', []));
      completedFinally();
    } else {
      runTest();
    }
  }

  function runTest() {
    inline function handleCatch(e:Any, stack:CallStack) {
      results.add(Error(e, stack));
      runTeardown();
    }
    try {
      testAsync = test.execute();
    }
    #if !UTEST_FAILURE_THROW
    catch(e:ValueException) {
      handleCatch(e.value, e.stack);
      return;
    } catch(e) {
      handleCatch(e, e.stack);
      return;
    }
    #end

    testAsync.then(checkTest);
  }

  function checkTest() {
    onPrecheck.dispatch(this);

    if(testAsync.timedOut) {
      results.add(TimeoutError(1, []));
      onTimeout.dispatch(this);

    } else if(testAsync.resolved) {
      if(results.length == 0) {
        results.add(Warning('no assertions'));
      }
      onTested.dispatch(this);

    } else {
      throw 'Unexpected test state';
    }

    runTeardown();
  }

  function runTeardown() {
    inline function handleCatch(e:Any, stack:CallStack) {
      results.add(TeardownError(e, CallStack.exceptionStack()));
      completedFinally();
    }
    try {
      teardownAsync = fixture.teardownMethod();
    }
    #if !UTEST_FAILURE_THROW
    catch(e:ValueException) {
      handleCatch(e.value, e.stack);
      return;
    } catch(e) {
      handleCatch(e, e.stack);
      return;
    }
    #end

    teardownAsync.then(checkTeardown);
  }

  function checkTeardown() {
    if(teardownAsync.timedOut) {
      results.add(TeardownError('Teardown timeout', []));
    }
    completedFinally();
  }

  function executeFinally() {
    onPrecheck.dispatch(this);
    tested();
  }

  function bindHandler() {
    if (wasBound) return;
    Assert.results = this.results;
    wasBound = true;
  }

  function unbindHandler() {
    if (!wasBound) return;
    Assert.results = null;
    wasBound = false;
  }

  function tested() {
    if(results.length == 0)
      results.add(Warning("no assertions"));
    onTested.dispatch(this);
    completedFinally();
  }

  function timeout() {
    results.add(TimeoutError(asyncStack.length, []));
    onTimeout.dispatch(this);
    completedFinally();
  }

  function completedFinally() {
    finished = true;
    unbindHandler();
    executionTime = (Timer.stamp() - startTime) * 1000;
    onComplete.dispatch(this);
  }
}
