package utest;

class Test implements ITest {

	public function new() {}

	/**
	 * This method is executed once before running the first test in the current class
	 */
	public function setupClass():Null<Async> {
		return Async.getResolved();
	}

	/**
	 * This method is executed before each test.
	 */
	public function setup():Null<Async> {
		return Async.getResolved();
	}

	/**
	 * This method is executed after each test.
	 */
	public function teardown():Null<Async> {
		return Async.getResolved();
	}

	/**
	 * This method is executed once after the last test in the current class is finished.
	 */
	public function teardownClass():Null<Async> {
		return Async.getResolved();
	}
}