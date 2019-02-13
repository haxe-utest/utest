package utest;

class TestWithMacro extends Test {
	public function testMacro() {
		Macro.dummyMacro();
		Assert.pass();
	}
}

private class Macro {
	macro static public function dummyMacro() return macro {}
}