package utest;

/**
 * If a method of this interface has `Null<utest.Async>` return type and it returns `null` it is treated as synchronous.
 * If it returns an instance of `utest.Async` it is treated as asynchronous and the next action will be performed
 * only after the method `done()` of that instance is executed.
 */
@:autoBuild(utest.utils.TestBuilder.build())
interface ITest {
	/**
	 * This method is executed once before running the first test in the current class
	 */
	function setupClass():Null<Async>;

	/**
	 * This method is executed before each test.
	 */
	function setup():Null<Async>;

	/**
	 * This method is executed after each test.
	 */
	function teardown():Null<Async>;

	/**
	 * This method is executed once after the last test in the current class is finished.
	 */
	function teardownClass():Null<Async>;
}