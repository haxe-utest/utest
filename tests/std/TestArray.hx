package std;

import utest.Assert;

class TestArray {
	public function new(){}

	public function testLength(){
		var a = new Array();
		a[0] = 1;
		a[1] = 2;
		Assert.equals( 2, a.length );
	}

	public function testLength2(){
		var a = new Array<Null<Int>>();
		a[0] = 1;
		a[50] = 2;
		Assert.equals( 51, a.length );
		Assert.equals( null, a[1] );
	}

	public function testReverse(){
		var a = new Array();
		for( i in 0...20 ){
			a[i] = i;
		}
		a.reverse();
		Assert.equals( 20, a.length );
		for( i in 0...20 ){
			Assert.equals( 19-i, a[i] );
		}
	}

	public function testReverse2() {
		var arr = ['a', 'c', 'b'];
		arr.reverse();
		var expected = ['b', 'c', 'a'];
		for(i in 0...arr.length)
			Assert.equals(expected[i], arr[i]);
	}

	public function testPushUnshift(){
		var a = new Array();
		a.unshift(1);
		Assert.equals("1",a.join(", "));
		a.push(2);
		Assert.equals("1, 2",a.join(", "));
		a.unshift(3);
		Assert.equals("3, 1, 2",a.join(", "));
	}

	public function testRemove(){
		var a = new Array();
		a.unshift(1);
		a.push(2);
		a.remove(1);
		a.push(3);
		Assert.equals("2, 3",a.join(", "));
	}

	public function testPop(){
		var a = new Array();
		a.unshift(1);
		a.push(2);
		a.unshift(3);
		Assert.equals( 2, a.pop() );
		Assert.equals("3, 1",a.join(", "));
	}

	public function testShift(){
		var a = new Array();
		a.unshift(1);
		a.push(2);
		a.unshift(3);
		Assert.equals( 3, a.shift());
		Assert.equals("1, 2",a.join(", "));
	}

	public function testSlice(){
		var a = new Array();
		for( i in 0...20 ){
			a[i] = i;
		}
		Assert.equals( "0, 1", a.slice(0,2).join(", ") );
		Assert.equals( "0, 1", a.slice(0,-18).join(", ") );
		Assert.equals( "18, 19", a.slice(-2,20).join(", ") );
		Assert.equals( "16, 17", a.slice(16,18).join(", ") );
		Assert.equals( "16, 17", a.slice(-4,-2).join(", ") );

		Assert.equals( "18, 19", a.slice(18).join(", ") );

		a = new Array();
		a[0] = 0;
		a[1] = 1;
		Assert.equals( "0, 1", a.slice(-4,2).join(", ") );
		Assert.equals( "", a.slice(0,-4).join(", ") );
		Assert.equals( "1", a.slice(1,2).join(", ") );
		Assert.equals( "1", a.slice(1,10).join(", ") );
		Assert.equals( "", a.slice(100,10).join(", ") );
	}

	public function testSort(){
		var a = new Array();
		a[0] = 65;
		a[1] = 35;
		a[2] = 75;
		a[3] = 75;

		a.sort(function(i,j){
			if( i > j ) return 1;
			if( i == j ) return 0;
			return -1;
		});
		Assert.equals( "35, 65, 75, 75", a.join(", ") );
	}

	public function testSplice(){
		var a = new Array();
		for( i in 0...5 ){
			a[i] = i;
		}
		a.splice(0, 2);
		Assert.equals( "2, 3, 4", a.join(", ") );
		var a = [];
		a.splice(0,0);
		a.splice(10,10);
		a.splice(-10,10);
		a.splice(-10,-10);
		Assert.equals( "", a.join(", ") );
	}

	public function testSplice2(){
		var a = new Array();
		for( i in 0...5 ){
			a[i] = i;
		}
		a.splice(0, -2);
		Assert.equals( "0, 1, 2, 3, 4", a.join(", ") );
	}

	public function testSplice3(){
		var a = new Array();
		for( i in 0...5 ){
			a[i] = i;
		}
		a.splice(-2, 2);
		Assert.equals( "0, 1, 2", a.join(", ") );
	}

	public function testSplice4(){
		var a = new Array();
		for( i in 0...5 ){
			a[i] = i;
		}
		a.splice(-4, -2);
		Assert.equals( "0, 1, 2, 3, 4", a.join(", ") );
	}

	public function testSplice5(){
		var a = new Array();
		for( i in 0...5 ){
			a[i] = i;
		}
		a.splice(-8, 2);
		Assert.equals( "2, 3, 4", a.join(", ") );
	}

	public function testSplice6(){
		var a = new Array();
		for( i in 0...5 ){
			a[i] = i;
		}
		a.splice(2, -8);
		Assert.equals( "0, 1, 2, 3, 4", a.join(", ") );
	}

	public function testInsert(){
		var a = new Array();
		for( i in 0...5 ){
			a[i] = i;
		}
		Assert.equals( 5, a.length );
		a.insert( 2, 10 );
		Assert.equals( "0, 1, 10, 2, 3, 4", a.join(", ") );
		Assert.equals( 6, a.length );

		a.insert( 15, 20 );
		Assert.equals( "0, 1, 10, 2, 3, 4, 20", a.join(", ") );
		Assert.equals( 7, a.length );

		a.insert( -3, 30 );
		Assert.equals( "0, 1, 10, 2, 30, 3, 4, 20", a.join(", ") );

		a.insert( -10, 40 );
		Assert.equals( "40, 0, 1, 10, 2, 30, 3, 4, 20", a.join(", ") );
	}

	public function testFor(){
		var a = new Array<Null<Int>>();
		a[0] = 0;
		a[5] = 5;
		a[8] = 8;
		a[3] = 3;
		var sb = new StringBuf();
		for( i in a ){
			if((i == untyped "undefined") || i == null)
				sb.add("null");
			else
				sb.add(i);
		}
		Assert.equals( "0nullnull3null5nullnull8", sb.toString() );
	}

	public function testForRemove(){
		var a = new Array<Null<Int>>();
		a[0] = 0;
		a[1] = 1;
		a[2] = 2;
		a[3] = 3;
		a[4] = 4;
		a[7] = 7;

		var sb = new StringBuf();
		for( i in a ) {
			if( i == null )
				sb.add("null");
			else {
				if( i < 3 ) a.remove(i);
				sb.add( i );
			}
		}
		Assert.equals("024nullnull7",sb.toString());
	}

	public function testNeko(){
		var a = new Array<Int>();

		for( i in 0...5 ){
			a.push( i );
		}

		Assert.equals( "0,1,2,3,4", a[0]+","+a[1]+","+a[2]+","+a[3]+","+a[4] );
	}

	public function testConcat(){
		var a = [0,1,2,3,4];
		var b = [8,9,10];
		var r = a.concat(b);
		Assert.equals( r.join(","), "0,1,2,3,4,8,9,10" );
	}

	public function testCopy(){
		var a = [{a: 1}];
		var b = a.copy();
		Assert.equals( 1, a[0].a );
		Assert.equals( 1, b[0].a );
		b[0].a = 2;
		Assert.equals( 2, a[0].a );
		a = [{a: 5}];
		Assert.equals( 5, a[0].a );
		Assert.equals( 2, b[0].a );

	}
}