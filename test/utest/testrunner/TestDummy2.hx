package utest.testrunner;

@:keep
class TestDummy2 implements ITest {
  public function new() {}

  public function testDummy() {
    Assert.pass();
  }
}