package utest;

import haxe.CallStack;
import utest.Assertation;

class TestHandler<T> {
  private static inline var POLLING_TIME = 10;
  public var results(default, null) : List<Assertation>;
  public var fixture(default, null) : TestFixture;
  public var finished(default,null):Bool = false;
  var asyncStack : List<Dynamic>;

  public var onTested(default, null) : Dispatcher<TestHandler<T>>;
  public var onTimeout(default, null) : Dispatcher<TestHandler<T>>;
  public var onComplete(default, null) : Dispatcher<TestHandler<T>>;
  public var onPrecheck(default, null) : Dispatcher<TestHandler<T>>;

  public var precheck(default, null) : Void->Void;

  private var wasBound:Bool = false;

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
  }

  public function execute() {
    if (fixture.ignoringInfo.isIgnored) {
      executeFinally();
      return;
    }

    //ugly hack to call executeFinally() only once if asynchronous code is involved
    var isSync = true;
    var expectingAsync = true;
    function run() {
      if(isSync) {
        expectingAsync = false;
        return;
      }
      executeFixtureMethod();
      executeFinally();
    }

    try {
      executeMethod(fixture.setup);
      executeAsyncMethod(fixture.setupAsync, run);
      if(!expectingAsync) {
        executeFixtureMethod();
      }
    }
    #if !UTEST_FAILURE_THROW
    catch(e : Dynamic) {
      results.add(SetupError(e, exceptionStack()));
    }
    #end
    isSync = false;
    if(!expectingAsync) {
      executeFinally();
    }
  }

  function executeFixtureMethod() {
    try {
      executeMethod(fixture.method);
    }
    #if !UTEST_FAILURE_THROW
    catch (e : Dynamic) {
      results.add(Error(e, exceptionStack()));
    }
    #end
  }

  function executeFinally() {
    onPrecheck.dispatch(this);
    checkTested();
  }

  static function exceptionStack(pops = 2)
  {
    var stack = haxe.CallStack.exceptionStack();
    while (pops-- > 0)
      stack.pop();
    return stack;
  }

  function checkTested() {
#if ((haxe_ver >= "3.4.0") || flash || js)
    if(expiration == null || asyncStack.length == 0) {
      tested();
    } else if(haxe.Timer.stamp() > expiration) {
      timeout();
    } else {
      haxe.Timer.delay(checkTested, POLLING_TIME);
    }
#else
    if(asyncStack.length == 0)
      tested();
    else
      timeout();
#end
  }

  public var expiration(default, null) : Null<Float>;
  public function setTimeout(timeout : Int) {
    var newExpire = haxe.Timer.stamp() + timeout/1000;
    expiration = (expiration == null) ? newExpire : (newExpire > expiration ? newExpire : expiration);
  }

  function bindHandler() {
    if (wasBound) return;
    Assert.results     = this.results;
    Assert.createAsync = this.addAsync;
    Assert.createEvent = this.addEvent;
    wasBound = true;

  }

  function unbindHandler() {
    if (!wasBound) return;
    Assert.results     = null;
    Assert.createAsync = function(?f, ?t){ return function(){}};
    Assert.createEvent = function(f, ?t){ return function(e){}};
    wasBound = false;
  }

  /**
  * Adds a function that is called asynchronously.
  *
  * Example:
  * <pre>
  * var fixture = new TestFixture(new TestClass(), "test");
  * var handler = new TestHandler(fixture);
  * var flag = false;
  * var async = handler.addAsync(function() {
  *   flag = true;
  * }, 50);
  * handler.onTimeout.add(function(h) {
  *   trace("TIMEOUT");
  * });
  * handler.onTested.add(function(h) {
  *   trace(flag ? "OK" : "FAILED");
  * });
  * haxe.Timer.delay(function() async(), 10);
  * handler.execute();
  * </pre>
  * @param  f, the function that is called asynchrnously
  * @param  timeout, the maximum time to wait for f() (default is 250)
  * @return returns a function closure that must be executed asynchrnously
  */
  public function addAsync(?f : Void->Void, timeout = 250) {
    if (null == f)
      f = function() { }
    asyncStack.add(f);
    var handler = this;
    setTimeout(timeout);
    return function() {
      if(!handler.asyncStack.remove(f)) {
        handler.results.add(AsyncError("async function already executed", []));
        return;
      }
      try {
        handler.bindHandler();
        f();
      }
      #if !UTEST_FAILURE_THROW
      catch(e : Dynamic) {
        handler.results.add(AsyncError(e, exceptionStack(0))); // TODO check the correct number of functions is popped from the stack
      }
      #end
    };
  }

  public function addEvent<EventArg>(f : EventArg->Void, timeout = 250) {
    asyncStack.add(f);
    var handler = this;
    setTimeout(timeout);
    return function(e : EventArg) {
      if(!handler.asyncStack.remove(f)) {
        handler.results.add(AsyncError("event already executed", []));
        return;
      }
      try {
        handler.bindHandler();
        f(e);
      }
      #if !UTEST_FAILURE_THROW
      catch(e : Dynamic) {
        handler.results.add(AsyncError(e, exceptionStack(0))); // TODO check the correct number of functions is popped from the stack
      }
      #end
    };
  }

  function executeMethod(name : String) {
    if(name == null) return;
    bindHandler();
    Reflect.callMethod(fixture.target, Reflect.field(fixture.target, name), []);
  }

  function executeAsyncMethod(name : String, done : Void->Void) : Void {
    if(name == null) {
      done();
      return;
    }
    bindHandler();
    Reflect.callMethod(fixture.target, Reflect.field(fixture.target, name), [done]);
  }

  function tested() {
    if(results.length == 0)
      results.add(Warning("no assertions"));
    onTested.dispatch(this);
    completed();
  }

  function timeout() {
    results.add(TimeoutError(asyncStack.length, []));
    onTimeout.dispatch(this);
    completed();
  }

  function completed() {
    if (fixture.ignoringInfo.isIgnored) {
      completedFinally();
      return;
    }

    //ugly hack to call completedFinally() only once if asynchronous code is involved
    var isSync = true;
    var expectingAsync = true;
    function complete() {
      if(isSync) {
        expectingAsync = false;
        return;
      }
      completedFinally();
    }

    try {
      executeMethod(fixture.teardown);
      executeAsyncMethod(fixture.teardownAsync, complete);
    }
    #if !UTEST_FAILURE_THROW
    catch(e : Dynamic) {
      results.add(TeardownError(e, exceptionStack(2))); // TODO check the correct number of functions is popped from the stack
    }
    #end
    isSync = false;
    if(!expectingAsync) {
      completedFinally();
    }
  }

  function completedFinally() {
    finished = true;
    unbindHandler();
    onComplete.dispatch(this);
  }
}
