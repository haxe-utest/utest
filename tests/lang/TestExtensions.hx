package lang;

import utest.Assert;

class TestExtensions {
	public function new() {}
	
	public function testTypedefExt() {
		var td : ExtTDef = {
			v : "haXe",
			f : function() { return "test"; },
			v2 : "Neko",
			f2 : function() { return "test2"; }
		};
		Assert.equals("haXe", td.v);
		Assert.equals("test", td.f());
		Assert.equals("Neko", td.v2);
		Assert.equals("test2", td.f2());
	}
	
	public function testClassExt() {
		var o = new BaseClass();
		o.v = "haXe";
		o.v2 = "Neko";
		o.f2 = function() { return "test2"; };
		var to : ExtClass = cast o;
		
		Assert.equals("haXe", to.v);
		Assert.equals("test", to.f());
		Assert.equals("Neko", to.v2);
		Assert.equals("test2", to.f2());
	}
	
}

typedef BaseTDef = {
	v : String,
	f : Void -> String
}

typedef ExtTDef = {> BaseTDef,
	v2 : String,
	f2 : Void -> String
}

class BaseClass implements Dynamic {
	public function new() {}
	public var v : String;
	public function f() { return "test"; }
}

typedef ExtClass = {>BaseClass,
	v2 : String,
	f2 : Void -> String
}