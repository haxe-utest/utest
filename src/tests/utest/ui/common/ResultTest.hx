package tests.utest.ui.common;

import utest.Assert;
import utest.Assertation;
import utest.Runner;
import utest.ui.text.TraceReport;
import utest.ui.common.PackageResult;
import utest.ui.common.ClassResult;
import utest.ui.common.FixtureResult;
import utest.ui.common.ResultAggregator;

class ResultTest {
	public function new();

	public static function main() {
		var runner = new Runner();
		runner.addCase(new ResultTest());
		var report = new TraceReport(runner);
		runner.run();
	}

	public function testFixtureResultEmpty() {
		var r = new FixtureResult(0, "test");
		Assert.equals(0, r.assertations);
		Assert.equals(0, r.errors);
		Assert.equals(0, r.failures);
		Assert.equals(0, r.successes);
		Assert.equals(0, r.warnings);
		Assert.isFalse(r.hasAsyncError);
		Assert.isFalse(r.hasErrors);
		Assert.isFalse(r.hasFailures);
		Assert.isFalse(r.hasSetupError);
		Assert.isFalse(r.hasTeardownError);
		Assert.isFalse(r.hasTestError);
		Assert.isFalse(r.hasTimeoutError);
		Assert.isFalse(r.hasWarnings);
		Assert.isTrue(r.isOk);

		var c = 0;
		for(_ in r.iterator())
			c++;
		Assert.equals(0, c);
	}

	public function testFixtureResultAll() {
		var r = new FixtureResult(0, "test");

		r.add(Success(null));
		Assert.isTrue(r.isOk);
		Assert.equals(1, r.assertations);
		Assert.equals(0, r.errors);
		Assert.equals(0, r.failures);
		Assert.equals(1, r.successes);
		Assert.equals(0, r.warnings);

		r.add(Success(null));
		Assert.isTrue(r.isOk);
		Assert.equals(2, r.assertations);

		r.add(Failure(null, null));
		Assert.isFalse(r.isOk);
		Assert.equals(1, r.failures);
		Assert.equals(2, r.successes);
		Assert.equals(3, r.assertations);

		r.add(Failure(null, null));
		Assert.isFalse(r.isOk);
		Assert.equals(2, r.failures);

		r.add(Error(null));
		Assert.equals(2, r.failures);
		Assert.equals(1, r.errors);

		r.add(SetupError(null));
		Assert.equals(2, r.errors);
		Assert.isTrue(r.hasSetupError);
		Assert.isFalse(r.hasTeardownError);

		r.add(TeardownError(null));
		Assert.equals(3, r.errors);
		Assert.isTrue(r.hasTeardownError);

		r.add(TimeoutError(0));
		Assert.equals(4, r.errors);
		Assert.isTrue(r.hasTimeoutError);

		r.add(AsyncError(null));
		Assert.equals(5, r.errors);
		Assert.isTrue(r.hasAsyncError);

		Assert.equals(0, r.warnings);
		Assert.isFalse(r.hasWarnings);
		r.add(Warning(null));
		Assert.equals(1, r.warnings);
		Assert.isTrue(r.hasWarnings);

		r.add(Warning(null));
		Assert.equals(2, r.warnings);
		Assert.isTrue(r.hasWarnings);

		Assert.isFalse(r.isOk);
		Assert.equals(11, r.assertations);

		var c = 0;
		for(_ in r.iterator())
			c++;
		Assert.equals(11, c);
	}

	function createFixture(method : String, ?assertations : Array<Assertation>) {
		var fix = new FixtureResult(1, method);
		if(assertations != null)
			for(assertation in assertations)
				fix.add(assertation);
		return fix;
	}

	function equalsArrays(a : Array<String>, b : Array<String>, id : String) {
		if(a.length != b.length) {
			Assert.fail("arrays length doesn't match");
			return;
		}
		for(i in 0...a.length) {
			Assert.equals(a[i], b[i], id+ ": error at index #"+i);
		}
	}

	public function testClassResult() {
		var r = new ClassResult("c", null, null);
		Assert.equals("c", r.className);
		Assert.equals(0, r.methods);
		Assert.equals(0, r.successes);
		Assert.equals(0, r.assertations);
		Assert.equals(0, r.errors);
		Assert.equals(0, r.failures);
		Assert.equals(0, r.warnings);
		Assert.isFalse(r.hasErrors);
		Assert.isFalse(r.hasFailures);
		Assert.isFalse(r.hasWarnings);
		Assert.isFalse(r.hasSetup);
		Assert.isFalse(r.hasTeardown);

		r.add(createFixture("a", [Success(null)]));
		Assert.equals(1, r.methods);
		Assert.equals(1, r.successes);
		Assert.equals(1, r.assertations);
		Assert.equals(0, r.errors);
		Assert.equals(0, r.failures);
		Assert.equals(0, r.warnings);
		Assert.isFalse(r.hasErrors);
		Assert.isFalse(r.hasFailures);
		Assert.isFalse(r.hasWarnings);

		r.add(createFixture("b", [Warning(null), Success(null)]));
		Assert.equals(2, r.methods);
		Assert.equals(2, r.successes);
		Assert.equals(3, r.assertations);
		Assert.equals(1, r.warnings);
		Assert.isFalse(r.hasErrors);
		Assert.isFalse(r.hasFailures);
		Assert.isTrue(r.hasWarnings);

		equalsArrays(["a", "b"], r.methodNames(false), "warnings #1");
		equalsArrays(["b", "a"], r.methodNames(), "warnings #2");
		equalsArrays(["b", "a"], r.methodNames(true), "warnings #3");

		r.add(createFixture("c", [Failure(null, null)]));
		Assert.equals(3, r.methods);
		Assert.equals(2, r.successes);
		Assert.equals(4, r.assertations);
		Assert.equals(1, r.failures);
		Assert.isTrue(r.hasFailures);

		equalsArrays(["a", "b", "c"], r.methodNames(false), "failures #1");
		equalsArrays(["c", "b", "a"], r.methodNames(), "failures #2");

		r.add(createFixture("d", [Error(null)]));
		Assert.equals(4, r.methods);
		Assert.equals(2, r.successes);
		Assert.equals(5, r.assertations);
		Assert.equals(1, r.failures);
		Assert.equals(1, r.errors);
		Assert.isTrue(r.hasErrors);
		equalsArrays(["a", "b", "c", "d"], r.methodNames(false), "errors #1");
		equalsArrays(["d", "c", "b", "a"], r.methodNames(), "errors #1");
	}

	public function testClassResultSetupTeardown() {
		var r = new ClassResult("c", "s", null);
		Assert.equals("s", r.setupName);
		Assert.isTrue(r.hasSetup);
		Assert.isFalse(r.hasTeardown);

		r = new ClassResult("c", null, "t");
		Assert.equals("t", r.teardownName);
		Assert.isFalse(r.hasSetup);
		Assert.isTrue(r.hasTeardown);
	}
}