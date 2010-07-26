package platform.php;

import utest.Assert;
import utest.Runner;
import platform.php.utils.ExternClass;

class TestMiscPhp {
	public function new();

	public function testRethrow() {
		try {
			throw 666;
		} catch(a : String) {
			// do nothing
		} catch(x : Dynamic) {
			Assert.raises(function() {
				php.Lib.rethrow(x);
			}, Int);
		}
	}

	public function testFixtureResultEmpty() {
		var me = this;
		var c = function() {
			var old = me.a;
			me.a = function() {
			  return old()+"b";
			};
			Assert.equals("ab", me.a());
		}
		c();
	}
	dynamic function a() { return "a"; }
	
	public function testDynamicAdd() {
		var o : Dynamic = { a : 1, b : 2, c : "a", d : "b" };
		Assert.equals(3, o.a + o.b);
		Assert.equals("1a", o.a + o.c);
		Assert.equals("a2", o.c + o.b);
		Assert.equals("ab", o.c + o.d);
		
		o.a += o.b;
		Assert.equals(5, o.a += o.b);
		o.c += o.d;
		Assert.equals("abb", o.c += o.d);
	}

	public function testExternClassInit() {
		var o = new ExternClass();
		Assert.equals("haxe", o.x);
		var o = new platform.php.utils.ExternClassNoInit();
		Assert.equals("php", o.x);
	}

	public function testIfFor1() {
		var t = ['1','2','3'];
		var b = '';
		if( true ) for( x in t ) { b+=x; } else for( x in t ) { b+="f"+x; }
		Assert.equals('123', b);
		b = '';
		if( false ) for( x in t ) { b+=x; } else for( x in t ) { b+="f"+x; }
		Assert.equals('f1f2f3', b);
	}

	public function testIfFor2() {
		var t = ['1','2','3'];
		var b = '';
		if( true ) for( x in t ) b+=x; else for( x in t ) b+="f"+x;
		Assert.equals('123', b);
		b = '';
		if( false ) for( x in t ) b+=x; else for( x in t ) b+="f"+x;
		Assert.equals('f1f2f3', b);
	}

	public function testIfFor3() {
		var t = new List();
		t.add('1');
		t.add('2');
		t.add('3');
		var b = '';
		if( true ) for( x in t ) { b+=x; } else for( x in t ) { b+="f"+x; }
		Assert.equals('123', b);
		b = '';
		if( false ) for( x in t ) { b+=x; } else for( x in t ) { b+="f"+x; }
		Assert.equals('f1f2f3', b);
	}

	public function testIfFor4() {
		var t = new List();
		t.add('1');
		t.add('2');
		t.add('3');
		var b = '';
		if( true ) for( x in t ) b+=x; else for( x in t ) b+="f"+x;
		Assert.equals('123', b);
		b = '';
		if( false ) for( x in t ) b+=x; else for( x in t ) b+="f"+x;
		Assert.equals('f1f2f3', b);
	}
	
	public function testIntSum()
	{
		var a:Int = 1;
		var b:Int = 4;
		var c:Int = a + b;
		Assert.equals(5, c);
		c = a - b;
		Assert.equals(-3, c);
	}
}
