package utest;

@:keep
class TestRunner extends Test {

  public function testAddCases_notRecursive() {
    var runner = new Runner();
    runner.addCases('utest.testrunner', false);
    Assert.equals(3, runner.length);
  }

  public function testAddCases_recursive() {
    var runner = new Runner();
    runner.addCases('utest.testrunner', true);
    Assert.equals(4, runner.length);
  }

  public function testAddCases_packageIdentifier() {
    var runner = new Runner();
    runner.addCases(utest.testrunner, true);
    Assert.equals(4, runner.length);
  }

  public function testAddCases_nameFilter() {
    var runner = new Runner();
    runner.addCases('utest.testrunner', true, 'Dummy3');
    Assert.equals(1, runner.length);

    var runner = new Runner();
    runner.addCases('utest.testrunner', true, '^Test');
    Assert.equals(3, runner.length);
  }
}