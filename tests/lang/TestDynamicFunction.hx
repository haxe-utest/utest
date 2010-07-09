package lang;

import utest.Assert;
import lang.util.ImplementsDynamic;
import lang.util.F9Dynamic;
import lang.util.MethodVariable;

class TestDynamicFunction {
	public function new() {}

	public function testArrayReference() {
		var f = function() Assert.isTrue(true);
		var a = [f];
		a[0]();
		a.pop()();
	}

	public function testListReference() {
		var f = function() Assert.isTrue(true);
		var list = new List();
		list.add(f);
		list.pop()();
	}

	public function testUnsetReferenceInLoop() {
		var h = new Hash();
		h.set("a", function() return "a");
		h.set("b", function() return "b");
		var o = { a : null, b : null };

		for(n in h.keys()) {
			var f = h.get(n);
			Reflect.setField(o, n, function() return f());
		}

		Assert.equals("a", o.a());
		Assert.equals("b", o.b());
	}

#if !(flash9 || cpp)
	public function testFastListReference() {
		var f = function() Assert.isTrue(true);
		var list = new haxe.FastList();
		list.add(f);
		list.pop()();
	}
#end

	public function testInline() {
		var f = function() { return "test"; };
		Assert.equals("test", f());
	}

	public function testInline2() {
		var f = function() {
			return '<a href="/file/';
		};
		Assert.equals('<a href="/file/', f());
	}

	public function testLocalExecution() {
		Assert.equals("test", function() { return "test"; }());
	}

	public function testLocalExecutionWithParam() {
		Assert.equals("test1", function(i : Int) { return "test" + i; }(1));
	}

	function passFunction(f : Void -> String) {
		return f();
	}

	public function testArgument1() {
		var f = function() { return "test"; };
		Assert.equals("test", passFunction(f));
	}

	public function testArgument2() {
		Assert.equals("test", passFunction(function() { return "test"; }));
	}

	public function testAnonymousObject1() {
		var a = { f : function(){ return "test"; } };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject2() {
		var a : Dynamic = {};
		a.f = function(){ return "test"; };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject3() {
		var a = { f : f };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject4() {
		var a : Dynamic = {};
		a.f = f;
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject5() {
		var a = { f : staticF };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject6() {
		var a : Dynamic = {};
		a.f = staticF;
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicAddMethod1() {
		var a = new ImplementsDynamic();
		a.f = function(){ return "test"; };
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicAddMethod2() {
		var a = new ImplementsDynamic();
		a.f = f;
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicAddMethod3() {
		var a = new ImplementsDynamic();
		a.f = staticF;
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicRedefineMethod1() {
		var a = new ImplementsDynamic();
		Assert.equals("stub", a.stub());
		a.stub = function(){ return "test"; };
		Assert.equals("test", a.stub());
	}

	public function testImplementsDynamicRedefineMethod2() {
		var a = new ImplementsDynamic();
		Assert.equals("stub", a.stub());
		a.stub = f;
		Assert.equals("test", a.stub());
	}

	public function testImplementsDynamicRedefineMethod3() {
		var a = new ImplementsDynamic();
		Assert.equals("stub", a.stub());
		a.stub = staticF;
		Assert.equals("test", a.stub());
	}

	public function testF9DynamicRedefineMethod1() {
		var a = new F9Dynamic();
		Assert.equals("stub", a.stub());
		a.stub = function(){ return "test"; };
		Assert.equals("test", a.stub());
	}

	public function testF9DynamicRedefineMethod2() {
		var a = new F9Dynamic();
		Assert.equals("stub", a.stub());
		a.stub = f;
		Assert.equals("test", a.stub());
	}

	public function testF9DynamicRedefineMethod3() {
		var a = new F9Dynamic();
		Assert.equals("stub", a.stub());
		a.stub = staticF;
		Assert.equals("test", a.stub());
	}

	public function testMethodVariable1() {
		var a = new MethodVariable();
		a.f = function(){ return "test"; };
		Assert.equals("test", a.f());
	}

	public function testMethodVariable2() {
		var a = new MethodVariable();
		a.f = f;
		Assert.equals("test", a.f());
	}

	public function testMethodVariable3() {
		var a = new MethodVariable();
		a.f = staticF;
		Assert.equals("test", a.f());
	}

	public function testStaticMethodVariable1() {
		MethodVariable.staticF = function(){ return "test1"; };
		Assert.equals("test1", MethodVariable.staticF());
	}

	public function testStaticMethodVariable2() {
		MethodVariable.staticF = f;
		Assert.equals("test", MethodVariable.staticF());
	}

	public function testStaticMethodVariable3() {
		MethodVariable.staticF = staticF;
		Assert.equals("test", MethodVariable.staticF());
		Assert.equals("test", lang.util.MethodVariable.staticF());
	}

	public function testStaticMethodFullyQualifiedName() {
		Assert.equals("test", lang.util.C.test());
		Assert.equals("test", lang.util.C.s);
  	}

	public function testDynamicFunctionOnThis() {
		val = "test";
		Assert.equals("test!", getVal());
		var me = this;
		getVal = function() { return me.val + "!?"; };
		Assert.equals("test!?", getVal());
	}

	private var val : String;
	private dynamic function getVal() {
		return val + "!";
	}

	private var f2(default, setDynamicFunction) : String;

	private dynamic function setDynamicFunction(v : String) {
		return f2 = v +"!";
	}

	private static var sf2(default, setStaticDynamicFunction) : String;

	private static dynamic function setStaticDynamicFunction(v : String) {
		return sf2 = v +"!";
	}

	private function f() {
		return "test";
	}

	private static function staticF() {
		return "test";
	}

	public function testClosureLocalInfluence() {
		var b = 0;
		var f = function() { b++; };
		f();
		Assert.equals(1, b);
		f();
		Assert.equals(2, b);
	}

	public function testInternalRedefine() {
		Assert.equals("aa", intern("a"));
		Assert.equals("ab", intern("b"));
		Assert.equals("ac", intern("c"));
	}

	private dynamic function intern(s : String) {
		intern = function(x) {
			return s + x;
		}
		return intern(s);
	}

	public function testAssign() {
		var expected = Math.cos(0);
		var f = Math.cos;
        Assert.equals(expected, f(0));

	}

	public function testAssign2() {
		var expected = Math.cos(0);
		var o = { cos : Math.cos };
        Assert.equals(expected, o.cos(0));
	}

	public function testScope1() {
		var a : {x : Int, f : Void->Int} = null;
		a = {
			x : 1,
			f : function() {return untyped a.x; }
		};

		var b = {
			x : 2,
			f : a.f
		};

		Assert.equals(1, b.f());
	}

	public function testScope2() {
		var a = new Scope1();
		Assert.equals(1, a.f());
		var b = new Scope2();
		Assert.equals(2, b.f());
		b.f = a.f;
		Assert.equals(1, b.f());
	}


	public function testCapture() {
		// read
		var fun = null;
		fun = function(i) return i;
		Assert.equals(1, fun(1));
		// write
		var fun = null;
		var sum = 0;
		var k = 0;
		fun = function() { k++; sum++; return k; };
		Assert.equals(1, fun());
		Assert.equals(1, sum);
	}
}

private class Scope1 {
	var a : Int;
	public function new() {
		a = 1;
	}
	dynamic public function f() {
		return a;
	}
}

private class Scope2 {
	var a : Int;
	public function new() {
		a = 2;
	}
	dynamic public function f() {
		return a;
	}
}