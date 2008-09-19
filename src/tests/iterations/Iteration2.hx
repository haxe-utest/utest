package tests.iterations;

import utest.Assert;
import utest.Runner;
import utest.TestFixture;

class Iteration2 {
	public function new();

	// #1
	public function testRunnerRun() {
		var r = new Runner();
		r.fixtures.add(new TestFixture(new TestClass(), "assertTrue"));
		r.onProgress.add(function(e) {
			trace(e.done == 1 ? "OK @1" : "FAIL");
		});
		r.run();
	}

	// #2
	public function testAssertCreateAsync() {
		var r = new Runner();
		r.fixtures.add(new TestFixture(new TestClass(), "assertAsync"));
		r.onProgress.add(function(e) {
			trace(e.done == 1 ? "OK @2" : "FAIL");
		});
		r.run();
	}

	// #3
	public function testRunnerSequenceOnAsync() {
		var r = new Runner();
		var test = new TestSequenceClass();
		r.fixtures.add(new TestFixture(test, "test1"));
		r.fixtures.add(new TestFixture(test, "test2"));
		r.fixtures.add(new TestFixture(test, "test3"));
		r.onComplete.add(function(r){
			trace(test.seq == "123" ? "OK @3" : "FAIL");
		});
		r.run();
	}

	// #4
	public function testRunnerAddCase() {
		var r = new Runner();
		r.addCase(new TestCaseClass());
		trace(r.fixtures.length == 1     ? "OK @4" : "FAIL");
		var fix = r.fixtures.pop();
		trace(fix.method   == "testOne"  ? "OK @5" : "FAIL");
		trace(fix.setup    == null       ? "OK @6" : "FAIL");
		trace(fix.teardown == "teardown" ? "OK @7" : "FAIL");
	}

	// #5
	public function testRunnerAddCaseCustomFun() {
		var r = new Runner();
		r.addCase(new TestCaseClass(), "_setup", "_teardown");
		var fix = r.fixtures.pop();
		trace(fix.setup    == "_setup" ? "OK @8" : "FAIL");
		trace(fix.teardown == null     ? "OK @9" : "FAIL");
	}

	// #6
	public function testRunnerAddCaseCustomPrefix() {
		var r = new Runner();
		r.addCase(new TestCaseClass(), "_setup", "teardown", "Test");
		trace(r.fixtures.length == 1     ? "OK @10" : "FAIL ");
		var fix = r.fixtures.pop();
		trace(fix.method   == "TestTwo"  ? "OK @11" : "FAIL");
		trace(fix.setup    == "_setup"   ? "OK @12" : "FAIL");
		trace(fix.teardown == "teardown" ? "OK @13" : "FAIL");
	}

	// #7
	public function testRunnerAddCaseCustomPattern() {
		var r = new Runner();
		r.addCase(new TestCaseClass(), null, null, ~/test/i);
		trace(r.fixtures.length == 3     ? "OK @14" : "FAIL");
	}


	public static function main() {
		var r = new Iteration2();

		r.testRunnerRun();
		r.testAssertCreateAsync();
		r.testRunnerSequenceOnAsync();
		r.testRunnerAddCase();
		r.testRunnerAddCaseCustomFun();
		r.testRunnerAddCaseCustomPrefix();
#if (flash9 || !flash)
		r.testRunnerAddCaseCustomPattern();
#end
	}
}

class TestSequenceClass {
	public var seq : String;
	public function new() {
		seq = "";
	}

	public function test1() {
		var me = this;
		var async = Assert.createAsync(function() me.seq += "1");
#if (flash || js)
		haxe.Timer.delay(async, 100);
#else
		async();
#end
	}

	public function test2() {
		var me = this;
		var async = Assert.createAsync(function() me.seq += "2");
#if (flash || js)
		haxe.Timer.delay(async, 50);
#else
		async();
#end
	}

	public function test3() {
		var me = this;
		var async = Assert.createAsync(function() me.seq += "3");
		async();
	}
}