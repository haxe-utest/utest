package std;

import utest.Assert;
#if haxe3
import haxe.ds.StringMap in Hash;
import haxe.ds.IntMap in IntHash;
#end

class TestHash {
	public function new(){}

	public function testSetGet(){
		var a = new Hash();
		a.set("one",1);
		a.set("two",2);
		Assert.equals( 1, a.get("one") );
		Assert.equals( 2, a.get("two") );
		Assert.equals( null, a.get("three") );
	}

	public function testRemoveGet(){
		var a = new Hash();
		a.set("one",1);
		a.set("two",2);
		a.remove("one");
		Assert.equals( null, a.get("one") );
	}

	public function testKeys(){
		var a = new Hash();
		a.set("one",1);
		a.set("two",2);
		var c = 0;
		for( e in a.keys() ){
			if( e == "one" ) c++;
			else if( e == "two" ) c++;
			else throw "Bad key";
		}
		Assert.equals(2,c);
	}

	public function testIter(){
		var a = new Hash();
		a.set("one",1);
		a.set("two",2);
		a.set("three",3);
		a.remove("two");
		var i = 0;
		for( t in a ){
			i++;
		}
		Assert.equals( 2, i );
		a.remove("nothing");
	}

	public function testExists(){
		var a = new Hash();
		a.set("one",1);
		Assert.isTrue( a.exists("one") );
		Assert.isFalse( a.exists("two") );
		a.set("two",2);
		a.remove("one");
		Assert.isFalse( a.exists("one") );
		Assert.isTrue( a.exists("two") );
	}

	public function testPrototype(){
		var a = new Hash();
		a.set("one",1);
		a.set("two",2);
		Assert.isFalse( a.exists("prototype") );
		Assert.equals( null, a.get("prototype") );
		a.set("prototype",5);
		Assert.isTrue( a.exists("prototype") );
		Assert.equals( 5, a.get("prototype") );
		a.remove("prototype");
		Assert.isFalse( a.exists("prototype") );
		Assert.equals( null, a.get("prototype") );
	}

	#if neko
	// Fail on Flash, Opera, ... ?
	public function testHasOwnProperty(){
		var a = new Hash();
		a.set("one",1);
		a.set("two",2);
		Assert.isFalse( a.exists("hasOwnProperty") );
		Assert.equals( null, a.get("hasOwnProperty") );
		a.set("hasOwnProperty",5);
		Assert.isTrue( a.exists("hasOwnProperty") );
		Assert.equals( 5, a.get("hasOwnProperty") );
		a.remove("hasOwnProperty");
		Assert.isFalse( a.exists("hasOwnProperty") );
		Assert.equals( null, a.get("hasOwnProperty") );
	}
	#end

	#if (neko || flash9)
	// fail on Safari 1.3.2, flash<9, ... ?
	public function testProto(){
		var a = new Hash();
		a.set("one",1);
		a.set("two",2);
		Assert.isFalse( a.exists("__proto__") );
		Assert.equals( null, a.get("__proto__") );
		a.set("__proto__",6);
		Assert.isTrue( a.exists("__proto__") );
		Assert.equals( 6, a.get("__proto__") );
		a.remove("__proto__");
		Assert.isFalse( a.exists("__proto__") );
		Assert.equals( null, a.get("__proto__") );
	}
	#end

	#if php
	public function testFromAssociativeArray() {
		var h : Hash<String> = php.Lib.hashOfAssociativeArray(untyped __php__("array('name' => 'haXe', 'lastname' => 'Neko')"));
		Assert.equals("haXe", h.get("name"));
		Assert.equals("Neko", h.get("lastname"));
	}
	#end

	public function testForRemove(){
		var a = new Hash<Null<Int>>();
		a.set( "zero", 0 );
		a.set( "one", 1 );
		a.set( "two", 2 );
		a.set( "three", 3 );

		var sb = new StringBuf();
		for( i in a ){
			if( i == 1 ) a.remove("one");

			if( i == null ) throw "Null value in hash";
			sb.add( i );
		}
		Assert.equals(4,sb.toString().length);
	}
}