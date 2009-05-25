package utest;

import utest.Assertation;

/**
* @todo add documentation
*/
class TestHandler<T> {
	private static inline var POLLING_TIME = 10;
	public var results(default, null) : List<Assertation>;
	public var fixture(default, null) : TestFixture<T>;
	var asyncStack : List<Dynamic>;

	public var onTested(default, null) : Dispatcher<TestHandler<T>>;
	public var onTimeout(default, null) : Dispatcher<TestHandler<T>>;
	public var onComplete(default, null) : Dispatcher<TestHandler<T>>;

	public function new(fixture : TestFixture<T>) {
		if(fixture == null) throw "fixture argument is null";
		this.fixture  = fixture;
		results       = new List();
		asyncStack    = new List();
		onTested   = new Dispatcher();
		onTimeout  = new Dispatcher();
		onComplete = new Dispatcher();
	}

	public function execute() {
		try {
			executeMethod(fixture.setup);
			try {
				executeMethod(fixture.method);
			} catch(e : Dynamic) {
				results.add(Error(e));
			}
		} catch(e : Dynamic) {
			results.add(SetupError(e));
		}
		checkTested();
	}

	function checkTested() {
#if (flash || js)
		if(expireson == null || asyncStack.length == 0) {
			tested();
		} else if(haxe.Timer.stamp() > expireson) {
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

	public var expireson(default, null) : Null<Float>;
	public function setTimeout(timeout : Int) {
		var newexpire = haxe.Timer.stamp() + timeout/1000;
		expireson = (expireson == null) ? newexpire : (newexpire > expireson ? newexpire : expireson);
	}

	function bindHandler() {
		Assert.results     = this.results;
		Assert.createAsync = this.addAsync;
		Assert.createEvent = this.addEvent;
	}

	function unbindHandler() {
		Assert.results     = null;
		Assert.createAsync = function(f, ?t){ return function(){}};
		Assert.createEvent = function(f, ?t){ return function(e){}};
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
	* @param	f, the function that is called asynchrnously
	* @param	timeout, the maximum time to wait for f() (default is 250)
	* @return	returns a function closure that must be executed asynchrnously
	*/
	public function addAsync(f : Void->Void, timeout = 250) {
		asyncStack.add(f);
		var handler = this;
		setTimeout(timeout);
		return function() {
			if(!handler.asyncStack.remove(f)) {
				handler.results.add(AsyncError("method already executed"));
				return;
			}
			try {
				handler.bindHandler();
				f();
			} catch(e : Dynamic) {
				handler.results.add(AsyncError(e));
			}
		};
	}

	public function addEvent<EventArg>(f : EventArg->Void, timeout = 250) {
		asyncStack.add(f);
		var handler = this;
		setTimeout(timeout);
		return function(e : EventArg) {
			if(!handler.asyncStack.remove(f)) {
				handler.results.add(AsyncError("event already executed"));
				return;
			}
			try {
				handler.bindHandler();
				f(e);
			} catch(e : Dynamic) {
				handler.results.add(AsyncError(e));
			}
		};
	}

	function executeMethod(name : String) {
		if(name == null) return;
		bindHandler();
		Reflect.callMethod(fixture.target, Reflect.field(fixture.target, name), []);
	}

	function tested() {
		if(results.length == 0)
			results.add(Warning("no assertions"));
		onTested.dispatch(this);
		completed();
	}

	function timeout() {
		results.add(TimeoutError(asyncStack.length));
		onTimeout.dispatch(this);
		completed();
	}

	function completed() {
		try {
			executeMethod(fixture.teardown);
		} catch(e : Dynamic) {
			results.add(TeardownError(e));
		}
		unbindHandler();
		onComplete.dispatch(this);
	}
}