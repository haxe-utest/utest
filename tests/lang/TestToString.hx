package lang;

import utest.Assert;

class TestToString {
	public function new() {}

	public function testObjectToString() {
		var date = new Date(2008, 0, 1, 0, 0, 0);
		Assert.equals("a2008-01-01 00:00:00", "a" + date);
	}

	public function testAnonymToString() {
		Assert.equals("a{ x => haXe }", "a" + { x : 'haXe' });
	}
}