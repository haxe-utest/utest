package utest;

import utest.Assertation;

class TestHandler<T> {
	private static inline var POLLING_TIME = 10;
	public var results(default, null) : List<Assertation>;
	public var fixture(default, null) : TestFixture<T>;
	public var executionTime(default, null) : Int;
	var asyncStack : List<Dynamic>;
	public function new(fixture : TestFixture<T>) {
		if(fixture == null) throw "fixture argument is null";
		this.fixture  = fixture;
		results       = new List();
		asyncStack    = new List();
		executionTime = -1;
	}

	var startTime : Null<Float>;
	public function execute() {
		try {
			executeMethod(fixture.setup);
			try {
				startTime = haxe.Timer.stamp();
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
		if(startTime != null)
			executionTime = Std.int((haxe.Timer.stamp() - startTime)*1000);
		if(results.length == 0)
			results.add(Warning("no assertions"));
		onTested(this);
		completed();
	}

	function timeout() {
		results.add(TimeoutError(asyncStack.length));
		onTimeout(this);
		completed();
	}

	function completed() {
		try {
			executeMethod(fixture.teardown);
		} catch(e : Dynamic) {
			results.add(TeardownError(e));
		}
		unbindHandler();
		onComplete(this);
	}

	public dynamic function onTested(handler : TestHandler<T>);
	public dynamic function onTimeout(handler : TestHandler<T>);
	public dynamic function onComplete(handler : TestHandler<T>);
}