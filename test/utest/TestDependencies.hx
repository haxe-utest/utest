package utest;

class TestDependencies extends Test {
	var executedTests:Array<String> = [];

	function test1() {
		executedTests.push('test1');
		Assert.pass();
	}

	@:depends(test3)
	function test2() {
		executedTests.push('test2');
		Assert.pass();
	}

	@:depends(test1)
	function test3() {
		executedTests.push('test3');
		Assert.pass();
	}

	@:depends(test3, test2)
	function test4() {
		executedTests.push('test4');
		Assert.pass();
	}

	@:depends(test1, test2, test3, test4)
	function testExecutionOrderIsCorrect() {
		Assert.same(['test1', 'test3', 'test2', 'test4'], executedTests);
	}
}