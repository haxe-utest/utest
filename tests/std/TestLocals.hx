package std;

import utest.Assert;

class TestLocals
{
	public function testIncrDecr() {
		var i = 5;
		Assert.equals( i++, 5 );
		Assert.equals( i, 6 );
		Assert.equals( i--, 6 );
		Assert.equals( i, 5 );
		Assert.equals( ++i, 6 );
		Assert.equals( i, 6 );
		Assert.equals( --i, 5 );
		Assert.equals( i, 5 );
	}

	public function testScope() {
		var x = 0;
		Assert.equals(x,0);
		// simple scope
		{
			var x = "hello";
			Assert.equals(x,"hello");
			{
				var x = "";
				Assert.equals(x,"");
			}
			Assert.equals(x,"hello");
		}
		Assert.equals(x,0);
		// if
		var flag = true;
		if( flag ) {
			var x = "hello";
			Assert.equals(x,"hello");
		}
		Assert.equals(x,0);
		// for
		for( x in ["hello"] )
			Assert.equals(x,"hello");
		Assert.equals(x,0);
		// switch
		switch( MyEnum.D(MyEnum.A) ) {
		case D(x):
			Assert.equals(x,MyEnum.A);
		default:
			Assert.warn("???");
		}
		Assert.equals(x,0);
		// try/catch
		try {
			throw "hello";
		} catch( x : Dynamic ) {
			Assert.equals(x,"hello");
		}
		Assert.equals(x,0);
	}

	public function testCapture() {
		// read
		var funs = new Array();
		for( i in 0...5 )
			funs.push(function() return i);
		for( k in 0...5 )
			Assert.equals(funs[k](),k);

		// write
		funs = new Array();
		var sum = 0;
		for( i in 0...5 ) {
			var k = 0;
			funs.push(function() { k++; sum++; return k; });
		}
		for( i in 0...5 )
			Assert.equals(funs[i](),1);
		Assert.equals(sum,5);

		// multiple
		var accesses = new Array();
		var sum = 0;
		for( i in 0...5 ) {
			var j = i;
			accesses.push({
				inc : function() { sum += j; j++; return j; },
				dec : function() { j--; sum -= j; return j; },
			});
		}
		for( i in 0...5 ) {
			var a = accesses[i];
			Assert.equals( a.inc(), i + 1 );
			Assert.equals( sum, i );
			Assert.equals( a.dec(), i );
			Assert.equals( sum, 0 );
		}
	}

	public function testSubCapture() {
		var funs = new Array();
		for( i in 0...5 )
			funs.push(function() {
				var tmp = new Array();
				for( j in 0...5 )
					tmp.push(function() return i + j);
				var sum = 0;
				for( j in 0...5 )
					sum += tmp[j]();
				return sum;
			});
		for( i in 0...5 )
			Assert.equals( funs[i](), i * 5 + 10 );
	}

	public function testParallelCapture() {
		var funs = new Array();
		for( i in 0...5 ) {
			if( true ) {
				var j = i;
				funs.push(function(k) return j);
			}
			if( true )
				funs.push(function(j) return j);
		}
		for( k in 0...5 ) {
			Assert.equals( k, funs[k*2](0) );
			Assert.equals( k, funs[k*2+1](k) );
		}
	}

	public function testPossibleBug() {
		var funs = new Array();
		for( i in 0...5 )
			funs.push(function(i) return i);
		for( k in 0...5 )
			Assert.equals( 55, funs[k](55) );
	}
	
	public function new(){}
}