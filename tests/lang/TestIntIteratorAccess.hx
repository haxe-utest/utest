package lang;

import utest.Assert;

class TestIntIteratorAccess {
	public function new() {}

	public function testIterator() {
		var ref = 5;
		var range = 5...10;
		for(i in range) {
			Assert.equals(ref, i);
			ref++;
		}
	}
}