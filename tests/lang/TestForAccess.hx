package lang;

import utest.Assert;

class TestForAccess {
	public function new() {}

	public function testForeach() {
		var a = [1, 2, 3];
		var test = 1;
		for(x in a) {
			Assert.equals(test, x);
			test++;
		}
	}

	public function testFor() {
		var a = [1, 2, 3];
		var i = 0;
		for(x in 1...3) {
			Assert.equals(a[i], x);
			i++;
		}
	}

	public function testForBreak() {
		var a = [1, 2, 3];
		var i = 0;
		for(x in 1...3) {
			Assert.equals(a[i], x);
			i++;
			break;
		}
		Assert.equals(1, i);
	}

	public function testForeachBreak() {
		var a = [1, 2, 3];
		var test = 1;
		for(x in a) {
			Assert.equals(test, x);
			test++;
			break;
		}
		Assert.equals(2, test);
	}

	public function testForContinue() {
		var a = [1, 2, 3];
		var i = 0;
		for(x in 1...3) {
			Assert.equals(a[i], x);
			i++;
			continue;
			Assert.isTrue(false); // this must not be executed
		}
		Assert.equals(2, i);
	}

	public function testForeachContinue() {
		var a = [1, 2, 3];
		var test = 1;
		for(x in a) {
			Assert.equals(test, x);
			test++;
			continue;
			Assert.isTrue(false); // this must not be executed
		}
		Assert.equals(4, test);
	}
}