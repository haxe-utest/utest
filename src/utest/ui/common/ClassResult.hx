package utest.ui.common;

import utest.TestResult;

class ClassResult {
  var fixtures : Map<String, FixtureResult>;
  public var className(default, null) : String;
  public var setupName(default, null) : String;
  public var teardownName(default, null) : String;
  public var hasSetup(default, null) : Bool;
  public var hasTeardown(default, null) : Bool;

  public var methods(default, null) : Int;
  public var stats(default, null) : ResultStats;

  public function new(className : String, setupName : String, teardownName : String) {
    fixtures = new Map();
    this.className = className;
    this.setupName = setupName;
    hasSetup = setupName != null;
    this.teardownName = teardownName;
    hasTeardown = teardownName != null;

    methods = 0;
    stats = new ResultStats();
  }

  public function add(result : FixtureResult) {
    if(fixtures.exists(result.methodName)) throw "invalid duplicated fixture result";

    stats.wire(result.stats);

    methods++;
    fixtures.set(result.methodName, result);
  }

  public function get(method : String)
    return fixtures.get(method);

  public function exists(method : String)
    return fixtures.exists(method);

  public function methodNames(errorsHavePriority = true) : Array<String> {
    var names = [];
    for(name in fixtures.keys())
      names.push(name);
    if(errorsHavePriority) {
      var me = this;
      names.sort(function(a, b) {
        var as = me.get(a).stats;
        var bs = me.get(b).stats;
        if(as.hasErrors) {
          return (!bs.hasErrors) ? -1 : (as.errors == bs.errors ? Reflect.compare(a, b) : Reflect.compare(as.errors, bs.errors));
        } else if(bs.hasErrors) {
          return 1;
        } else if(as.hasFailures) {
          return (!bs.hasFailures) ? -1 : (as.failures == bs.failures ? Reflect.compare(a, b) : Reflect.compare(as.failures, bs.failures));
        } else if(bs.hasFailures) {
          return 1;
        } else if(as.hasWarnings) {
          return (!bs.hasWarnings) ? -1 : (as.warnings == bs.warnings ? Reflect.compare(a, b) : Reflect.compare(as.warnings, bs.warnings));
        } else if(bs.hasWarnings) {
          return 1;
        } else {
          return Reflect.compare(a, b);
        }
      });
    } else {
      names.sort(function(a, b) {
        return Reflect.compare(a, b);
      });
    }
    return names;
  }


}