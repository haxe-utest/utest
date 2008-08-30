package utest;

import utest.Assertation;

class TestResult {
	public var pack          : String;
	public var cls           : String;
	public var method        : String;
	public var setup         : String;
	public var teardown      : String;
	public var executionTime : Int;
	public var assertations  : List<Assertation>;
/*
	public function hasSetup() {
		return setup != null;
	}

	public function hasTeardown() {
		return setup != null;
	}

	public function count() {
		return assertations.length;
	}

	public function successes() {
		return countAssertions(Success(null));
	}

	public function failures() {
		return countAssertions(Failure(null, null));
	}

	public function errors() {
		return countAssertions(Error(null));
	}

	public function setupErrors() {
		return countAssertions(SetupError(null));
	}

	public function teardownErrors() {
		return countAssertions(TeardownError(null));
	}

	public function timeoutErrors() {
		return countAssertions(TimeoutError(-1));
	}

	public function asyncErrors() {
		return countAssertions(AsyncError(null));
	}

	public function warnings() {
		return countAssertions(Warning(null));
	}

	public function allErrors() {
		return errors() + setupErrors() + teardownErrors() + timeoutErrors() + asyncErrors();
	}

	public function isOk() {
		return assertations.length == successes();
	}

	function countAssertions(type : Assertation) {
		var index = Type.enumIndex(type);
		var v = 0;
		for(assertation in assertations) {
			if(index == Type.enumIndex(assertation))
				v++;
		}
		return v;
	}
*/

	public function new();

	public static function ofHandler(handler : TestHandler<Dynamic>) {
		var r = new TestResult();
		var path = Type.getClassName(Type.getClass(handler.fixture.target)).split('.');
		r.cls           = path.pop();
		r.pack          = path.join('.');
		r.method        = handler.fixture.method;
		r.setup         = handler.fixture.setup;
		r.teardown      = handler.fixture.teardown;
		r.executionTime = handler.executionTime;
		r.assertations  = handler.results;
		return r;
	}
}