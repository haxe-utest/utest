package lang;

import utest.Assert;

class TestToString {
	public function new() {}

	public function testObjectToString() {
		var date = new Date(2008, 0, 1, 0, 0, 0);
		Assert.equals("a2008-01-01 00:00:00", "a" + Std.string(date));
	}

	public function testAnonymToString() {
		Assert.stringSequence([
			"a{",  "x", "haXe", "}"
		],
		"a" + Std.string({ x : 'haXe' }));
	}
}