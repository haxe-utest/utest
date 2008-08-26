package utest;


class Runner {
	public var fixtures(default, null) : List<TestFixture<Dynamic>>;
	public var results (default, null) : List<TestResult>;
	public function new() {
		fixtures = new List();
		results  = new List();
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
		onStart(this);
		runNext();
	}

	function runNext() {
		if(fixtures.length > 0)
			runFixture(fixtures.pop());
		else
			onComplete(this);
	}

	public dynamic function onProgress(runner : Runner, result : TestResult, done : Int, totals : Int);
	public dynamic function onStart(r : Runner);
	public dynamic function onComplete(r : Runner);

	var counter : Int;
	function runFixture(fixture : TestFixture<Dynamic>) {
		var handler = new TestHandler(fixture);
		handler.onComplete = testComplete;
		handler.execute();
	}

	function testComplete(h : TestHandler<Dynamic>) {
		var result = TestResult.ofHandler(h);
		onProgress(this, result, fixtures.length+1, testsToRun);
		results.add(result);
		runNext();
	}
}