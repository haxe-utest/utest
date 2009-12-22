package lang;

import utest.Assert;

import lang.util.ImplementsDynamic;
import lang.util.SubImplementsDynamic;

class TestDynamicClass {
	public function new() {}
	
	public function testDynamic() {
		var o = new ImplementsDynamic();
		o.n = "haXe";
		Assert.equals("haXe", o.n);
	}
	
	public function testConstrainedDynamic() {
		var o = new SubImplementsDynamic();
		o.n = 1;
		Assert.equals(1, o.n);
	}
}