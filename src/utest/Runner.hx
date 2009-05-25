package utest;

import utest.Dispatcher;

/**
* The Runner class performs a set of tests. The tests can be added using addCase or addFixtures.
* Once all the tests are register they are axecuted on the run() call.
* Note that Runner does not provide any visual output. To visualize the test results use one of
* the classes in the utest.ui package.
* @todo complete documentation
*/
class Runner {
	var fixtures(default, null) : Array<TestFixture<Dynamic>>;

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
	* The number of fixtures registered.
	*/
	public var length(default, null)      : Int;
	/**
	* Instantiates a Runner onject.
	*/
	public function new() {
		fixtures   = new Array();
		onProgress = new Dispatcher();
		onStart    = new Dispatcher();
		onComplete = new Dispatcher();
		length = 0;
	}

	/**
	* Adds a new test case.
	* @param	test: must be a not null object
	* @param	setup: string name of the setup function (defaults to "setup")
	* @param	teardown: string name of the teardown function (defaults to "teardown")
	* @param	prefix: prefix for methods that are tests (defaults to "test")
	* @param	pattern: a regular expression that discriminates the names of test
	* 			functions; when set,  the prefix parameter is meaningless
	*/
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