package utest;

import haxe.Timer;

class TestAsync extends Test {
	function testResolved() {
		var async = Async.getResolved();
		Assert.isTrue(async.resolved);
	}

	function testDone() {
		var async = new Async();
		async.then(function() Assert.pass());
		async.done();
	}

	function testDone_resolved() {
		var async = Async.getResolved();
		async.then(function() Assert.pass());
	}

	@:timeout(1000)
	function testTimeout(async:Async) {
		Timer.delay(
			function() {
				Assert.pass();
				async.done();
			},
			300 //more than default timeout (250)
		);
	}

	function testSetTimeout(async:Async) {
		async.setTimeout(1000);
		Timer.delay(
			function() {
				Assert.pass();
				async.done();
			},
			300 //more than default timeout (250)
		);
	}
}

@:timeout(1000)
class TestClassTimeout extends Test {
	function testClassTimeout(async:Async) {
		Timer.delay(
			function() {
				Assert.pass();
				async.done();
			},
			300 //more than default timeout (250)
		);
	}
}