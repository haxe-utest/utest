package utest.testrunner.sub;

@:keep
class TestDummy3 implements ITest {
  public function new() {}

  public function testDummy() {
    Assert.pass();
  }
}