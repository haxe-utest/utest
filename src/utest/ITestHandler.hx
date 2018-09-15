package utest;

import haxe.CallStack;

using utest.utils.AsyncUtils;

class ITestHandler<T> extends TestHandler<T> {
	var testCase:ITest;
	var test:TestData;
	var setupAsync:Null<Async>;
	var testAsync:Null<Async>;
	var teardownAsync:Null<Async>;

	public function new(fixture:TestFixture) {
		super(fixture);
		if(!fixture.isITest) {
			throw 'Invalid fixture type for utest.ITestHandler';
		}
		testCase = cast(fixture.target, ITest);
		test = fixture.test;
		if(test == null) {
			throw 'Fixture is missing test data';
		}
	}

	override public function execute() {
		if (fixture.ignoringInfo.isIgnored) {
			executeFinally();
			return;
		}
		bindHandler();
		runSetup();
	}

	function runSetup() {
		setupAsync = Async.getResolved();
		try {
			setupAsync = testCase.setup().orResolved();
		} catch(e:Dynamic) {
			results.add(SetupError(e, CallStack.exceptionStack()));
			completedFinally();
			return;
		}

		setupAsync.then(checkSetup);
	}

	function checkSetup() {
		if(setupAsync.timedOut) {
			results.add(SetupError('Setup timeout', []));
			completedFinally();
		} else {
			runTest();
		}
	}

	function runTest() {
		testAsync = test.async.orResolved();
		try {
			test.execute();
		} catch(e:Dynamic) {
			results.add(Error(e, CallStack.exceptionStack()));
			runTeardown();
			return;
		}

		testAsync.then(checkTest);
	}

	function checkTest() {
		onPrecheck.dispatch(this);

		if(testAsync.timedOut) {
			results.add(TimeoutError(1, []));
			onTimeout.dispatch(this);

		} else if(testAsync.resolved) {
			if(results.length == 0) {
				results.add(Warning('no assertions'));
			}
			onTested.dispatch(this);

		} else {
			throw 'Unexpected test state';
		}

		runTeardown();
	}

	function runTeardown() {
		teardownAsync = Async.getResolved();
		try {
			teardownAsync = testCase.teardown().orResolved();
		} catch(e:Dynamic) {
			results.add(TeardownError(e, CallStack.exceptionStack()));
			completedFinally();
			return;
		}

		teardownAsync.then(checkTeardown);
	}

	function checkTeardown() {
		if(teardownAsync.timedOut) {
			results.add(SetupError('Teardown timeout', []));
		}
		completedFinally();
	}

	override function bindHandler() {
		if (wasBound) return;
		Assert.results = this.results;
		var msg = ' is not allowed in tests extending utest.ITest. Add `async:utestAsync` argument to the test method instead.';
		Assert.createAsync = function(?f, ?t) throw 'Assert.createAsync() $msg';
		Assert.createEvent = function(f, ?t) throw 'Assert.createEvent() $msg';
		wasBound = true;
	}

}
