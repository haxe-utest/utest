package utest;

import utest.Assert;
import utest.Assertation;

@:keep
class TestAssert {
  public function new(){}

  var resultsbypass : List<Assertation>;
  var results : List<Assertation>;
  public function bypass() {
    resultsbypass = Assert.results;
    Assert.results = new List();
  }

  public function restore() {
    results = Assert.results;
    Assert.results = resultsbypass;
  }

  public function testBooleans() {
    bypass();
    Assert.isTrue(true);
    Assert.isTrue(false);
    Assert.isFalse(true);
    Assert.isFalse(false);
    restore();
    expect(2, 2);
  }

  public function testNullity() {
    bypass();
    Assert.isNull(null);
    Assert.isNull(0);
    Assert.isNull(0.0);
    Assert.isNull(0.1);
    Assert.isNull(1);
    Assert.isNull("");
    Assert.isNull("a");
    Assert.isNull(Math.NaN);
    Assert.isNull(Math.POSITIVE_INFINITY);
    Assert.isNull(true);
    Assert.isNull(false);
    restore();
    expect(1, 10);
  }

  public function testNoNullity() {
    bypass();
    Assert.notNull(null);
    Assert.notNull(0);
    Assert.notNull(0.0);
    Assert.notNull(0.1);
    Assert.notNull(1);
    Assert.notNull("");
    Assert.notNull("a");
    Assert.notNull(Math.NaN);
    Assert.notNull(Math.POSITIVE_INFINITY);
    Assert.notNull(true);
    Assert.notNull(false);
    restore();
    expect(10, 1);
  }

  public function testRaises() {
    bypass();
    var errors : Array<Dynamic> = ["e",    1,   0.1,   new TestAssert(), {},      [1]];
    var types  : Array<Dynamic> = [String, Int, Float, TestAssert,       Dynamic, Array];
    var i = 0;
    var expectedsuccess = 12;
    for(error in errors)
      for(type in types) {
        i++;
        Assert.raises(function() throw error, type);
      }
    restore();
    expect(expectedsuccess, i-expectedsuccess);
  }

  public function testIs() {
    bypass();
    var values : Array<Dynamic> = ["e",    1,   0.1,   new TestAssert(), {},      [1]];
    var types  : Array<Dynamic> = [String, Int, Float, TestAssert,       Dynamic, Array];
    var i = 0;
    var expectedsuccess = 12;
    for(value in values)
      for(type in types) {
        i++;
        Assert.isOfType(value, type);
      }
    restore();
    expect(expectedsuccess, i-expectedsuccess);
  }

  public function testSamePrimitive() {
    bypass();
    Assert.same(null, 1);
    Assert.same(1, 1);
    Assert.same(1, "1");
    Assert.same("a", "a");
    Assert.same(null, "");
    Assert.same(new Date(2000, 0, 1, 0, 0, 0), null);
    Assert.same([1 => "a", 2 => "b"], [1 => "a", 2 => "b"]);
    Assert.same(["a" => 1], ["a" => 1]);
    Assert.same(["a" => 1], [1 => 1]);
    Assert.same([1 => "a"], [1 => "a", 2 => "b"]);
//    TODO doesn't work anymore
//    Assert.same(new Date(2000, 0, 1, 0, 0, 0), new Date(2000, 0, 1, 0, 0, 0));

    restore();
    expect(5, 6);
  }

  public function testSameType() {
    bypass();
    Assert.same(null, {});
    Assert.same(null, null);
    Assert.same({}, null);
    Assert.same({}, 1);
    Assert.same({}, []);
    Assert.same(null, None);
    Assert.same(None, null);

    restore();
    expect(1, 6);
  }

  public function testSameArray() {
    bypass();
    Assert.same([], []);
    Assert.same([1], ["1"]);
    Assert.same([1,2,3], [1,2,3]);
    Assert.same([1,2,3], [1,2]);
    Assert.same([1,2],   [1,2,3]);
    Assert.same([1,[1,2]], [1,[1,2]]);
    Assert.same([1,[1,2]], [1,[]], false);
    Assert.same([1,[1,2]], [1,[]], true);

    restore();
    expect(4, 4);
  }

  public function testSameArray_message() {
    bypass();
    Assert.same([{field:{sub:1}}], [{field:{sub:2}}]);
    restore();

    Assert.equals(1, results.length);
    var expectedMessage = 'expected array element at [0] to have 1 but it is 2 for field array[0].field.sub';
    switch(results.first()) {
      case Failure(msg, _): Assert.equals(expectedMessage, msg);
      case _: Assert.fail();
    }
  }

  public function testSameObject() {
    bypass();
    Assert.same({}, {});
    Assert.same({a:1}, {a:"1"});
    Assert.same({a:1,b:"c"}, {a:1,b:"c"});
    Assert.same({a:1,b:"c"}, {a:1,c:"c"});
    Assert.same({a:1,b:"c"}, {a:1});
    Assert.same({a:1,b:{a:1,c:"c"}}, {a:1,b:{a:1,c:"c"}});
    Assert.same({a:1,b:{a:1,c:"c"}}, {a:1,b:{}}, false);
    Assert.same({a:1,b:{a:1,c:"c"}}, {a:1,b:{}}, true);

    restore();
    expect(4, 4);
  }

  public var value : String;
  public var sub : TestAssert;
  public function testSameInstance() {
    var c1 = new TestAssert();
    c1.value = "a";
    var c2 = new TestAssert();
    c2.value = "a";
    var c3 = new TestAssert();

    var r1 = new TestAssert();
    r1.sub = c1;
    var r2 = new TestAssert();
    r2.sub = c2;
    var r3 = new TestAssert();
    r3.sub = c3;


    bypass();
    Assert.same(c1, c1);
    Assert.same(c1, c2);
    Assert.same(c1, c3);

    Assert.same(r1, r2);
    Assert.same(r1, r3, false);
    Assert.same(r1, r3, true);

    restore();
    expect(4, 2);
  }

  public function testSameIterable() {
    var list1 = new List<Dynamic>();
    list1.add("a");
    list1.add(1);
    var s1 = new List();
    s1.add(2);
    list1.add(s1);
    var list2 = new List<Dynamic>();
    list2.add("a");
    list2.add(1);
    list2.add(s1);
    var list3 = new List<Dynamic>();
    list3.add("a");
    list3.add(1);
    list3.add(new List());

    bypass();
    Assert.same(list1, list2);
    Assert.same(list1, list3, false);
    Assert.same(list1, list3, true);

    Assert.same(0...3, 0...3);
    Assert.same(0...3, 0...4);

    restore();
    expect(3, 2);
  }

  public function testSameIterable_message() {
    var list1 = new List();
    list1.add({field:{sub:1}});
    var list2 = new List();
    list2.add({field:{sub:2}});

    bypass();
    Assert.same(list1, list2);
    restore();

    Assert.equals(1, results.length);
    var expectedMessage = 'expected 1 but it is 2 for field iterable[0].field.sub';
    switch(results.first()) {
      case Failure(msg, _): Assert.equals(expectedMessage, msg);
      case _: Assert.fail();
    }
  }
/*
  TODO Needs fixing
  public function testSameMap() {
    var h1 = new haxe.ds.StringMap();
    h1.set('a', 'b');
    h1.set('c', 'd');
    var h2 = new haxe.ds.StringMap();
    h2.set('a', 'b');
    h2.set('c', 'd');
    var h3 = new haxe.ds.StringMap();
    var h4 = new haxe.ds.StringMap();
    h4.set('c', 'd');

    var i1 = new haxe.ds.IntMap();
    i1.set(2, 'b');
    var i2 = new haxe.ds.IntMap();
    i2.set(2, 'b');

    bypass();

    Assert.same(h1, h2);
    Assert.same(h1, h3);
    Assert.same(h1, h4);
    Assert.same(i1, i2);

    restore();
    expect(2, 2);
  }
*/
  public function testSameEnums() {
    bypass();

    Assert.same(None, None);
    Assert.same(Some("a"), Some("a"));
    Assert.same(Some("a"), Some("b"), true);
    Assert.same(Some("a"), Some("b"), false);
    Assert.same(Some("a"), None);
    Assert.same(Rec(Rec(Some("a"))), Rec(Rec(Some("a"))));
    Assert.same(Rec(Rec(Some("a"))), Rec(None), true);
// TODO: something goes wrong here with flash6, haXe/Flash6 bug?
#if !flash6
    Assert.same(Rec(Rec(Some("a"))), Rec(Rec(None)), false);
#end

    restore();
#if flash6
    expect(3, 4);
#else
    expect(4, 4);
#end
  }

  public function testEquals() {
    bypass();
    var values    : Array<Dynamic> = ["e", 1, 0.1, {}];
    var expecteds : Array<Dynamic> = ["e", 1, 0.1, {}];
    var i = 0;
    var expectedsuccess = 3;
    for(expected in expecteds)
      for(value in values) {
        i++;
        Assert.equals(expected, value);
      }
    restore();
    expect(expectedsuccess, i-expectedsuccess);
  }

  public function testFloatEquals() {
    bypass();
    var values    : Array<Float> = [1, 0.1, 0.000000000000000000000000000011, Math.NaN, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.PI, 0.11];
    var expecteds : Array<Float> = [1, 0.1, 0.000000000000000000000000000012, Math.NaN, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.PI, 0.12];
    var i = 0;
    var expectedsuccess = 7;
    for(expected in expecteds)
      for(value in values) {
        i++;
        Assert.floatEquals(expected, value);
      }
    restore();
    expect(expectedsuccess, i-expectedsuccess);
  }

  public function testPass() {
    bypass();
    Assert.pass();
    restore();
    expect(1, 0);
  }

  public function testFail() {
    bypass();
    Assert.fail();
    restore();
    expect(0, 1);
  }

  public function testWarn() {
    bypass();
    Assert.warn("");
    restore();
    expect(0, 0, 1);
  }

  #if (haxe_ver >= "3.4.0")
  public function testCreateAsync() {
    var assert = Assert.createAsync(function() Assert.pass(), 1000);
    haxe.Timer.delay(assert, 50);
  }
  #end

  public function expect(esuccesses : Int, efailures : Int, eothers = 0) {
    var successes = 0;
    var failures  = 0;
    var others    = 0;
    for(result in results) {
      switch(result) {
        case Success(_):
          successes++;
        case Failure(_,_):
          failures++;
        default:
          others++;
      }
    }
    Assert.equals(eothers, others, "expected "+eothers+" other results but were "+others);
// TODO doesn't work anymore
//    Assert.equals(esuccesses, successes, "expected "+esuccesses+" successes but were "+successes);
    Assert.equals(efailures, failures, "expected "+efailures+" failures but were "+failures);
  }
}

private enum Sample {
  None;
  Some(s : String);
  Rec(s : Sample);
}
