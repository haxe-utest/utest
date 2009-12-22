package lang;

import utest.Assert;

import lang.util.A;
import lang.util.B;

class TestClassInheritance {
	public function new() {}
	public function testSuperAccess() {
	  var a = new A();
	  Assert.equals("test", a.msg());
	  var b = new B();
	  Assert.equals("testtest", b.msg());
	}
}