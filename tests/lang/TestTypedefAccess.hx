package lang;

import utest.Assert;
import lang.util.A;

typedef MyType = {
	msg : Void -> String
}

typedef Person = {
    name : String,
	age : Int
}

class TestTypedefAccess {
	public function new() {}
	
	public function testSimpleTypedef() {
		var o : Person = { name : "haXe", age : 2 };
		Assert.equals("haXe", o.name);
		Assert.equals(2, o.age);
	}
	
	public function testTypedefWithClass() {
		var o : MyType = cast new A();
		Assert.equals("test", o.msg());
		var o2 : MyType = {
			msg : function() { return "test2"; }
		}
		Assert.equals("test2", o2.msg());
	}
}