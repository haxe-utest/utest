package utest;

class TestAsync extends Test {
	public function testResolved() {
		var async = Async.getResolved();
		Assert.isTrue(async.resolved);
	}

	public function testDone() {
		var async = new Async();
		async.then(function() Assert.pass());
		async.done();
	}

	public function testDone_resolved() {
		var async = Async.getResolved();
		async.then(function() Assert.pass());
	}
}