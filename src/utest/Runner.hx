package utest;

import utest.Dispatcher;


class Runner {
	public var fixtures(default, null) : List<TestFixture<Dynamic>>;

	public var onProgress(default, null) : Dispatcher<{ result : TestResult, done : Int, totals : Int }>;
	public var onStart(default, null)    : Dispatcher<Runner>;
	public var onComplete(default, null) : Dispatcher<Runner>;

	public function new() {
		fixtures   = new List();
		onProgress = new Dispatcher();
		onStart    = new Dispatcher();
		onComplete = new Dispatcher();
	}

	public function addCase(test : Dynamic, setup = "setup", teardown = "teardown", prefix = "test", ?pattern : EReg) {
		if(!Reflect.isObject(test)) throw "can't add a null object as a test case";
		if(!isMethod(test, setup))
			setup = null;
		if(!isMethod(test, teardown))
			teardown = null;
		var fields = Type.getInstanceFields(Type.getClass(test));
		if(pattern == null) {
			for(field in fields) {
				if(!StringTools.startsWith(field, prefix)) continue;
				if(!isMethod(test, field)) continue;
				fixtures.add(new TestFixture(test, field, setup, teardown));
			}
		} else {
			for(field in fields) {
				if(!pattern.match(field)) continue;
				if(!isMethod(test, field)) continue;
				fixtures.add(new TestFixture(test, field, setup, teardown));
			}
		}
	}

	function isMethod(test : Dynamic, name : String) {
		try {
			return Reflect.isFunction(Reflect.field(test, name));
		} catch(e : Dynamic) {
			return false;
		}
	}

	var testsToRun : Int;
	public function run() {
		counter = 0;
		testsToRun = fixtures.length;
		onStart.dispatch(this);
		runNext();
	}

	function runNext() {
		if(fixtures.length > 0)
			runFixture(fixtures.pop());
		else
			onComplete.dispatch(this);
	}

	var counter : Int;
	function runFixture(fixture : TestFixture<Dynamic>) {
		var handler = new TestHandler(fixture);
		handler.onComplete.add(testComplete);
		handler.execute();
	}

	function testComplete(h : TestHandler<Dynamic>) {
		onProgress.dispatch({ result : TestResult.ofHandler(h), done : fixtures.length+1, totals : testsToRun });
		runNext();
	}
}