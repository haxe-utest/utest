package utest;

#if (haxe_ver < "3.4.0")
	#error 'Haxe 3.4.0 or later is required for utest.ITest'
#end

/**
 * Interface, which should be implemented by test cases.
 *
 */
@:autoBuild(utest.utils.TestBuilder.build())
interface ITest {
	// /**
	//  * This method is executed once before running the first test in the current class.
	//  * If return type is `Void` it is treated as synchronous method.
	//  */
	// function setupClass():Async;

	// /**
	//  * This method is executed before each test.
	//  * If return type is `Void` it is treated as synchronous method.
	//  */
	// function setup():Async;

	// /**
	//  * This method is executed after each test.
	//  * If return type is `Void` it is treated as synchronous method.
	//  */
	// function teardown():Async;

	// /**
	//  * This method is executed once after the last test in the current class is finished.
	//  * If return type is `Void` it is treated as synchronous method.
	//  */
	// function teardownClass():Async;
}