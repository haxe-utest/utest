package lang;

import utest.Assert;

import lang.util.A;
import lang.util.B;

// cases with === or !== have been commented because inconsistents in several platforms.
// Those operators maybe be removed in a future version.

class TestEqualityOperators {
	public function new() {}
	
	public function testInt() {
		Assert.isTrue (0 == 0);
		Assert.isFalse(0 != 0);
	}


#if !flash9
	public function testFloatInt() {
    Assert.isTrue (0 == 0.0);
	}
#end


	public function testFloatIntVar() {
		var i = 0;
		var f = 0.0;
		Assert.isTrue (i ==  f);
		Assert.isFalse(i !=  f);
	}

#if !flash9
	public function testIntNullity() {
		Assert.isTrue (0 !=  null);
		Assert.isFalse(0 ==  null);
	}
#end

	public function testIntVar() {
		var i1 = 0;
		var i2 = 0;
		Assert.isTrue (i1 ==  i2);
		Assert.isFalse(i1 !=  i2);
	}

	public function testIntNullityVar() {
		var n = null;
		var i : Null<Int> = 0;
		Assert.isTrue( i !=  n);
		Assert.isFalse(i ==  n);
	}

	public function testIntNullityVar2() {
		var n : Null<Int> = null;
		var i : Null<Int> = 0;
		Assert.isTrue( i !=  n);
		Assert.isFalse(i ==  n);
	}

#if !flash9
	public function testFloatNullity() {
		Assert.isTrue (0.0 !=  null);
		Assert.isFalse(0.0 ==  null);
	}
#end

	public function testFloatNullityVar() {
		var n = null;
		var f : Null<Float> = 0.0;
		Assert.isTrue (f !=  n);
		Assert.isFalse(f ==  n);
	}

	public function testFloatIntDynamic1() {
		var i : Dynamic = 0;
		var f = 0.0;
		Assert.isTrue (i ==  f);
		Assert.isFalse(i !=  f);
	}

	public function testFloatIntDynamic2() {
		var i = 0;
		var f : Dynamic = 0.0;
		Assert.isTrue (i ==  f);
		Assert.isFalse(i !=  f);
	}

	public function testFloatIntDynamic3() {
		var i : Dynamic = 0;
		var f : Dynamic = 0.0;
		Assert.isTrue (i ==  f);
		Assert.isFalse(i !=  f);
	}

	public function testNull() {
		Assert.isTrue(null == null);
		Assert.isTrue(null == null);
	}


	public function testString() {
		Assert.isTrue ("a" ==  "a");
		Assert.isFalse("a" !=  "a");
		Assert.isTrue ("a" !=  null);
	}

	public function testStringVar() {
		var s1 = "a";
		var s2 = "a";
		Assert.isTrue (s1 == s2);
		Assert.isFalse(s1 != s2);
	}

	public function testStringDynamic1() {
		var s1 : Dynamic = "a";
		var s2 = "a";
		Assert.isTrue (s1 == s2);
		Assert.isFalse(s1 != s2);
	}

	public function testStringDynamic2() {
		var s1 = "a";
		var s2 : Dynamic = "a";
		Assert.isTrue (s1 == s2);
		Assert.isFalse(s1 != s2);
	}

	public function testStringDynamic3() {
		var s1 : Dynamic = "a";
		var s2 : Dynamic = "a";
		Assert.isTrue (s1 == s2);
		Assert.isFalse(s1 != s2);
	}

	public function testStringNullityDynamic1() {
		var n : Dynamic = null;
		var i = "a";
		Assert.isTrue (i !=  n);
		Assert.isFalse(i ==  n);
	}

	public function testStringNullityDynamic2() {
		var n = null;
		var i : Dynamic = "a";
		Assert.isTrue (i !=  n);
		Assert.isFalse(i ==  n);
	}

	public function testStringNullityDynamic3() {
		var n : Dynamic = null;
		var i : Dynamic = "a";
		Assert.isTrue (i !=  n);
		Assert.isFalse(i ==  n);
	}

	public function testIntNullityDynamic1() {
		var n : Dynamic = null;
		var i : Null<Int> = 0;
		Assert.isTrue (i !=  n);
		Assert.isFalse(i ==  n);
	}

	public function testIntNullityDynamic2() {
		var n = null;
		var i : Dynamic = 0;
		Assert.isTrue (i !=  n);
		Assert.isFalse(i ==  n);
	}

	public function testIntNullityDynamic3() {
		var n : Dynamic = null;
		var i : Dynamic = 0;
		Assert.isTrue (i !=  n);
		Assert.isFalse(i ==  n);
	}

	public function testFloatNullityDynamic1() {
		var n : Dynamic = null;
		var f : Null<Float> = 0.0;
		Assert.isTrue (f !=  n);
		Assert.isFalse(f ==  n);
	}

	public function testFloatNullityDynamic2() {
		var n = null;
		var f : Dynamic = 0.0;
		Assert.isTrue (f !=  n);
		Assert.isFalse(f ==  n);
	}

	public function testFloatNullityDynamic3() {
		var n : Dynamic = null;
		var f : Dynamic = 0.0;
		Assert.isTrue (f !=  n);
		Assert.isFalse(f ==  n);
	}

	public function testAnonymous() {
		Assert.isTrue ({ name : "haXe" } !=  { name : "haXe" });
		Assert.isFalse({ name : "haXe" } ==  { name : "haXe" });
	}

	public function testAnonymousVar() {
		var x = { name : "haXe" };
		var y = { name : "haXe" };
		var z = { name : "neko" };
		Assert.isTrue (x !=  y);
		Assert.isTrue (x !=  z);
		Assert.isFalse(x !=  x);
		Assert.isTrue (x ==  x);
		Assert.isFalse(x ==  y);
		Assert.isFalse(x ==  z);
	}

	public function testAnonymousDynamic1() {
		var x : Dynamic = { name : "haXe" };
		var y = { name : "haXe" };
		var z = { name : "neko" };
		Assert.isTrue (x !=  y);
		Assert.isTrue (x !=  z);
		Assert.isFalse(x !=  x);
		Assert.isTrue (x ==  x);
		Assert.isFalse(x ==  y);
		Assert.isFalse(x ==  z);
	}

	public function testAnonymousDynamic2() {
		var x : Dynamic = { name : "haXe" };
		var y : Dynamic = { name : "haXe" };
		var z = { name : "neko" };
		Assert.isTrue (x !=  y);
		Assert.isTrue (x !=  z);
		Assert.isFalse(x !=  x);
		Assert.isTrue (x ==  x);
		Assert.isFalse(x ==  y);
		Assert.isFalse(x ==  z);
	}

	public function testInstance() {
		Assert.isTrue(new A() !=  new A());
		Assert.isTrue(new A() !=  new B());
		Assert.isFalse(new A() ==  new B());
	}

	public function testInstanceVar() {
		var x = new A();
		var y = new A();
		var z = new B();
		Assert.isTrue(x ==  x);
		Assert.isTrue(x !=  z);
		Assert.isTrue(x !=  y);
	}

	public function testInstanceDynamic1() {
		var x : Dynamic = new A();
		var y = new A();
		var z = new B();
		Assert.isTrue(x ==  x);
		Assert.isTrue(x !=  z);
		Assert.isTrue(x !=  y);
	}

	public function testInstanceDynamic2() {
		var x : Dynamic = new A();
		var y : Dynamic = new A();
		var z = new B();
		Assert.isTrue(x ==  x);
		Assert.isTrue(x !=  z);
		Assert.isTrue(x !=  y);
	}

#if !flash9
	public function testBool() {
		Assert.isTrue (true  != null);
		Assert.isTrue (false != null);
		Assert.isFalse(true  == null);
		Assert.isFalse(false == null);
	}

	public function testBoolDynamic1() {
		var t : Dynamic = true;
		var f : Dynamic = false;
		var z : Bool = null;
		Assert.isTrue (t != z);
		Assert.isTrue (f != z);
		Assert.isFalse(t == z);
		Assert.isFalse(f == z);
	}
#end

	public function testBoolDynamic2() {
		var t : Bool = true;
		var f : Bool = false;
		var z : Dynamic = null;
		Assert.isTrue (t != z);
		Assert.isTrue (f != z);
		Assert.isFalse(t == z);
		Assert.isFalse(f == z);
	}

	public function testBoolDynamic3() {
		var t : Dynamic = true;
		var f : Dynamic = false;
		var z : Dynamic = null;
		Assert.isTrue (t != z);
		Assert.isTrue (f != z);
		Assert.isFalse(t == z);
		Assert.isFalse(f == z);
	}
}