package utest.ui.common;

import utest.Assertation;

class FixtureResult {
	public var executionTime(default, null) : Int;
	public var methodName(default, null) : String;

	public var assertations(default, null) : Int;
	public var successes(default, null) : Int;
	public var failures(default, null) : Int;
	public var errors(default, null) : Int;
	public var warnings(default, null) : Int;

	public var isOk(default, null) : Bool;
	public var hasFailures(default, null) : Bool;
	public var hasErrors(default, null) : Bool;
	public var hasWarnings(default, null) : Bool;

	public var hasTestError(default, null) : Bool;
	public var hasSetupError(default, null) : Bool;
	public var hasTeardownError(default, null) : Bool;
	public var hasTimeoutError(default, null) : Bool;
	public var hasAsyncError(default, null) : Bool;

	var list(default, null) : List<Assertation>;
	public function new(executionTime : Int, methodName : String) {
		this.executionTime = executionTime;
		this.methodName = methodName;
		this.list = new List();

		assertations = 0;
		successes = 0;
		failures = 0;
		errors = 0;
		warnings = 0;

		isOk = true;
		hasFailures = false;
		hasErrors = false;
		hasWarnings = false;

		hasTestError = false;
		hasSetupError = false;
		hasTeardownError = false;
		hasTimeoutError = false;
		hasAsyncError = false;
	}

	public function iterator() {
		return list.iterator();
	}

	public function add(assertation : Assertation) {
		list.add(assertation);
		assertations++;
		switch(assertation) {
			case Success(_):
				successes++;
			case Failure(_, _):
				failures++;
				hasFailures = true;
				isOk = false;
			case Error(_):
				errors++;
				hasErrors = true;
				hasTestError = true;
				isOk = false;
			case SetupError(_):
				errors++;
				hasErrors = true;
				hasSetupError = true;
				isOk = false;
			case TeardownError(_):
				errors++;
				hasErrors = true;
				hasTeardownError = true;
				isOk = false;
			case TimeoutError(_):
				errors++;
				hasErrors = true;
				hasTimeoutError = true;
				isOk = false;
			case AsyncError(_):
				errors++;
				hasErrors = true;
				hasAsyncError = true;
				isOk = false;
			case Warning(_):
				warnings++;
				hasWarnings = true;
				isOk = false;
		}
	}
}