package utest;

class TestCaseDependencies {
	static public var caseExecutionOrder:Array<String> = [];
}

class Case1 extends Test {
	function test() {
		TestCaseDependencies.caseExecutionOrder.push('Case1');
		Assert.pass();
	}
}

@:depends(utest.Case3)
class Case2 extends Test {
	function test() {
		TestCaseDependencies.caseExecutionOrder.push('Case2');
		Assert.pass();
	}
}

@:depends(utest.Case1)
class Case3 extends Test {
	function test() {
		TestCaseDependencies.caseExecutionOrder.push('Case3');
		Assert.pass();
	}
}

@:depends(utest.Case3, utest.Case2)
class Case4 extends Test {
	function test() {
		TestCaseDependencies.caseExecutionOrder.push('Case4');
		Assert.pass();
	}
}