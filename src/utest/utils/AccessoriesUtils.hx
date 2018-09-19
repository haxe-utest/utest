package utest.utils;

import utest.TestData;

class AccessoriesUtils {
	static public function getSetupClass(accessories:Accessories):Void->Async {
		if(accessories.setupClass != null) {
			if(accessories.setupClass.method != null) {
				return function() {
					accessories.setupClass.method();
					return Async.getResolved();
				}
			} else if(accessories.setupClass.asyncMethod != null) {
				return accessories.setupClass.asyncMethod;
			}
		}
		return Async.getResolved;
	}

	static public function getSetup(accessories:Accessories):Void->Async {
		if(accessories.setup != null) {
			if(accessories.setup.method != null) {
				return function() {
					accessories.setup.method();
					return Async.getResolved();
				}
			} else if(accessories.setup.asyncMethod != null) {
				return accessories.setup.asyncMethod;
			}
		}
		return Async.getResolved;
	}

	static public function getTeardown(accessories:Accessories):Void->Async {
		if(accessories.teardown != null) {
			if(accessories.teardown.method != null) {
				return function() {
					accessories.teardown.method();
					return Async.getResolved();
				}
			} else if(accessories.teardown.asyncMethod != null) {
				return accessories.teardown.asyncMethod;
			}
		}
		return Async.getResolved;
	}

	static public function getTeardownClass(accessories:Accessories):Void->Async {
		if(accessories.teardownClass != null) {
			if(accessories.teardownClass.method != null) {
				return function() {
					accessories.teardownClass.method();
					return Async.getResolved();
				}
			} else if(accessories.teardownClass.asyncMethod != null) {
				return accessories.teardownClass.asyncMethod;
			}
		}
		return Async.getResolved;
	}
}