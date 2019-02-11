package utest;

@:keep
class TestRunner {
  public function new(){}

  public function testAddCases_notRecursive() {
    var runner = new Runner();
    runner.addCases('utest.testrunner', false);
    Assert.equals(2, runner.length);
  }

  public function testAddCases_recursive() {
    var runner = new Runner();
    runner.addCases('utest.testrunner', true);
    Assert.equals(3, runner.length);
  }

  public function testAddCases_identifier() {
    var runner = new Runner();
    runner.addCases(utest.testrunner, true);
    Assert.equals(3, runner.length);
  }
}