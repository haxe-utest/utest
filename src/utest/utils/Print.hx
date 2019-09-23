package utest.utils;

class Print {
	static public function immediately(msg:String) {
		#if sys
			Sys.print(msg);
		#elseif js
			untyped __js__('console.log({0})', msg);
		#else
			trace(msg)
		#end
	}

	static public function startCase(caseName:Dynamic) {
		#if UTEST_PRINT_TESTS
			immediately('Running $caseName...\n');
		#end
	}

	static public function startTest(name) {
		#if UTEST_PRINT_TESTS
			immediately('    $name\n');
		#end
	}
}