package utest.utils;

import utest.TestData;

using utest.utils.AccessoriesUtils;

class AccessoriesUtils {
	static public function getSetupClass(accessories:Accessories):()->Async {
		return accessories.setupClass == null ? Async.getResolved : accessories.setupClass;
	}

	static public function getSetup(accessories:Accessories):()->Async {
		return accessories.setup == null ? Async.getResolved : accessories.setup;
	}

	static public function getTeardown(accessories:Accessories):()->Async {
		return accessories.teardown == null ? Async.getResolved : accessories.teardown;
	}

	static public function getTeardownClass(accessories:Accessories):()->Async {
		return accessories.teardownClass == null ? Async.getResolved : accessories.teardownClass;
	}
}