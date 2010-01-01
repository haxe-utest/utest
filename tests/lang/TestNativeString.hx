package lang;

import utest.Assert;

class TestNativeString {
	public function new() {}

	private var st : String;
	private var dy : Dynamic;

	static function dref(s : String) : Dynamic {
		return s;
	}

	static function darg(d : Dynamic) : Dynamic {
		return d;
	}

	static function dtarg(d : Dynamic) : String {
		return d;
	}

	public function testNullable() {
		var s : Null<String> = "haXe";
		Assert.equals("h", s.substr(0, 1));
	}

	public function testD() {
		var d : Dynamic = "string";
		dy = "string";
		Assert.equals("s", d.substr(0, 1));
		Assert.equals("s", dy.substr(0, 1));
	}

	public function testDD() {
		var d1 : Dynamic = "string";
		var d2 : Dynamic = "string";
		var d3 : Dynamic = "String";
		st = "String";
		dy = "string";
		Assert.isTrue(d1 == d2);
		Assert.isTrue(d1 != d3);
		Assert.isTrue(d1 != st);
		Assert.isTrue(d3 == st);
		Assert.isTrue(d3 != dy);
		Assert.isTrue(d1 == dy);
	}

	public function testDConcatenation() {
		var d : Dynamic = "s";
		dy = "s";
		Assert.equals("st", d + "t");
		Assert.equals("st", dy + "t");
	}

	public function testDRef() {
		var s = "s";
		var d = dref(s);
		dy = dref(s);
		Assert.equals("s", d);
		Assert.equals("s", dy);
		Assert.equals("s", dref("s"));
	}

	public function testDArg() {
		var s = "s";
		var ds : Dynamic = "s";
		var d = darg(s);
		dy = darg(s);
		Assert.equals("s", d);
		Assert.equals("s", dy);
		Assert.equals("s", darg("s"));
		Assert.equals("s", darg(ds));
	}

	public function testDT() {
		var s = "s";
		var d = dtarg(s);
		dy = dtarg(s);
		Assert.equals("s", d);
		Assert.equals("s", dy);
		Assert.equals("s", dtarg("s"));
	}

	public function testDoubleBox() {
		var d1 : Dynamic = "s";
		var d2 : Dynamic = d1; // this must not be boxed
		Assert.equals("s", d2);
	}

	public function testUntypedCast() {
		var d1 : Dynamic = "s";
		var s : String = cast d1;
		Assert.equals(1, s.length);
		Assert.equals(1, d1.length);
	}

	public function testCast() {
		var d1 : Dynamic = "s";
		var s : String = cast(d1, String);
		Assert.equals(1, s.length);
		Assert.equals(1, d1.length);
	}

	public function testEnum() {
		var s1 = str("s");
		var s2 = dstr("s");
		enumAssert(s1, "s");
		enumAssert(s2, "s");
	}

	static function enumAssert(e : NativesStringEnum, ?aeq : Array<Int>, ?seq : String) {
		switch(e) {
			case str(s):
				Assert.equals(seq.length, s.length);
				Assert.equals(seq, s);
			case dstr(s):
				Assert.equals(seq.length, s.length);
				Assert.equals(seq, s);
			default:
				Assert.fail();
		}
	}
#if php // this should proabably unified in php and fail as in other platoforms
	public function testReflectField() {
		var s = "haXe";
		Assert.equals(4, Reflect.field(s, 'length'));
		var f = Reflect.field(s, 'toUpperCase');
		Assert.equals('HAXE', f());
	}

	public function testReflectCallMethod() {
		var s = "haXe";
		Assert.equals('h', Reflect.callMethod(s, 'substr', [0, 1]));
	}

	public function testReflectFields() {
		var fields = Reflect.fields("haXe");
		var expected = ["substr", "charAt", "charCodeAt", "indexOf", "lastIndexOf", "split", "toLowerCase", "toUpperCase", "toString", "length"];
		Assert.isTrue(fields.length > 0);
		for(field in fields)
			Assert.isTrue(Lambda.has(expected, field));
	}
	
	public function testReflectCompareMethods() {
		var s = '.';
		Assert.equals(s.substr, s.substr);
	}
	
	public function testCreateEmptyInstance() {
		var s = Type.createEmptyInstance(String);
		// TODO, check other platforms on this
		Assert.equals('', s);
	}
	
	public function testTypeGetInstanceFields() {
		var fields = Type.getInstanceFields(String);
		var expected = ["substr", "charAt", "charCodeAt", "indexOf", "lastIndexOf", "split", "toLowerCase", "toUpperCase", "toString", "length"];
		Assert.isTrue(fields.length > 0);
		for(field in fields)
			Assert.isTrue(Lambda.has(expected, field));
	}

	public function testTypeGetClassFields() {
		var fields = Type.getClassFields(String);
		var expected = ["fromCharCode"];
		Assert.isTrue(fields.length > 0);
		for(field in fields)
			Assert.isTrue(Lambda.has(expected, field));
	}
	
	public function testReflectCopy() {
		var s1 = 'haXe';
		var s2 = Reflect.copy(s1);
		Assert.equals(s1, s2);
	}
#end
	
	public function testReflectIsFunction1() {
		var s = '.';
		Assert.isTrue(Reflect.isFunction(s.substr));
	}

	public function testReflectIsFunction2() {
		var s = '.';
		var f = Reflect.field(s, 'toUpperCase');
		Assert.isTrue(Reflect.isFunction(f));
	}

	public function testReflectIsObject() {
		var s = 'haXe';
		var d : Dynamic = 'Neko';
		Assert.isTrue(Reflect.isObject(s));
		Assert.isTrue(Reflect.isObject(d));
	}

	public function testCreateInstance() {
		var s = Type.createInstance(String, ['']);
		// TODO, check other platforms on this
		Assert.equals('', s);
	}
}

enum NativesStringEnum {
	str(s : String);
	dstr(s : Dynamic);
}