package utest;

import utest.TestHandler;
import utest.TestFixture;

@:keep
class TestIgnored {
  public function new() {
  }

  public function testIgnoredWithoutReason():Void {
    var async = Assert.createAsync();

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

      async();
    });

    runner.run();
  }

  public function testIgnoredWithReason():Void {
    var async = Assert.createAsync();

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

      async();
    });

    runner.run();
  }
}

@:keep
class TestCaseWithIgnoredCaseWithoutReason {
  public function new() {}

  @Ignored
  public function testIgnoredWithoutReason():Void {
    Assert.fail();
  }
}

@:keep
class TestCaseWithIgnoredCaseWithReason {
  public function new() {}

  @Ignored("REASON")
  public function testIgnoredWithReason():Void {
    Assert.fail();
  }
}
