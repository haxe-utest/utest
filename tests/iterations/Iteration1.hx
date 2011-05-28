package iterations;

import utest.Assert;
import utest.TestFixture;
import utest.TestHandler;

class Iteration1 {
	static inline var TIMEOUT = 50;
	static inline var DELAY   = 5;
	function new(){}

	// @1
	public function testTestClass() {
		var subject = new TestClass();
		subject.test();
		trace(subject.tested ? "OK @1" : "FAIL");
	}

	// @2
	public function testHandlerExecute() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		handler.execute();
		trace(fixture.target.tested ? "OK @2" : "FAIL");
	}

	// @3
	public function testHandlerProtectedContext() {
		var fixture = new TestFixture(new TestClass(), "throwError");
		var handler = new TestHandler(fixture);
		try {
			handler.execute();
			trace("OK @3");
		} catch(e : Dynamic) {
			trace("FAIL");
		}
	}

	// @4
	public function assertTrueSuccess() {
		Assert.results = new List();
		Assert.isTrue(true, null);
		var r = Assert.results.pop();
		Assert.results = null;
		switch(r) {
			case Success(p):
				trace(p != null ? "OK @4" : "FAIL");
			default:
				trace("FAIL");
		}
	}

	// @5
	public function assertTrueFailureNoMessage() {
		Assert.results = new List();
		Assert.isTrue(false); // null message
		var r = Assert.results.pop();
		Assert.results = null;
		switch(r) {
			case Failure(m, p):
				trace(p != null ? "OK @5" : "FAIL");
			default:
				trace("FAIL");
		}
	}

	// @6
	public function assertTrueFailureMessage() {
		Assert.results = new List();
		Assert.isTrue(false, "FAIL");
		var r = Assert.results.pop();
		Assert.results = null;
		switch(r) {
			case Failure(m, p):
				trace((m == "FAIL" && p != null) ? "OK @6" : "FAIL");
			default:
				trace("FAIL");
		}
	}

	// @7
	public function testHandlerHasResults() {
		var fixture = new TestFixture(new TestClass(), "assertTrue");
		var handler = new TestHandler(fixture);
		handler.execute();

		trace(handler.fixture != null && handler.results.length == 1 ? "OK @7" : "FAIL");
	}

	// @8
	public function testHandlerHasError() {
		var fixture = new TestFixture(new TestClass(), "throwError");
		var handler = new TestHandler(fixture);
		handler.execute();

		trace(handler.fixture != null && handler.results.length == 1 ? "OK @8" : "FAIL");
		switch(handler.results.pop()) {
			case Error(e, _):
				trace(e == "error" ? "OK @9" : "FAIL");
			default:
				trace("FAIL");
		}
	}

	// @9
	public function testHandlerSetup() {
		var fixture = new TestFixture(new TestClass(), "test", "setup");
		var handler = new TestHandler(fixture);
		handler.execute();
		trace(fixture.target.donesetup ? "OK @10" : "FAIL");
	}

	// @10
	public function testHandlerSetupError() {
		var fixture = new TestFixture(new TestClass(), "test", "throwError"); // setup now throws an exception
		var handler = new TestHandler(fixture);
		handler.execute();
		switch(handler.results.pop()) {
			case SetupError(e, _):
				trace(e == "error" ? "OK @11" : "FAIL");
			default:
				trace("FAIL");
		}
	}

	// @11
	public function testHandlerCompleteSync() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var flag = false;
		handler.onTested.add(function(h) {
			flag = true;
		});
		handler.execute();
		trace(flag ? "OK @12" : "FAIL");
	}

	// @12
	public function testHandlerSetTimeout() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);

		trace(handler.expireson == null ? "OK @13" : "FAIL");
		var before = haxe.Timer.stamp();
		handler.setTimeout(1);
		var after = haxe.Timer.stamp();
		trace(handler.expireson >= before ? "OK @14" : "FAIL");
		trace(handler.expireson <= (after+1) ? "OK @15" : "FAIL");
	}

	// @13
	public function testHandlerTimeout() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var flag1 = false;
		var flag2 = false;
		handler.addAsync(function() {
			// do nothing
		}, TIMEOUT);
		handler.onTimeout.add(function(h) {
			trace(flag1 ? "OK @15" : "FAIL");
			flag2 = true;
		});
		handler.onTested.add(function(h) {
			trace("FAIL");
		});
		trace(flag1 ? "FAIL" : "OK @16");
		flag1 = true;
		handler.execute();
#if (flash || js)
		haxe.Timer.delay(function() trace(flag2 ? "OK @17" : "FAIL"), TIMEOUT*2);
#else
		trace(flag2 ? "OK @17" : "FAIL");
#end
	}

	// @14
	public function testAsync() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var flag = false;
		var async = handler.addAsync(function() {
			trace(flag ? "FAIL" : "OK @18");
			flag = true;
		}, TIMEOUT*2);
		handler.onTimeout.add(function(h) {
			trace("TIMEOUT");
		});
		handler.onTested.add(function(h) {
			trace(flag ? "OK @19" : "FAIL");
		});
#if (flash || js)
		haxe.Timer.delay(function() async(), DELAY);
#else
		async();
#end
		handler.execute();
	}

	// @15
	public function testEvent() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var value    = "";
		var expected = "haxe";
		var async = handler.addEvent(function(s) {
			trace(s == expected ? "OK @20" : "FAIL");
			value = s;
		}, TIMEOUT*2);
		handler.onTimeout.add(function(h) {
			trace("TIMEOUT");
		});
		handler.onTested.add(function(h) {
			trace(value == expected ? "OK @21" : "FAIL");
		});
#if (flash || js)
		haxe.Timer.delay(function() async(expected), DELAY);
#else
		async(expected);
#end
		handler.execute();
	}

	// @16
	public function testMultipleAsync() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var value = "";
		var async1 = handler.addAsync(function() {
			value += "1";
		}, TIMEOUT*4);
		var async2 = handler.addAsync(function() {
			value += "2";
		}, TIMEOUT*2);
		handler.onTimeout.add(function(h) {
			trace("TIMEOUT");
		});
		handler.onTested.add(function(h) {
			trace(value == "12" ? "OK @22" : "FAIL");
		});
#if (flash || js)
		haxe.Timer.delay(function() async2(), TIMEOUT*2);
		async1();
#else
		async1();
		async2();
#end
		handler.execute();
	}

	// @17
	public function testAsyncRunTwice() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var value = 0;
		var async = handler.addAsync(function() {
			value++;
		}, TIMEOUT*2);
		handler.onTimeout.add(function(h) {
			trace("TIMEOUT");
		});
		handler.onTested.add(function(h) {
			trace(value == 1 ? "OK @23" : "FAIL");
		});
		async();
		async();
		handler.execute();
	}

	// @18
	public function testAsyncRunTwiceGeneratesError() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var value = 0;
		var async = handler.addAsync(function() { }, TIMEOUT*2);
		handler.onTimeout.add(function(h) {
			trace("TIMEOUT");
		});
		handler.onTested.add(function(h) {
			switch(handler.results.pop()) {
				case AsyncError(_, _):
					trace("OK @24");
				default:
					trace("FAIL");
			}
		});
		async();
		async();
		handler.execute();
	}

	// @19 I totally forgot about that
	public function testTimeoutGeneratesError() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var value = 0;
		var async = handler.addAsync(function() { }, TIMEOUT);
		handler.onTimeout.add(function(h) {
			switch(handler.results.pop()) {
				case TimeoutError(i, _):
					trace(i == 1 ? "OK @25" : "FAIL");
				default:
					trace("FAIL");
			}
		});
		handler.execute();
	}

	// @20
	public function testAsyncThrowException() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var async = handler.addAsync(function() throw "error", TIMEOUT);
		handler.onTested.add(function(h) {
			switch(handler.results.pop()) {
				case AsyncError(_, _):
					trace("OK @26");
				default:
					trace("FAIL");
			}
		});
#if (flash || js)
		haxe.Timer.delay(function() async(), DELAY);
#else
		async();
#end
		handler.execute();
	}

	// @21
	public function testEmptyTestGeneratesWarning() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		handler.execute();
		switch(handler.results.pop()) {
			case Warning(_):
				trace("OK @27");
			default:
				trace("FAIL");
		}
	}

	// @22
	public function testOnComplete() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		handler.onComplete.add(function(h) {
			trace("OK @28");
		});
		handler.execute();
	}

	// @23
	public function testOnCompleteSequence() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var value = "";
		handler.onTested.add(function(h) {
			value += "1";
		});
		handler.onTimeout.add(function(h) {
			value += "2";
		});
		handler.onComplete.add(function(h) {
			trace(value == "1" ? "OK @29" : "FAIL");
		});
		handler.execute();
	}

	// @24
	public function testOnCompleteSequenceAsyncOk() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		var async = handler.addAsync(function() {}, TIMEOUT);
		var value = "";
		handler.onTested.add(function(h) {
			value += "1";
		});
		handler.onTimeout.add(function(h) {
			value += "2";
		});
		handler.onComplete.add(function(h) {
			trace(value == "1" ? "OK @30" : "FAIL");
		});
#if (flash || js)
		haxe.Timer.delay(function() async(), DELAY);
#else
		async();
#end
		handler.execute();
	}

	// @25
	public function testOnCompleteSequenceAsyncTimeout() {
		var fixture = new TestFixture(new TestClass(), "test");
		var handler = new TestHandler(fixture);
		handler.addAsync(function() {}, DELAY);
		var value = "";
		handler.onTested.add(function(h) {
			value += "1";
		});
		handler.onTimeout.add(function(h) {
			value += "2";
		});
		handler.onComplete.add(function(h) {
			trace(value == "2" ? "OK @31" : "FAIL");
		});
		handler.execute();
	}

	// @26
	public function testTeardown() {
		var fixture = new TestFixture(new TestClass(), "test", null, "teardown");
		var handler = new TestHandler(fixture);
		handler.onTested.add(function(h) {
			trace(fixture.target.doneteardown ? "FAIL" : "OK @32");
		});
		handler.onTimeout.add(function(h) {
			trace("FAIL");
		});
		handler.onComplete.add(function(h) {
			trace(fixture.target.doneteardown ? "OK @33" : "FAIL");
		});
		handler.execute();
	}

	// @27
	public function testTeardownAsync() {
		var fixture = new TestFixture(new TestClass(), "test", null, "teardown");
		var handler = new TestHandler(fixture);
		var async = handler.addAsync(function(){}, TIMEOUT);
		handler.onTested.add(function(h) {
			trace(fixture.target.doneteardown ? "FAIL" : "OK @34");
		});
		handler.onTimeout.add(function(h) {
			trace("FAIL");
		});
		handler.onComplete.add(function(h) {
			trace(fixture.target.doneteardown ? "OK @35" : "FAIL");
		});
#if (flash || js)
		haxe.Timer.delay(function() async(), DELAY);
#else
		async();
#end
		handler.execute();
	}


	public static function main() {
		var t = new Iteration1();
		t.testTestClass();
		t.testHandlerExecute();
		t.testHandlerProtectedContext();
		t.assertTrueSuccess();
		t.assertTrueFailureNoMessage();
		t.assertTrueFailureMessage();
		t.testHandlerHasResults();
		t.testHandlerHasError();
		t.testHandlerSetup();
		t.testHandlerSetupError();
		t.testHandlerCompleteSync();
		t.testHandlerSetTimeout();
		t.testHandlerTimeout();
		t.testAsync();
		t.testEvent();
		t.testMultipleAsync();
		t.testAsyncRunTwice();
		t.testAsyncRunTwiceGeneratesError();
		t.testTimeoutGeneratesError();
		t.testAsyncThrowException();
		t.testEmptyTestGeneratesWarning();
		t.testOnComplete();
		t.testOnCompleteSequence();
		t.testOnCompleteSequenceAsyncOk();
		t.testOnCompleteSequenceAsyncTimeout();
		t.testTeardown();
		t.testTeardownAsync();
	}
}