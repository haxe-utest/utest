package utest;

import utest.Assertation;

class TestHandler<T> {
	private static inline var POLLING_TIME = 10;
	public var results(default, null) : List<Assertation>;
	public var fixture(default, null) : TestFixture<T>;
	var asyncStack : List<Dynamic>;
	public function new(fixture : TestFixture<T>) {
		if(fixture == null) throw "fixture argument is null";
		this.fixture = fixture;
		results      = new List();
		asyncStack   = new List();
	}

	public function execute() {
		Assert.results = results;
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


	public function addAsync(f : Void->Void, timeout = 250) {
		asyncStack.add(f);
		var handler = this;
		setTimeout(timeout);
		return function() {
			if(!handler.asyncStack.remove(f)) {
				handler.results.add(AsyncError("method already executed"));
				return;
			}
			Assert.results = handler.results;
			try {
				Assert.results = handler.results;
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
				Assert.results = handler.results;
				f(e);
			} catch(e : Dynamic) {
				handler.results.add(AsyncError(e));
			}
		};
	}

	function executeMethod(name : String) {
		if(name == null) return;
		Reflect.callMethod(fixture.target, Reflect.field(fixture.target, name), []);
	}

	function tested() {
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
		onCompleted(this);
	}

	public dynamic function onTested(handler : TestHandler<T>);
	public dynamic function onTimeout(handler : TestHandler<T>);
	public dynamic function onCompleted(handler : TestHandler<T>);
}