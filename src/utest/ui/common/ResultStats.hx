package utest.ui.common;

import utest.Dispatcher;

class ResultStats {
  public var assertations(default, null) : Int;
  public var successes(default, null) : Int;
  public var failures(default, null) : Int;
  public var errors(default, null) : Int;
  public var warnings(default, null) : Int;
  public var ignores(default,null) : Int;

  public var onAddSuccesses(default, null) : Dispatcher<Int>;
  public var onAddFailures(default, null)  : Dispatcher<Int>;
  public var onAddErrors(default, null)    : Dispatcher<Int>;
  public var onAddWarnings(default, null)  : Dispatcher<Int>;
  public var onAddIgnores(default, null)   : Dispatcher<Int>;

  public var isOk(default, null) : Bool;
  public var hasFailures(default, null) : Bool;
  public var hasErrors(default, null) : Bool;
  public var hasWarnings(default, null) : Bool;
  public var hasIgnores(default, null) : Bool;

  public function new() {
    assertations = 0;
    successes = 0;
    failures = 0;
    errors = 0;
    warnings = 0;
    ignores = 0;

    isOk = true;
    hasFailures = false;
    hasErrors = false;
    hasWarnings = false;
    hasIgnores = false;

    onAddSuccesses = new Dispatcher();
    onAddFailures = new Dispatcher();
    onAddErrors = new Dispatcher();
    onAddWarnings = new Dispatcher();
    onAddIgnores = new Dispatcher();
  }

  public function addSuccesses(v : Int) {
    if(v == 0) return;
    assertations += v;
    successes += v;
    onAddSuccesses.dispatch(v);
  }

  public function addFailures(v : Int) {
    if(v == 0) return;
    assertations += v;
    failures += v;
    hasFailures = failures > 0;
    isOk = !(hasFailures || hasErrors || hasWarnings);
    onAddFailures.dispatch(v);
  }

  public function addErrors(v : Int) {
    if(v == 0) return;
    assertations += v;
    errors += v;
    hasErrors = errors > 0;
    isOk = !(hasFailures || hasErrors || hasWarnings);
    onAddErrors.dispatch(v);
  }

  public function addIgnores(v:Int) {
    if (v == 0) return;
    assertations += v;
    ignores += v;
    hasIgnores = ignores > 0;
    onAddIgnores.dispatch(v);
  }

  public function addWarnings(v : Int) {
    if(v == 0) return;
    assertations += v;
    warnings += v;
    hasWarnings = warnings > 0;
    isOk = !(hasFailures || hasErrors || hasWarnings);
    onAddWarnings.dispatch(v);
  }

  public function sum(other : ResultStats) {
    addSuccesses(other.successes);
    addFailures(other.failures);
    addErrors(other.errors);
    addWarnings(other.warnings);
    addIgnores(other.ignores);
  }

  public function subtract(other : ResultStats) {
    addSuccesses(-other.successes);
    addFailures(-other.failures);
    addErrors(-other.errors);
    addWarnings(-other.warnings);
    addIgnores(-other.ignores);
  }

  public function wire(dependant : ResultStats) {
    dependant.onAddSuccesses.add(addSuccesses);
    dependant.onAddFailures.add(addFailures);
    dependant.onAddErrors.add(addErrors);
    dependant.onAddWarnings.add(addWarnings);
    dependant.onAddIgnores.add(addIgnores);
    sum(dependant);
  }

  public function unwire(dependant : ResultStats) {
    dependant.onAddSuccesses.remove(addSuccesses);
    dependant.onAddFailures.remove(addFailures);
    dependant.onAddErrors.remove(addErrors);
    dependant.onAddWarnings.remove(addWarnings);
    dependant.onAddIgnores.remove(addIgnores);
    subtract(dependant);
  }

}