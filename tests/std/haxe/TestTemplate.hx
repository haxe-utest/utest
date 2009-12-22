package std.haxe;

import utest.Assert;

class TestTemplate {
	public function new(){}

	public function testSimple(){
		var t = new haxe.Template("Hello ::name::!");
		Assert.equals("Hello haXe!", t.execute({ name : "haXe" }));
	}

	public function testCalculation() {
		var t = new haxe.Template("Seconds in a day ::(24*(60*60))::");
		Assert.equals("Seconds in a day 86400", t.execute({}));
	}

	public function testNestedObjects() {
		var t = new haxe.Template("::name::'s father is ::father.name::");
		Assert.equals("haXe's father is Nicolas", t.execute({ name : "haXe", father : { name : "Nicolas"}}));
	}

	public function testIf() {
		var t = new haxe.Template("::if (condition)::true::elseif (other)::other::else::false::end::");
		Assert.equals("true",  t.execute({ condition : true , other : true}));
		Assert.equals("other", t.execute({ condition : false, other : true}));
		Assert.equals("false", t.execute({ condition : false, other : false}));
	}

	public function testMacro() {
		var t = new haxe.Template("$$sayHello(::name::)");
		var out = t.execute(
			{ name : "haXe"},
			{ sayHello : function(resolve : String->Dynamic, name : String) { return "Hello "+name+"!"; }});
		Assert.equals("Hello haXe!", out);
	}

	public function testLoop() {
		var t = new haxe.Template("::foreach numbers::::__current__:: ::end::");
		Assert.equals("1 2 3 ", t.execute({ numbers : 1...4 }));
	}
}
