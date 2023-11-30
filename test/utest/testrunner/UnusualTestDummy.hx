package utest.testrunner;

@:keep
class UnusualTestDummy implements ITest {
  public function new() {}

  public function testDummy() {
    Assert.pass();
  }
}