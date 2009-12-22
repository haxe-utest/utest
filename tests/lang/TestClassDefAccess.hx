package lang;

import utest.Assert;

import lang.util.A;

class TestClassDefAccess {
  public function new(){}

  public function testAccess() {
    var c = A;
    Assert.notNull(c);
    var c = lang.util.A;
    Assert.notNull(c);
  }

  public function testMethodAccess() {
    var c = A;
    Assert.equals("test", c.test());
  }

  public function testVarAccess() {
    var c = A;
    Assert.equals("test", c.s);
    c.s = "test2";
    Assert.equals("test2", c.s);
  }
}