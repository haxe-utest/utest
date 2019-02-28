package utest;

/**
 * Test synchronous synchronous of ITest
 */
class TestSyncITest extends Test {
	var setupClassCallCount = 0;
	var setupCallCount = 0;
	var teardownCallCount = 0;
	var teardownClassCallCount = 0;

	function setupClass() {
		setupClassCallCount++;
	}

	function setup() {
		setupCallCount++;
	}

	static function testStaticMethodsShouldNotBeTested() {
		Assert.fail();
	}

	function testSync1() {
		Assert.equals(1, setupClassCallCount);
		Assert.isTrue(setupCallCount > 0);
	}

	function testSync2() {
		Assert.equals(1, setupClassCallCount);
		Assert.isTrue(setupCallCount > 0);
	}

	function teardown() {
		teardownCallCount++;
	}

	function teardownClass() {
		teardownClassCallCount++;

		if(setupClassCallCount != 1) {
			throw 'TestSyncITest: setupClassCallCount should be called one time. Actual: $setupClassCallCount.';
		}
		var testCount = #if display 0 #else  __initializeUtest__().tests.length #end;
		if(setupCallCount != testCount) {
			throw 'TestSyncITest: setupCallCount should be called once per test. Expected: $testCount, actual: $setupCallCount.';
		}
		if(teardownCallCount != testCount) {
			throw 'TestSyncITest: teardownClassCallCount should be called once per test. Expected: $testCount, actual: $teardownCallCount.';
		}
		if(teardownClassCallCount != 1) {
			throw 'TestSyncITest: teardownClassCallCount should be called one time. Actual: $teardownClassCallCount.';
		}
	}
}