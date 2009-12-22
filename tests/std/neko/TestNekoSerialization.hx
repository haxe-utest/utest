package std.neko;

import utest.Assert;

class TestObject {
	public var i : Int;
	public var f : Float;
	public var s : String;
	public var a : Array<Int>;

	public function new(){
		i = 100;
		f = 0.4343;
		s = "some string";
		a = [0,1,2];
	}

	public function toString() : String {
		return i+"|"+f+"|"+s+"|"+Std.string(a);
	}
}

class TestNekoSerialization {
	public function new(){}

	public function testInt(){
		var s = 100;
		var a1 = neko.Lib.serialize(s);
		var a2 = neko.Lib.unserialize(a1);
		Assert.equals(s, a2);
	}

	public function testFloat(){
		var s = 100.094343;
		var a1 = neko.Lib.serialize(s);
		var a2 = neko.Lib.unserialize(a1);
		Assert.equals(s, a2);
	}

	public function testString(){
		var s = "Test";
		var a1 = neko.Lib.serialize(s);
		var a2 = neko.Lib.unserialize(a1);
		Assert.equals(s, a2);
	}

	public function testIntArray(){
		var s = [1,2,3];
		var a1 = neko.Lib.serialize(s);
		var a2 = neko.Lib.unserialize(a1);
		Assert.equals(Std.string(s), Std.string(a2));
	}

	public function testStrintArray(){
		var s = ["1","2","3"];
		var a1 = neko.Lib.serialize(s);
		var a2 = neko.Lib.unserialize(a1);
		Assert.equals(Std.string(s), Std.string(a2));
	}

	public function testAnonymousObject(){
		var s = { i:100, f:0.4343, s:"some string", a:[0,1,2] };
		var a1 = neko.Lib.serialize(s);
		var a2 = neko.Lib.unserialize(a1);
		Assert.equals(Std.string(s), Std.string(a2));
	}

	public function testClassInstance(){
		var s = new TestObject();
		var a1 = neko.Lib.serialize(s);
		var a2 = neko.Lib.unserialize(a1);
		Assert.equals(Std.string(s), Std.string(a2));
	}
}