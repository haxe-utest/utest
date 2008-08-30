package utest.ui.common;

import utest.TestResult;

class ClassResult {
	public var executionTime(default, null) : Int;
	var fixtures : Hash<FixtureResult>;
	public var className(default, null) : String;
	public var setupName(default, null) : String;
	public var teardownName(default, null) : String;
	public var hasSetup(default, null) : Bool;
	public var hasTeardown(default, null) : Bool;

	public var methods(default, null) : Int;
	public var assertations(default, null) : Int;
	public var successes(default, null) : Int;
	public var failures(default, null) : Int;
	public var errors(default, null) : Int;
	public var warnings(default, null) : Int;

	public var isOk(default, null) : Bool;
	public var hasFailures(default, null) : Bool;
	public var hasErrors(default, null) : Bool;
	public var hasWarnings(default, null) : Bool;

	public function new(className : String, setupName : String, teardownName : String) {
		executionTime = 0;
		fixtures = new Hash();
		this.className = className;
		this.setupName = setupName;
		hasSetup = setupName != null;
		this.teardownName = teardownName;
		hasTeardown = teardownName != null;

		methods = 0;
		assertations = 0;
		successes = 0;
		failures = 0;
		errors = 0;
		warnings = 0;

		isOk = true;
		hasFailures = false;
		hasErrors = false;
		hasWarnings = false;
	}

	public function add(result : FixtureResult) {
		if(fixtures.exists(result.methodName)) throw "invalid duplicated fixture result";
		methods++;
		fixtures.set(result.methodName, result);
		executionTime += result.executionTime;
		assertations += result.assertations;
		successes += result.successes;
		failures += result.failures;
		errors += result.errors;
		warnings += result.warnings;
		isOk = isOk && result.isOk;
		if(result.hasFailures)
			hasFailures = true;
		if(result.hasErrors)
			hasErrors = true;
		if(result.hasWarnings)
			hasWarnings = true;
	}

	public function get(method : String) {
		return fixtures.get(method);
	}

	public function exists(method : String) {
		return fixtures.exists(method);
	}

	public function methodNames(errorsHavePriority = true) : Array<String> {
		var names = [];
		for(name in fixtures.keys())
			names.push(name);
		if(errorsHavePriority) {
			var me = this;
			names.sort(function(a, b) {
				var afix = me.get(a);
				var bfix = me.get(b);
				if(afix.hasErrors) {
					return (!bfix.hasErrors) ? -1 : (afix.errors == bfix.errors ? Reflect.compare(a, b) : Reflect.compare(afix.errors, bfix.errors));
				} else if(bfix.hasErrors) {
					return 1;
				} else if(afix.hasFailures) {
					return (!bfix.hasFailures) ? -1 : (afix.failures == bfix.failures ? Reflect.compare(a, b) : Reflect.compare(afix.failures, bfix.failures));
				} else if(bfix.hasFailures) {
					return 1;
				} else if(afix.hasWarnings) {
					return (!bfix.hasWarnings) ? -1 : (afix.warnings == bfix.warnings ? Reflect.compare(a, b) : Reflect.compare(afix.warnings, bfix.warnings));
				} else if(bfix.hasWarnings) {
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