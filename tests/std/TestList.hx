package std;

import utest.Assert;

class TestList {
	public function new(){}

	public function testAddLength(){
		var a = new List();
		Assert.isTrue( a.isEmpty() );
		a.add( 1 );
		Assert.equals( 1, a.length );
		Assert.isFalse( a.isEmpty() );
	}

	public function testAddFirst(){
		var a = new List();
		a.add( 1 );
		a.add( 2 );
		Assert.equals( 1, a.first() );
	}

	public function testAddLast(){
		var a = new List();
		a.add( 1 );
		a.push( 2 );
		Assert.equals( 1, a.last() );
	}

	public function testPushLength(){
		var a = new List();
		a.push( 1 );
		Assert.equals( 1, a.length );
	}

	public function testPushFirst(){
		var a = new List();
		a.push( 1 );
		Assert.equals( 1, a.first() );
	}

	public function testPushLast(){
		var a = new List();
		a.push( 1 );
		Assert.equals( 1, a.last() );
	}

	public function testTwoPush(){
		var a = new List();
		a.push( 1 );
		a.push( 2 );
		Assert.equals( "{2, 1}", a.toString() );
	}

	public function testPushAndAdd(){
		var a = new List();
		a.push( 1 );
		a.add( 2 );
		a.push( 3 );
		Assert.equals( "{3, 1, 2}", a.toString() );
	}

	public function testComplete1(){
		var a = new List();
		a.push( 1 );
		a.add( 2 );
		a.remove( 1 );
		a.add( 3 );
		Assert.equals( "{2, 3}", a.toString() );
	}

	public function testComplete2(){
		var a = new List();
		a.push( 1 );
		a.push( 2 );
		a.remove( 1 );
		a.add( 3 );
		a.push( 4 );
		a.remove( 2 );
		Assert.equals( "{4, 3}", a.toString() );
	}

	public function tesFor(){
		var sb = new StringBuf();
		var a = new List();
		a.push( 1 );
		a.push( 2 );
		a.remove( 1 );
		a.add( 3 );
		a.push( 4 );
		a.remove( 2 );
		for( e in a ){
			sb.add( e );
			sb.add( " " );
		}
		Assert.equals( "4 3 ", sb.toString() );
	}

	public function testForRemove(){
		var a = new List();
		a.add( 0 );
		a.add( 1 );
		a.add( 2 );
		a.add( 3 );

		var sb = new StringBuf();
		for( i in a ){
			if( i < 2 ) a.remove(i);

			sb.add( i );
		}
		Assert.equals("0123",sb.toString());
	}

	public function testClear(){
		var a = new List();
		a.add( 0 );
		a.add( 2 );
		a.add( 3 );
		Assert.equals( 3, a.length );
		Assert.equals( "0,2,3", a.join(",") );
		a.remove( 2 );
		Assert.equals( 2, a.length );
		Assert.equals( "0,3", a.join(",") );
		a.clear();
		Assert.equals( 0, a.length );
		Assert.equals( "", a.join(",") );
		a.remove( 0 );
		Assert.equals( 0, a.length );
		Assert.equals( "", a.join(",") );
		a.add( 5 );
		Assert.equals( 1, a.length );
		Assert.equals( "5", a.join(",") );
	}

	public function testFilter(){
		var a = new List();
		a.add( 5 );
		a.add( 15 );
		a.add( 2 );
		a.add( 0 );
		a.add( 55 );
		a.add( -5 );
		Assert.equals( "5,15,2,0,55,-5", a.join(",") );
		var b = a.filter(function(v){
			return v >= 5;
		});
		Assert.equals( "5,15,55", b.join(",") );
	}

	public function testMap(){
		var a = new List();
		a.add( 5 );
		a.add( 15 );
		a.add( 2 );
		a.add( 0 );
		a.add( 55 );
		a.add( -5 );
		var b = a.map(function(v){
			return v + 10;
		});
		Assert.equals( "15,25,12,10,65,5", b.join(",") );
	}

	public function testPop(){
		var a = new List();
		a.add(1);
		a.push(2);
		a.add(5);

		Assert.equals( 2, a.pop() );
		Assert.equals("1, 5",a.join(", "));
	}
	
	public function testSimpleRemove() {
		var list = new List<Dynamic>();
		list.add("haXe");
		list.add(true);
		list.remove(true);
		Assert.equals("haXe", list.first());
	}
}
