package iterations;

import utest.Assert;

class TestClass {
	public var tested       : Bool;
	public var donesetup    : Bool;
	public var doneteardown : Bool;

	public function new() {
		tested       = false;
		doneteardown = false;
		donesetup    = false;
	}

	public function setup() {
		donesetup = true;
	}

	public function teardown() {
		doneteardown = true;
	}

	public function test() {
		tested = true;
	}

	public function throwError() {
		throw "error";
	}

	public function assertTrue() {
		Assert.isTrue(true);
	}

	public function assertAsync() {
		var async = Assert.createAsync(function() Assert.isTrue(true));
#if (flash || js)
		haxe.Timer.delay(async, 50);
#else
		async();
#end
	}
}