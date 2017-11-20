package utest.ui.common;

import utest.Assertation;

class FixtureResult {
  public var methodName(default, null) : String;
  public var hasTestError(default, null) : Bool;
  public var hasSetupError(default, null) : Bool;
  public var hasTeardownError(default, null) : Bool;
  public var hasTimeoutError(default, null) : Bool;
  public var hasAsyncError(default, null) : Bool;

  public var stats(default, null) : ResultStats;

  var list(default, null) : List<Assertation>;
  public function new(methodName : String) {
    this.methodName = methodName;
    this.list = new List();
    hasTestError = false;
    hasSetupError = false;
    hasTeardownError = false;
    hasTimeoutError = false;
    hasAsyncError = false;

    stats = new ResultStats();
  }

  public function iterator()
    return list.iterator();

  public function add(assertation : Assertation) {
    list.add(assertation);
    switch(assertation) {
      case Assertation.Success(_):
        stats.addSuccesses(1);
      case Assertation.Failure(_, _):
        stats.addFailures(1);
      case Assertation.Error(_, _):
        stats.addErrors(1);
      case Assertation.SetupError(_, _):
        stats.addErrors(1);
        hasSetupError = true;
      case Assertation.TeardownError(_, _):
        stats.addErrors(1);
        hasTeardownError = true;
      case Assertation.TimeoutError(_, _):
        stats.addErrors(1);
        hasTimeoutError = true;
      case Assertation.AsyncError(_, _):
        stats.addErrors(1);
        hasAsyncError = true;
      case Assertation.Warning(_):
        stats.addWarnings(1);
      case Assertation.Ignore(_):
        stats.addIgnores(1);
    }
  }
}