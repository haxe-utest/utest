/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

using issue.TestIssueML20100806.ArrayExtension;
using issue.TestIssueML20100806.MyIteratorExtension;

class TestIssueML20100806
{
	public function new(){}
	
	public function testIssue()
	{
		var x = [1, 2, 3, 4, 5, 6].map(function(x) { return x + 1; } );
		Assert.same([2, 3, 4, 5, 6, 7], x.array());

		var a = x.filter(function(x) { return x > 4; } );
		Assert.same([5, 6, 7], a.array());
		
		var b = x.filter(function(x) { return x < 4; } );
		Assert.same([2, 3], b.array());
		
		Assert.equals(18, a.sum());
		Assert.equals(5,  b.sum());
		
		Assert.equals(5, a.take(1).sum());
		Assert.equals(3, b.drop(1).sum());
	}
}

class Function1Extensions {
  public static function andThen<U, V, W>(f1: U -> V, f2: V -> W): U -> W {
    return function(u: U): W {
      return f2(f1(u));
    }
  }
}

typedef MyIterator<T> = {
  function hasNext(): Bool;
  function next():T;
}

typedef MyIteratorGen<T> = Void -> MyIterator<T>;

class FilterIterator<T>{
  var iter: MyIterator<T>;
  var cache: T;
  var p:T -> Bool;

  public function new(iter: MyIterator<T>, p: T -> Bool){
    this.iter = iter;
    this.p = p;
  }

  public function hasNext(){
    if (!iter.hasNext())
      return false;
    else {
      cache = iter.next();
      while (!p(cache)){
        if (!iter.hasNext())
          return false;
        cache = iter.next();
      }
      return true;
    }
  }

  public function next(){
    return cache;
  }
}

class ArrayIterator<T>{
  var start:Int;
  var end:Int;
  var a:Array<T>;

  public function new(a:Array<T>, ?start:Int, ?end:Int){
    this.a = a;
    this.start = start == null ? -1 : start - 1;
    this.end = end == null ? a.length -1 : end -1;
    if (this.start < -1) throw "ArrayIterator: start must be >= 0";
  }

  public function hasNext(){
    return (start++) < end;
  }

  public function next(){
    return a[start];
  }

}

class MyIteratorExtension {

  // == returning new generators / fusing functions ==

  public static function map<A,B>(gen:MyIteratorGen<A>, f:A -> B):MyIteratorGen<B>{
    return function() {
      var iter = gen();
      return {
        hasNext : iter.hasNext,
        next: //  iter.next.andThen(f)
          function(){ return f(iter.next()); }
      }
    }
  }

  public static function filter<A>(gen:MyIteratorGen<A>, p:A -> Bool):MyIteratorGen<A>{
    return function(){
      var iter = gen();
      return new FilterIterator(iter,p);
    }
  }

  public static function foldl<T,Z>(gen:MyIteratorGen<T>, z:Z, f:Z -> T -> Z):Z{
    var acc = z;
    var iter = gen();
    while (iter.hasNext()){
      acc = f(acc, iter.next());
    }
    return acc;
  }


  public static function drop<T>(gen:MyIteratorGen<T>, x:Int):MyIteratorGen<T>{
    return function(){
      var iter = gen();
      for (i in (0 ... x)) if (!iter.hasNext()) break;
      return iter;
    }
  }


  public static function take<T>(gen:MyIteratorGen<T>, x:Int):MyIteratorGen<T>{
    return function(){
      var iter = gen();
      var counter = 0;
      return {
        hasNext: function(){
          return counter++ < x && iter.hasNext();
        },
        next: iter.next
      }
    }
  }

  // generating the iterators returning results

  // to array / to list etc
  public static function array<T>(gen:MyIteratorGen<T>):Array<T>{
    // this can be optimized
    return MyIteratorExtension.foldl(gen, new Array(), function(a, t){
      a.push(t);
      return a;
    });
  }

  public static function sum(gen:MyIteratorGen<Int>):Int{
    // this can be optimized
    return MyIteratorExtension.foldl(gen, 0, function(a, t){
      return a + t;
    });
  }
}

class ArrayExtension {

  public static function map<A,B>(a:Array<A>, f:A -> B):MyIteratorGen<B>{
    return MyIteratorExtension.map( function(){ return new ArrayIterator(a); }, f);
  }

}
