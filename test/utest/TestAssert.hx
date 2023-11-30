package utest;

import haxe.PosInfos;
import haxe.Exception;
import utest.Assert;
import utest.Assert.*;
import utest.Assertation;

@:keep
class TestAssert extends Test {

  function _bypass(fn:()->Void):List<Assertation> {
    var currentResults = Assert.results;
    Assert.results = new List();
    fn();
    var results = Assert.results;
    Assert.results = currentResults;
    return results;
  }

  function success(assertion:()->Bool, ?msg:String, ?pos:PosInfos) {
    var outcome = false;
    _bypass(() -> outcome = assertion());
    Assert.isTrue(outcome, msg, pos);
  }

  function failure(assertion:()->Bool, ?msg:String, ?pos:PosInfos) {
    var outcome = true;
    _bypass(() -> outcome = assertion());
    Assert.isFalse(outcome, msg, pos);
  }

  function warning(expectedMessage:String, assertion:()->Void, ?pos:PosInfos) {
    var results = Lambda.array(_bypass(assertion));
    if(results.length != 1) {
      Assert.fail('warnings expects a single warning assertion', pos);
    } else {
      switch results[0] {
        case Warning(msg): equals(expectedMessage, msg, pos);
        case _: throw new Exception('Unexpected behavior');
      }
    }
  }

  function failMessages(expectedMessage:String, assertion:()->Bool, ?pos:PosInfos) {
    var results = Lambda.array(_bypass(assertion));
    if(results.length != 1) {
      Assert.fail('failMessage expects a single failing assertion', pos);
    } else {
      switch results[0] {
        case Failure(msg, pos): equals(expectedMessage, msg, pos);
        case _: throw new Exception('Unexpected behavior');
      }
    }
  }

  public function testBooleans() {
    success(() -> isTrue(true));
    failure(() -> isTrue(false));
    failure(() -> isFalse(true));
    success(() -> isFalse(false));
  }

  public function testNullity() {
    success(() -> isNull(null));
    failure(() -> isNull(0));
    failure(() -> isNull(0.0));
    failure(() -> isNull(0.1));
    failure(() -> isNull(1));
    failure(() -> isNull(""));
    failure(() -> isNull("a"));
    failure(() -> isNull(Math.NaN));
    failure(() -> isNull(Math.POSITIVE_INFINITY));
    failure(() -> isNull(true));
    failure(() -> isNull(false));
  }

  public function testNoNullity() {
    failure(() -> notNull(null));
    success(() -> notNull(0));
    success(() -> notNull(0.0));
    success(() -> notNull(0.1));
    success(() -> notNull(1));
    success(() -> notNull(""));
    success(() -> notNull("a"));
    success(() -> notNull(Math.NaN));
    success(() -> notNull(Math.POSITIVE_INFINITY));
    success(() -> notNull(true));
    success(() -> notNull(false));
  }

  public function testRaises() {
    //expect exception of any type
    success(() -> raises(() -> throw 'error'));

    //expect specific exception type
    var errors : Array<Any> = ["str",    1,   0.1,   new TestAssert(), {},      [1],    new SampleException('sample exception')];
    var types  : Array<Any> = [String, Int, Float, TestAssert,       Dynamic, Array,  SampleException];
    var expectedsuccess = 14;
    for(errorIndex => error in errors)
      for(typeIndex => type in types) {
        if(errorIndex == typeIndex || type == Dynamic || (Std.isOfType(error, Int) && type == Float)) {
          success(() -> raises(() -> throw error, type), 'success expected: Assert.raises($error, $type)');
        } else {
          failure(() -> raises(() -> throw error, type), 'failure expected: Assert.raises($error, $type)');
        }
      }
  }

  public function testIs() {
    var values : Array<Any> = ["str",    1,   0.1,   new TestAssert(), {},      [1]];
    var types  : Array<Any> = [String, Int, Float, TestAssert,       Dynamic, Array];
    for(valueIndex => value in values)
      for(typeIndex => type in types) {
        if(valueIndex == typeIndex || type == Dynamic || (Std.isOfType(value, Int) && type == Float)) {
          success(() -> isOfType(value, type), 'success expected: Assert.isOfType($value, $type)');
        } else {
          failure(() -> isOfType(value, type), 'failure expected: Assert.isOfType($value, $type)');
        }
      }
  }

  public function testSimilar() {
    similar({value:'hello'}, new Dummy('hello', new Dummy()));
    return;

    success(() -> similar({a:'b'}, {a:'b', c:1}));
    success(() -> similar(['a' => 'b'], ['a' => 'b', 'c' => 'd']));
    success(() -> similar(['a', 'b'], ['a', 'b', 'c']));
    success(() -> similar({value:'hello'}, new Dummy('hello', new Dummy())));
    success(() -> similar({value:'hello', sub:{value:'world'}}, new Dummy('hello', new Dummy('world'))));
    success(() -> similar({sub:{value:'world'}}, new Dummy('hello', new Dummy('world'))));
    success(() -> same(new Dummy(), new DummyLike()));

    failure(() -> similar({a:'b'}, {a:'', c:1}));
    failure(() -> similar({a:'b'}, {c:1}));
    failure(() -> similar(['a' => 'b', 'c' => 'd'], ['a' => 'b']));
    failure(() -> similar(['a' => 'b'], ['a' => 'c']));
    failure(() -> similar(['a', 'b', 'c'], ['a', 'b']));
    failure(() -> similar(['a', 'b', 'c'], ['a', 'b', 'd']));
    failure(() -> similar({value:'hello'}, new Dummy('world')));
    failure(() -> similar({value:'hello', sub:{value:'world'}}, new Dummy('hello', new Dummy('foo'))));
  }

  public function testSamePrimitive() {
    //same primitives
    failure(() -> same(null, 1));
    success(() -> same(1, 1));
    failure(() -> same(1, "1"));
    success(() -> same("a", "a"));
    failure(() -> same(null, ""));
    failure(() -> same(new Date(2000, 0, 1, 0, 0, 0), null));
    success(() -> same([1 => "a", 2 => "b"], [1 => "a", 2 => "b"]));
    success(() -> same(["a" => 1], ["a" => 1]));
    failure(() -> same(["a" => 1], [1 => 1]));
    failure(() -> same([1 => "a"], [1 => "a", 2 => "b"]));
//    TODO doesn't work anymore
//    Assert.same(new Date(2000, 0, 1, 0, 0, 0), new Date(2000, 0, 1, 0, 0, 0));

    //same types
    failure(() -> same(null, {}));
    success(() -> same(null, null));
    failure(() -> same({}, null));
    failure(() -> same({}, 1));
    failure(() -> same({}, []));
    failure(() -> same(null, None));
    failure(() -> same(None, null));

    //same array
    success(() -> same([], []));
    failure(() -> same([1], ["1"]));
    success(() -> same([1,2,3], [1,2,3]));
    failure(() -> same([1,2,3], [1,2]));
    failure(() -> same([1,2],   [1,2,3]));
    success(() -> same(([1,[1,2]]:Array<Any>), ([1,[1,2]]:Array<Any>)));
    success(() -> same(([1,[1,2]]:Array<Any>), ([1,[]]:Array<Any>), false));
    failure(() -> same(([1,[1,2]]:Array<Any>), ([1,[]]:Array<Any>), true));

    //check messages for arrays
    var expectedMessage = 'expected array element at [0] to have 1 but it is 2 for field array[0].field.sub';
    //Use quoted fields names to avoid js minificator to cripple them because
    //we rely on the fields names being intact in this test.
    failMessages(expectedMessage, () -> same([{"field":{"sub":1}}], [{"field":{"sub":2}}]));

    //same objects
    success(() -> same({}, {}));
    failure(() -> same({a:1}, {a:"1"}));
    success(() -> same({a:1,b:"c"}, {a:1,b:"c"}));
    failure(() -> same({a:1,b:"c"}, {a:1,c:"c"}));
    failure(() -> same({a:1,b:"c"}, {a:1}));
    success(() -> same({a:1,b:{a:1,c:"c"}}, {a:1,b:{a:1,c:"c"}}));
    success(() -> same({a:1,b:{a:1,c:"c"}}, {a:1,b:{}}, false));
    failure(() -> same({a:1,b:{a:1,c:"c"}}, {a:1,b:{}}, true));

    //same class instances
    var c1 = new Dummy();
    c1.value = "a";
    var c2 = new Dummy();
    c2.value = "a";
    var c3 = new Dummy();

    var r1 = new Dummy();
    r1.sub = c1;
    var r2 = new Dummy();
    r2.sub = c2;
    var r3 = new Dummy();
    r3.sub = c3;

    success(() -> same(c1, c1));
    success(() -> same(c1, c2));
    failure(() -> same(c1, c3));

    success(() -> same(r1, r2));
    success(() -> same(r1, r3, false));
    failure(() -> same(r1, r3, true));

    failure(() -> same(new Dummy(), new DummyLike()));

    //same iterables
    var list1 = new List<Any>();
    list1.add("a");
    list1.add(1);
    var s1 = new List();
    s1.add(2);
    list1.add(s1);
    var list2 = new List<Any>();
    list2.add("a");
    list2.add(1);
    list2.add(s1);
    var list3 = new List<Any>();
    list3.add("a");
    list3.add(1);
    list3.add(new List());

    success(() -> same(list1, list2));
    success(() -> same(list1, list3, false));
    failure(() -> same(list1, list3, true));

    success(() -> same(0...3, 0...3));
    failure(() -> same(0...3, 0...4));

    //check messages for iterables

    //Use quoted fields names to avoid js minificator to cripple them because
    //we rely on the fields names being intact in this test.
    var list1 = new List();
    list1.add({"field":{"sub":1}});
    var list2 = new List();
    list2.add({"field":{"sub":2}});

    failMessages('expected 1 but it is 2 for field iterable[0].field.sub', () -> same(list1, list2));

    //same maps
    var h1 = new haxe.ds.StringMap();
    h1.set('a', 'b');
    h1.set('c', 'd');
    var h2 = new haxe.ds.StringMap();
    h2.set('a', 'b');
    h2.set('c', 'd');
    var h1ExtraKeys = h1.copy();
    h1ExtraKeys.set('e', 'f');
    var h3 = new haxe.ds.StringMap();
    var h4 = new haxe.ds.StringMap();
    h4.set('c', 'd');

    var i1 = new haxe.ds.IntMap();
    i1.set(2, 'b');
    var i2 = new haxe.ds.IntMap();
    i2.set(2, 'b');

    success(() -> same(h1, h2));
    failure(() -> same(h1, h1ExtraKeys));
    failure(() -> same(h1, h3));
    failure(() -> same(h1, h4));
    success(() -> same(i1, i2));

    //same enums
    success(() -> same(None, None));
    success(() -> same(Some("a"), Some("a")));
    failure(() -> same(Some("a"), Some("b"), true)); //expected to fail
    failure(() -> same(Some("a"), Some("b"), false)); //expected to fail
    failure(() -> same(Some("a"), None)); //expected to fail
    success(() -> same(Rec(Rec(Some("a"))), Rec(Rec(Some("a")))));
    failure(() -> same(Rec(Rec(Some("a"))), Rec(None), true)); //expected to fail
    success(() -> same(Rec(Rec(Some("a"))), Rec(Rec(None)), false));
  }

  public function testEquals() {
    var obj1 = {};
    var obj2 = {};
    var values    : Array<Any> = ["e", 1, 0.1, obj1, obj2];
    var expecteds : Array<Any> = ["e", 1, 0.1, obj1, obj2];
    for(expectedIndex => expected in expecteds)
      for(valueIndex => value in values) {
        if(valueIndex == expectedIndex)
          success(() -> equals(expected, value), 'success expected: equals($expected, $value)')
        else
          failure(() -> equals(expected, value), 'failure expected: equals($expected, $value)');
      }
  }

  public function testFloatEquals() {
    var values    : Array<Float> = [1, 0.1, 0.000000000000000000000000000011, Math.NaN, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.PI, 0.11, 0.12];
    var expecteds : Array<Float> = [1, 0.1, 0.000000000000000000000000000012, Math.NaN, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.PI, 0.11, 0.12];
    for(expectedIndex => expected in expecteds)
      for(valueIndex => value in values) {
        if(valueIndex == expectedIndex)
          success(() -> floatEquals(expected, value), 'success expected: floatEquals($expected, $value)')
        else
          failure(() -> floatEquals(expected, value), 'failure expected: floatEquals($expected, $value)');
      }
  }

  public function testPass() {
    success(() -> pass());
  }

  public function testFail() {
    failure(() -> fail());
  }

  public function testWarn() {
    warning('Attention!', () -> warn('Attention!'));
  }
}

private enum Sample {
  None;
  Some(s : String);
  Rec(s : Sample);
}

private class SampleException extends Exception {}

private class Dummy {
  public var value : Null<String>;
  public var sub : Null<Dummy>;
  public function new(?value:String, ?sub:Dummy) {
    this.value = value;
    this.sub = sub;
  }
}

private class DummyLike {
  public var value : Null<String>;
  public var sub : Null<DummyLike>;
  public function new(?value:String, ?sub:DummyLike) {
    this.value = value;
    this.sub = sub;
  }
}