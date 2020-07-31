package utest;

/**
 * The data of a test as collected by utest.utils.TestBuilder at compile time.
 */
typedef TestData = {
	var name(default,null):String;
	var dependencies(default,null):Array<String>;
	var execute(default,null):Void->Async;
}

/**
 * The data of accessory methods: setup, setupClass, teardown, teardownClass
 */
typedef Accessories = {
	?setup:Void->Async,
	?setupClass:Void->Async,
	?teardown:Void->Async,
	?teardownClass:Void->Async,
}

typedef InitializeUtest = {
	accessories:Accessories,
	dependencies:Array<String>,
	tests:Array<TestData>
}

typedef Initializer = {
	function __initializeUtest__():InitializeUtest;
}

class AccessoryName {
	/**
	 * This method is executed once before running the first test in the current class
	 */
	static public inline var SETUP_NAME = 'setup';
	/**
	 * This method is executed before each test.
	 */
	static public inline var SETUP_CLASS_NAME = 'setupClass';
	/**
	 * This method is executed after each test.
	 */
	static public inline var TEARDOWN_NAME = 'teardown';
	/**
	 * This method is executed once after the last test in the current class is finished.
	 */
	static public inline var TEARDOWN_CLASS_NAME = 'teardownClass';
}