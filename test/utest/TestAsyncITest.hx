package utest;

import haxe.Timer;

/**
 * Test asynchronous flow of ITest
 */
class TestAsyncITest extends Test {
	var setupClassCallCount = 0;
	var setupCallCount = 0;
	var teardownCallCount = 0;
	var teardownClassCallCount = 0;
	var setupClassRunning:Bool = false;
	var setupRunning:Bool = false;
	var teardownRunning:Bool = false;
	public var teardownClassRunning(default,null):Bool = false;

	function setupClass(async:Async) {
		setupClassRunning = true;
		setupClassCallCount++;
		Timer.delay(
			function() {
				setupClassRunning = false;
				async.done();
			},
			50
		);
	}

	function setup(async:Async) {
		setupRunning = true;

		if(setupClassRunning) {
			throw 'TestAsyncITest: setup() called before setupClass() finished.';
		}
		if(teardownRunning) {
			throw 'TestAsyncITest: setup() called before teardown() finished.';
		}

		setupCallCount++;
		Timer.delay(
			function() {
				setupRunning = false;
				async.done();
			},
			50
		);
	}

	function testAsync(async:Async) {
		var tm = Timer.stamp();
		if(setupRunning) {
			throw 'TestAsyncITest: test run before setup() finished.';
		}
		if(teardownRunning) {
			throw 'TestAsyncITest: setup() called before teardown() finished.';
		}

		var setupClassCallCount = setupClassCallCount;
		var setupCalled = setupCallCount > 0;
		Timer.delay(
			function() {
				Assert.equals(1, setupClassCallCount);
				Assert.isTrue(setupCalled);
				async.done();
			},
			50
		);
	}

	function testNormal() {
		if(setupRunning) {
			throw 'TestAsyncITest: test run before setup() finished.';
		}
		if(teardownRunning) {
			throw 'TestAsyncITest: setup() called before teardown() finished.';
		}

		Assert.equals(1, setupClassCallCount);
		Assert.isTrue(setupCallCount > 0);
	}

	function teardown(async:Async) {
		teardownRunning = true;

		if(setupRunning) {
			throw 'TestAsyncITest: teardown() called before setup() finished.';
		}

		teardownCallCount++;
		teardownRunning = false;
		Timer.delay(
			function() {
				teardownRunning = false;
				async.done();
			},
			50
		);
	}

	@:timeout(2500)
	function teardownClass(async:Async) {
		teardownClassRunning = true;

		if(teardownRunning) {
			throw 'TestAsyncITest: teardownClass() called before teardown() finished.';
		}

		teardownClassCallCount++;

		if(setupClassCallCount != 1) {
			throw 'TestAsyncITest: setupClassCallCount should be called one time. Actual: $setupClassCallCount.';
		}
		var testCount = #if display 0 #else  __initializeUtest__().tests.length #end;
		if(setupCallCount != testCount) {
			throw 'TestAsyncITest: setupCallCount should be called once per test. Expected: $testCount, actual: $setupCallCount.';
		}
		if(teardownCallCount != testCount) {
			throw 'TestAsyncITest: teardownClassCallCount should be called once per test. Expected: $testCount, actual: $teardownCallCount.';
		}
		if(teardownClassCallCount != 1) {
			throw 'TestAsyncITest: teardownClassCallCount should be called one time. Actual: $teardownClassCallCount.';
		}

		Timer.delay(
			function() {
				teardownClassRunning = false;
				async.done();
			},
			1750
		);
	}
}