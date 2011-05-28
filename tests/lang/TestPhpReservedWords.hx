package lang;

import utest.Assert;

class TestPhpReservedWords {
	public function new() {}

	public function testUse() {
		var and = "haXe";
		Assert.equals("haXe", and);
	}

	public static function testStaticKeyword()
	{
		Assert.equals(2, callback(list,"a.b")().length);
	}

	public static function list( t :String )
	{
		return t.split('.');
	}
	
	public function testSuperKeyword()
	{
		var bar = new Bar();
		Assert.equals("A", bar.final());
	}

	public function testDeclare() {
		var and : String;
		var or : String;
		var xor : String;
		var __FILE__ : String;
		var exception : String;
		var __LINE__ : String;
		var array : String;
		var as : String;
		var const : String;
		var declare : String;
		var die : String;
		var echo : String;
		var elseif : String;
		var empty : String;
		var enddeclare : String;
		var endfor : String;
		var endforeach : String;
		var endif : String;
		var endswitch : String;
		var endwhile : String;
		var eval : String;
		var exit : String;
		var foreach : String;
		var global : String;
		var include : String;
		var include_once : String;
		var isset : String;
		var list : String;
		var print : String;
		var require : String;
		var require_once : String;
		var unset : String;
		var use : String;
		var __FUNCTION__ : String;
		var __CLASS__ : String;
		var __METHOD__ : String;
		var final : String;
		var php_user_filter : String;
		var protected : String;
		var abstract : String;
		var clone : String;
		Assert.isTrue(true);
	}
}

private class Foo
{
	public function new(){}
	public function final()
	{
		return "A";
	}
}

private class Bar extends Foo {
	override public function final()
	{
		return super.final();
	}
}