package lang;

import utest.Assert;

class TestPrivateClassAccess {
	public function new() {}
	public function testInstance() {
		var v = new PrivateClass();
		Assert.equals("test", v.test());
	}
}

class PrivateClass {
	public function new() {}
	public function test() { return "test"; }
}