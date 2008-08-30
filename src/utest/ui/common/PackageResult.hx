/*
* TODO: this class needs to be tested
*/
package utest.ui.common;

import utest.TestResult;
import utest.Assertation;

class PackageResult {
	public var executionTime(default, null) : Int;
	public var packageName(default, null) : String;
	var classes : Hash<ClassResult>;
	var packages : Hash<PackageResult>;

	public var assertations(default, null) : Int;
	public var successes(default, null) : Int;
	public var failures(default, null) : Int;
	public var errors(default, null) : Int;
	public var warnings(default, null) : Int;

	public var isOk(default, null) : Bool;
	public var hasFailures(default, null) : Bool;
	public var hasErrors(default, null) : Bool;
	public var hasWarnings(default, null) : Bool;

	public function new(packageName : String) {
		this.packageName = packageName;

		executionTime = 0;
		classes = new Hash();
		packages = new Hash();

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

	public function addResult(result : TestResult, flattenPackage : Bool) {
		var pack = getOrCreatePackage(result.pack, flattenPackage, this);
		var cls = getOrCreateClass(pack, result.cls, result.setup, result.teardown);
		var fix = createFixtureAndIncrement(result.method, result.executionTime, result.assertations);
		cls.add(fix);
	}

	function createFixtureAndIncrement(method : String, executionTime : Int, assertations : Iterable<Assertation>) {
		var f = new FixtureResult(executionTime, method);
		for(assertation in assertations)
			f.add(assertation);

		executionTime += f.executionTime;
		this.assertations += f.assertations;
		successes += f.successes;
		failures += f.failures;
		errors += f.errors;
		warnings += f.warnings;

		isOk = isOk && f.isOk;
		if(f.hasFailures)
			hasFailures = true;
		if(f.hasErrors)
			hasErrors = true;
		if(f.hasWarnings)
			hasWarnings = true;

		return f;
	}

	function getOrCreateClass(pack : PackageResult, cls : String, setup : String, teardown : String) {
		if(pack.existsClass(cls)) return pack.getClass(cls);
		var c = new ClassResult(cls, setup, teardown);
		pack.addClass(c);
		return c;
	}

	function getOrCreatePackage(pack : String, flat : Bool, ref : PackageResult) {
		if(pack == null || pack == '') return ref;
		if(flat) {
			if(ref.existsPackage(pack))
				return ref.getPackage(pack);
			var p = new PackageResult(pack);
			ref.addPackage(p);
			return p;
		} else {
			var parts = pack.split('.');
			for(part in parts) {
				ref = getOrCreatePackage(part, true, ref);
			}
			return ref;
		}
	}

	public function addClass(result : ClassResult) {
		classes.set(result.className, result);

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

	public function addPackage(result : PackageResult) {
		packages.set(result.packageName, result);

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

	public function existsPackage(name : String) {
		return packages.exists(name);
	}

	public function existsClass(name : String) {
		return classes.exists(name);
	}

	public function getPackage(name : String) {
		return packages.get(name);
	}

	public function getClass(name : String) {
		return classes.get(name);
	}

	public function classNames(errorsHavePriority = true) : Array<String> {
		var names = [];
		for(name in classes.keys())
			names.push(name);
		if(errorsHavePriority) {
			var me = this;
			names.sort(function(a, b) {
				var afix = me.getClass(a);
				var bfix = me.getClass(b);
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

	public function packageNames(errorsHavePriority = true) : Array<String> {
		var names = [];
		for(name in packages.keys())
			names.push(name);
		if(errorsHavePriority) {
			var me = this;
			names.sort(function(a, b) {
				var afix = me.getPackage(a);
				var bfix = me.getPackage(b);
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