package utest;

import utest.Dispatcher;


class Runner {
	var fixtures(default, null) : Array<TestFixture<Dynamic>>;

	public var onProgress(default, null) : Dispatcher<{ result : TestResult, done : Int, totals : Int }>;
	public var onStart(default, null)    : Dispatcher<Runner>;
	public var onComplete(default, null) : Dispatcher<Runner>;
	public var length(default, null)      : Int;

	public function new() {
		fixtures   = new Array();
		onProgress = new Dispatcher();
		onStart    = new Dispatcher();
		onComplete = new Dispatcher();
		length = 0;
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
				addFixture(new TestFixture(test, field, setup, teardown));
			}
		} else {
			for(field in fields) {
				if(!pattern.match(field)) continue;
				if(!isMethod(test, field)) continue;
				addFixture(new TestFixture(test, field, setup, teardown));
			}
		}
	}
	
	public function addFixture(fixture : TestFixture<Dynamic>) {
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

	function runFixture(fixture : TestFixture<Dynamic>) {
		var handler = new TestHandler(fixture);
		handler.onComplete.add(testComplete);
		handler.execute();
	}

	function testComplete(h : TestHandler<Dynamic>) {
		onProgress.dispatch({ result : TestResult.ofHandler(h), done : pos, totals : length });
		runNext();
	}
}