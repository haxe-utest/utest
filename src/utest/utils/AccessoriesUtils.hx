package utest.utils;

import utest.TestData;

using utest.utils.AccessoriesUtils;

class AccessoriesUtils {
	static public function getSetupClass(accessories:Accessories):Void->Async {
		return accessories.setupClass.orStub();
	}

	static public function getSetup(accessories:Accessories):Void->Async {
		return accessories.setup.orStub();
	}

	static public function getTeardown(accessories:Accessories):Void->Async {
		return accessories.teardown.orStub();
	}

	static public function getTeardownClass(accessories:Accessories):Void->Async {
		return accessories.teardownClass.orStub();
	}

	static inline function orStub(fn:Null<Void->Async>):Void->Async {
		return fn == null ? Async.getResolved : fn;
	}
}