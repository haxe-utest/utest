package utest;

import utest.TestHandler;
import utest.TestFixture;
import utest.Async;

@:keep
class TestIgnored extends Test {

  public function testIgnoredWithoutReason(async:Async):Void {
    var runner:Runner = new Runner();
    runner.addCase(new TestCaseWithIgnoredCaseWithoutReason());

    var completedTests:Array<TestHandler<TestFixture>> = new Array<TestHandler<TestFixture>>();
    runner.onTestComplete.add(function(th:TestHandler<TestFixture>) {
      completedTests.push(th);
    });

    runner.onComplete.add(function(runner:Runner) {
      Assert.equals(1, completedTests.length);

      var th:TestHandler<TestFixture> = completedTests[0];

      Assert.equals(1, th.results.length);

      switch(th.results.first()) {
        case Assertation.Ignore(""): Assert.pass();
        default: Assert.fail('Expected Assertation.Ignore(""), Received: ${th.results.first()}');
      }

      async.done();
    });

    runner.run();
  }

  public function testIgnoredWithReason(async:Async):Void {
    var runner:Runner = new Runner();
    runner.addCase(new TestCaseWithIgnoredCaseWithReason());

    var completedTests:Array<TestHandler<TestFixture>> = new Array<TestHandler<TestFixture>>();
    runner.onTestComplete.add(function(th:TestHandler<TestFixture>) {
      completedTests.push(th);
    });

    runner.onComplete.add(function(runner:Runner) {
      Assert.equals(1, completedTests.length);

      var th:TestHandler<TestFixture> = completedTests[0];

      Assert.equals(1, th.results.length);

      switch(th.results.first()) {
        case Assertation.Ignore("REASON"): Assert.pass();
        default: Assert.fail('Expected Assertation.Ignore("REASON"), Received: ${th.results.first()}');
      }

      async.done();
    });

    runner.run();
  }
}

@:keep
class TestCaseWithIgnoredCaseWithoutReason extends Test {
  @Ignored
  public function testIgnoredWithoutReason():Void {
    Assert.fail();
  }
}

@:keep
class TestCaseWithIgnoredCaseWithReason extends Test {

  @Ignored("REASON")
  public function testIgnoredWithReason():Void {
    Assert.fail();
  }
}
