package utest;

/**
 * The data of a test as collected by utest.utils.TestBuilder at compile time.
 */
typedef TestData = {
	var name(default,null):String;
	var execute(default,null):Void->Void;
	@:optional var async(default,null):Async;
}