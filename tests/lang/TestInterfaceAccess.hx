package lang;

import utest.Assert;
import lang.util.T;
import lang.util.ITest;

class TestInterfaceAccess {
	public function new() {}
	public function testDirect() {
		var a : ITest = new T();
		a.msg = "test";
		Assert.equals("test", a.test());
	}
	
	public function testIndirect1() {
		var a = new T();
		Assert.equals("test", indirect(a));
	}
	
	public function testIndirect2() {
		Assert.equals("test", indirect(new T()));
	}
	
	function indirect(v : ITest) {
		v.msg = "test";
		return v.test();
	}
}