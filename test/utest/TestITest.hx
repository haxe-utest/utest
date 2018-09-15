package utest;

import haxe.Timer;

class TestITest extends Test {
	var setupClassCallCount = 0;
	var setupCallCount = 0;
	var teardownCallCount = 0;
	var teardownClassCallCount = 0;
	var setupClassRunning:Bool = false;
	var setupRunning:Bool = false;
	var teardownRunning:Bool = false;
	public var teardownClassRunning(default,null):Bool = false;

	override function setupClass():Null<Async> {
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

	override function setup():Null<Async> {
		setupRunning = true;

		if(setupClassRunning) {
			throw 'TestITest: setup() called before setupClass() finished.';
		}
		if(teardownRunning) {
			throw 'TestITest: setup() called before teardown() finished.';
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

	public function testAsync(async:Async) {
		var tm = Timer.stamp();
		if(setupRunning) {
			throw 'TestITest: test run before setup() finished.';
		}
		if(teardownRunning) {
			throw 'TestITest: setup() called before teardown() finished.';
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

	public function specTest() {
		Std.random(1) == 0;
		Std.random(1) != 1;
		Std.random(1) + 1 > 0;
		Std.random(1) + 1 >= 1;
		Std.random(1) + 1 <= 1;
		Std.random(1) + 1 < 2;
		!(Std.random(1) == 1);
		if(Std.random(1) == 0) {
			Std.random(1) == 0;
		}
	}

	public function testNormal() {
		if(setupRunning) {
			throw 'TestITest: test run before setup() finished.';
		}
		if(teardownRunning) {
			throw 'TestITest: setup() called before teardown() finished.';
		}

		Assert.equals(1, setupClassCallCount);
		Assert.isTrue(setupCallCount > 0);
	}

	override function teardown():Null<Async> {
		teardownRunning = true;

		if(setupRunning) {
			throw 'TestITest: teardown() called before setup() finished.';
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

	override function teardownClass():Null<Async> {
		teardownClassRunning = true;

		if(teardownRunning) {
			throw 'TestITest: teardownClass() called before teardown() finished.';
		}

		teardownClassCallCount++;

		if(setupClassCallCount != 1) {
			throw 'TestITest: setupClassCallCount should be called one time. Actual: $setupClassCallCount.';
		}
		var testCount = __initializeUtest__().length;
		if(setupCallCount != testCount) {
			throw 'TestITest: setupCallCount should be called once per test. Expected: $testCount, actual: $setupCallCount.';
		}
		if(teardownCallCount != testCount) {
			throw 'TestITest: teardownClassCallCount should be called once per test. Expected: $testCount, actual: $teardownCallCount.';
		}
		if(teardownClassCallCount != 1) {
			throw 'TestITest: teardownClassCallCount should be called one time. Actual: $teardownClassCallCount.';
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