package lang;

import utest.Assert;

class TestPhpDollarEscape {
	public function new() {}

	public function testDollar() {
		var dollar = "$a";
		Assert.equals("$" + "a", dollar);
	}
}