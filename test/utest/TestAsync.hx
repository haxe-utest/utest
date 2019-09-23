package utest;

import haxe.Timer;

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

	function testBranch_allBranchesDone(async:Async) {
		var cnt = 0;
		async.branch(function(sub) {
			Timer.delay(
				function() {
					Assert.equals(0, cnt);
					cnt++;
					sub.done();
				},
				50
			);
		});
		var sub = async.branch();
		Timer.delay(
			function() {
				Assert.equals(1, cnt);
				sub.done();
			},
			100
		);
	}

	function testBranch_rootDone(async:Async) {
		var sub = async.branch();
		Timer.delay(function() sub.done(), 50); //more than default timeout (250)
		Assert.pass();
		async.done();
	}

	function testBranch_firstBranchDoneImmediately(async:Async) {
		async.branch(function(sub) sub.done());
		async.branch(function(sub) {
			Timer.delay(
				function() {
					Assert.pass();
					sub.done();
				},
				50
			);
		});
	}
}