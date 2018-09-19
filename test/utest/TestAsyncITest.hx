package utest;

import haxe.Timer;

class TestAsyncITest extends Test {
	var setupClassCallCount = 0;
	var setupCallCount = 0;
	var teardownCallCount = 0;
	var teardownClassCallCount = 0;
	var setupClassRunning:Bool = false;
	var setupRunning:Bool = false;
	var teardownRunning:Bool = false;
	public var teardownClassRunning(default,null):Bool = false;

	function setupClass():Async {
		setupClassRunning = true;
		setupClassCallCount++;
		var async = new Async();
		Timer.delay(
			function() {
				setupClassRunning = false;
				async.done();
			},
			50);
		return async;
	}

	function setup():Async {
		setupRunning = true;

		if(setupClassRunning) {
			throw 'TestAsyncITest: setup() called before setupClass() finished.';
		}
		if(teardownRunning) {
			throw 'TestAsyncITest: setup() called before teardown() finished.';
		}

		setupCallCount++;
		var async = new Async();
		Timer.delay(
			function() {
				setupRunning = false;
				async.done();
			},
			50);
		return async;
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

	function teardown():Async {
		teardownRunning = true;

		if(setupRunning) {
			throw 'TestAsyncITest: teardown() called before setup() finished.';
		}

		teardownCallCount++;
		teardownRunning = false;
		var async = new Async();
		Timer.delay(
			function() {
				teardownRunning = false;
				async.done();
			},
			50);
		return async;
	}

	function teardownClass():Async {
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

		var async = new Async(2000);
		Timer.delay(
			function() {
				teardownClassRunning = false;
				async.done();
			},
			1750);
		return async;
	}
}