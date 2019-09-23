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
		try {
			setupAsync = fixture.setupMethod();
		}
		#if !UTEST_FAILURE_THROW
		catch(e:Dynamic) {
			results.add(SetupError(e, CallStack.exceptionStack()));
			completedFinally();
			return;
		}
		#end

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
		try {
			testAsync = test.execute();
		}
		#if !UTEST_FAILURE_THROW
		catch(e:Dynamic) {
			results.add(Error(e, CallStack.exceptionStack()));
			runTeardown();
			return;
		}
		#end

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
		try {
			teardownAsync = fixture.teardownMethod();
		}
		#if !UTEST_FAILURE_THROW
		catch(e:Dynamic) {
			results.add(TeardownError(e, CallStack.exceptionStack()));
			completedFinally();
			return;
		}
		#end

		teardownAsync.then(checkTeardown);
	}

	function checkTeardown() {
		if(teardownAsync.timedOut) {
			results.add(TeardownError('Teardown timeout', []));
		}
		completedFinally();
	}

	override function bindHandler() {
		if (wasBound) return;
		Assert.results = this.results;
		var msg = ' is not allowed in tests extending utest.ITest. Add `async:utest.Async` argument to the test method instead.';
		Assert.createAsync = function(?f, ?t) throw 'Assert.createAsync() $msg';
		Assert.createEvent = function(f, ?t) throw 'Assert.createEvent() $msg';
		wasBound = true;
	}

}
