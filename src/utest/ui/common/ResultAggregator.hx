/*
* TODO: this class needs to be tested
*/
package utest.ui.common;

import utest.Runner;
import utest.TestResult;

class ResultAggregator {
	var runner : Runner;
	var flattenPackage : Bool;
	public var root(default, null) : PackageResult;
	public function new(runner : Runner, flattenPackage = false) {
		if(runner == null) throw "runner argument is null";
		this.flattenPackage = flattenPackage;
		this.runner = runner;
		runner.onStart = start;
		runner.onProgress = progress;
		runner.onComplete = complete;
	}

	function start(runner : Runner) {
		root = new PackageResult(null);
		onStart();
	}

	function getOrCreatePackage(pack : String, flat : Bool, ?ref : PackageResult) {
		if(ref == null) ref = root;
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

	function getOrCreateClass(pack : PackageResult, cls : String, setup : String, teardown : String) {
		if(pack.existsClass(cls)) return pack.getClass(cls);
		var c = new ClassResult(cls, setup, teardown);
		pack.addClass(c);
		return c;
	}

	function createFixture(result : TestResult) {
		var f = new FixtureResult(result.executionTime, result.method);
		for(assertation in result.assertations)
			f.add(assertation);
		return f;
	}

	function progress(runner : Runner, result : TestResult, done : Int, totals : Int) {
		root.addResult(result, flattenPackage);
		onProgress(done, totals);
	}

	function complete(runner : Runner) {
		onComplete(root);
	}

	public dynamic function onStart();
	public dynamic function onComplete(pack : PackageResult);
	public dynamic function onProgress(done : Int, totals : Int);
}