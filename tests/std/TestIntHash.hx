package std;

import utest.Assert;

class TestIntHash {
	public function new(){}

	public function testSetGet(){
		var a = new IntHash();
		a.set(0,1);
		a.set(5,2);
		Assert.equals( 1, a.get(0) );
		Assert.equals( 2, a.get(5) );
		Assert.equals( null, a.get(3) );
	}

	public function testRemoveGet(){
		var a = new IntHash();
		a.set(1,1);
		a.set(5,2);
		a.remove(1);
		Assert.equals( null, a.get(1) );
	}

	public function testKeys(){
		var a = new IntHash();
		a.set(1,0);
		a.set(22,5);
		var c = 0;
		for( e in a.keys() ){
			if( e == 1 ) c++;
			else if( e == 22 ) c++;
			else throw "Bad key";
		}
		Assert.equals(2,c);
	}

	public function testIter(){
		var a = new IntHash();
		a.set(1,1);
		a.set(4,2);
		a.set(5,3);
		a.remove(4);
		var i = 0;
		for( t in a ){
			i++;
		}
		Assert.equals( 2, i );
		a.remove(8);
	}

	public function testExists(){
		var a = new IntHash();
		a.set(5,1);
		Assert.isFalse( a.exists(10) );
		a.set(10,2);
		a.remove(5);
		Assert.isFalse( a.exists(5) );
		Assert.isTrue( a.exists(10) );
	}

	public function testForRemove(){
		var a = new IntHash<Null<Int>>();
		a.set( 1, 0 );
		a.set( 5, 1 );
		a.set( 8, 2 );
		a.set( 11, 3 );

		var sb = new StringBuf();
		for( i in a ){
			if( i == 1 ) a.remove(5);

			if( i == null ) throw "Null value in hash";
			sb.add( i );
		}
		Assert.equals(4,sb.toString().length);
	}
}
