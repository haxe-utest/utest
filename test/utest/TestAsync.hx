package utest;

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
}