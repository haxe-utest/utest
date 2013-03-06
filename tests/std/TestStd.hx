package std;

import utest.Assert;
#if haxe3
import haxe.ds.StringMap in Hash;
import haxe.ds.IntMap in IntHash;
#end

class TestStd {
	public function new(){}

	public function testIs(){
		checkTypes(null,null);
		checkTypes(1,Int,Float);
		checkTypes(-1,Int,Float);
		checkTypes(1.2,Float);
		checkTypes(true,Bool);
		checkTypes(false,Bool);
		checkTypes([],Array);
		checkTypes("haXe",String);
		checkTypes(new List(),List);
		checkTypes(new Hash(),Hash);
		checkTypes(new ListExtended(),List,ListExtended);
		checkTypes(Foo,TestEnum);
		checkTypes(Bar(0),TestEnum);
	}

	function checkTypes( v : Dynamic, t : Dynamic, ?t2 : Dynamic, ?pos : haxe.PosInfos ){
		var a = [null,Int,Bool,Float,String,Array,Hash,List,ListExtended,TestEnum];
		for( c in a ){
			Assert.equals( c != null && (c == t || c == t2), Std.is(v,c), pos );
		}
	}

	public function testConv() {
		Assert.equals( "A", String.fromCharCode(65) );
		// TODO: check behavior for other platforms
		Assert.equals( null , ''.charCodeAt(0) );
		Assert.equals( 65 , 'A'.charCodeAt(0) );
		Assert.equals( 65 , Std.int(65) );
		Assert.equals( 65 , Std.int(65.456) );
		Assert.equals( 65 , Std.parseInt("65") );
		Assert.equals( 65 , Std.parseInt("65.3") );
		Assert.equals( 100, Std.parseInt("100x123") );
		#if js
		Assert.equals( null, Std.parseInt("x") );
		#else
		Assert.equals( 0, Std.parseInt("x") );
		#end
		Assert.equals( 65.0 , Std.parseFloat("65") );
		Assert.equals( 65.3 , Std.parseFloat("65.3") );
		#if !neko
		Assert.isTrue( Math.isNaN(Std.parseFloat("abc")) );
		#end
		Assert.equals( 255 , Std.parseInt("0xFF") );
	}

	public function testStdRandom() {
		var max = 100;
		var t = 0;
		for(i in 0...max) {
			var x = Std.random(max);
			t += x;
			Assert.isTrue(x >= 0 && x < max);
		}
		Assert.isTrue(t > 0); // it is not strictly correct but it is quite improbable that 100 extractions result all in zeros
	}

	public function testIsOnTypes() {
		Assert.isTrue(Std.is(ListExtended, Class));
		Assert.isTrue(Std.is(TestEnum, Enum));
		Assert.isTrue(Std.is(MyInterface, Class));
	}
}

private interface MyInterface {
}

private class ListExtended extends List<Dynamic> {
}

private enum TestEnum {
	Foo;
	Bar(c:Int);
}
