package lang;

import utest.Assert;

class TestIfAccess {
	public function new() {}

	public function testIf() {
		if(true)
			Assert.isTrue(true);

		if(false)
			Assert.isTrue(false);

		if(true)
			Assert.isTrue(true);
		else
			Assert.isTrue(false);

		if(false)
			Assert.isTrue(false);
		else
			Assert.isTrue(true);
	}

	public function testDirectAssignament() {
		var a = if(true) 1;
		Assert.equals(1, a);
		a = if(false) 2;
		Assert.isNull(a);
		a = if(false) 1 else 2;
		Assert.equals(2, a);
	}

	public function testBlockAssignament() {
		var a = if(true) { Assert.isTrue(true); 1; };
		Assert.equals(1, a);
		a = if(false) { Assert.isTrue(true); 2; };
		Assert.isNull(a);
		a = if(false) { Assert.isTrue(true); 1; } else { Assert.isTrue(true); 2; };
		Assert.equals(2, a);
	}

	public function testNestedBlockAssignament() {
		var a = if(true) { if(false) { Assert.isTrue(false); 2; } else { Assert.isTrue(true); 1; }; };
		Assert.equals(1, a);
	}
}