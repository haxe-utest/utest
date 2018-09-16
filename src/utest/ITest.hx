package utest;

#if (haxe_ver < "3.4.0")
	#error 'Haxe 3.4.0 or later is required for utest.ITest'
#end

/**
 * If a method of this interface has `Null<utest.Async>` return type and it returns `null` it is treated as a synchronous method.
 * If it returns an instance of `utest.Async` it is treated as an asynchronous method and the next action will be performed
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