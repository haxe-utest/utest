package utest.testrunner;

@:keep
class TestDummy1 implements ITest {
  public function new() {}

  public function testDummy() {
    Assert.pass();
  }
}