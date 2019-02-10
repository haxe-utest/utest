package utest;

#if (haxe_ver < "3.4.0")
	#error 'Haxe 3.4.0 or later is required for utest.ITest'
#end

/**
 * Interface, which should be implemented by test cases.
 *
 */
#if !macro
@:autoBuild(utest.utils.TestBuilder.build())
#end
interface ITest {
	// /**
	//  * This method is executed once before running the first test in the current class.
	//  * If it accepts an argument, it is treated as an asynchronous method.
	//  */
	// function setupClass():Void;
	// function setupClass(async:Async):Void;

	// /**
	//  * This method is executed before each test.
	//  * If it accepts an argument, it is treated as an asynchronous method.
	//  */
	// function setup():Void;
	// function setup(async:Async):Void;

	// /**
	//  * This method is executed after each test.
	//  * If it accepts an argument, it is treated as an asynchronous method.
	//  */
	// function teardown():Void;
	// function teardown(async:Async):Void;

	// /**
	//  * This method is executed once after the last test in the current class is finished.
	//  * If it accepts an argument, it is treated as an asynchronous method.
	//  */
	// function teardownClass():Void;
	// function teardownClass(async:Async):Void;
}
