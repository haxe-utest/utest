package lang;

import utest.Assert;

class TestAnonymousObject {
	public function new() {}
	
	public function testCreateEmpty() {
		var o = {};
		Assert.notNull(o);
	}
	
	public function testCreateObject() {
		var o = { name : "haXe" };
		Assert.notNull(o);
	}
	
	public function testAccessField() {
		var o = { name : "haXe", lastname : "Neko" };
		Assert.equals("haXe", o.name);
		Assert.equals("Neko", o.lastname);
	}
	
	public function testFunctionField() {
		var o = { f : function(n){ return "Hello " + n + "!"; } };
		Assert.notNull(o);
		Assert.notNull(o.f);
		Assert.equals("Hello haXe!", o.f("haXe"));
	}
	
	public function testObjectScope() {
	    var o : Dynamic = null;
		o = { name : "haXe", f : function() { return "Hello " + o.name + "!"; }};
		Assert.equals("Hello haXe!", o.f());
	}
	
	public function testNestedObjects() {
	  var o = { name : "haXe", locations : [{ town : "Lisbon" }, { town : "Milan" }], current : { town : "Lisbon" }};
	  Assert.equals("haXe", o.name);
	  Assert.equals("Lisbon", o.current.town);
	  Assert.equals("Lisbon", o.locations[0].town);
	  Assert.equals("Milan", o.locations[1].town);
	}
	
	public function testLengthField() {
		var o1 = { length : 1 };
		Assert.equals(1, o1.length);
		var o2 : Dynamic = { length : 2 };
		Assert.equals(2, o2.length);
		var o3 : Dynamic = {};
		o3.length = 3;
		Assert.equals(3, o3.length);
		o3.length++;
		Assert.equals(4, o3.length);
		o3.length += 1;
		Assert.equals(5, o3.length);
	}
	
	public function testAccessingUnexistentField() {
		var o : Dynamic = {};
		Assert.isTrue(o != null);
#if flash9
		Assert.equals(null, o.name);
#elseif (flash || js)
		Assert.equals(untyped undefined, o.name);
#else
    Assert.isNull(o.name);
#end
	}
}