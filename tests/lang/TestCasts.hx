package lang;

import utest.Assert;

import lang.util.T;
import lang.util.T2;
import lang.util.ITest;

class TestCasts {
  public function new() {}

  public function testCastFromType() {
    var x : T = new T2();
    Assert.is(x, T);
    var y : T2 = cast(x, T2);
    Assert.is(x, T2);
  }

  public function testCastFromInterface() {
    var x : ITest = new T();
    Assert.is(x, ITest);
    var y : T = cast(x, T);
    Assert.is(x, T);
  }

  public function testUnsafeCast() {
    var x : T = new T2();
    Assert.is(x, T);
    var y : T2 = cast x;
    Assert.is(x, T2);
  }
}