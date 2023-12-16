package utest.utils;

class Print {
	static public function immediately(msg:String) {
		#if sys
			Sys.print(msg);
		#elseif js
			js.Syntax.code('console.log({0})', msg);
		#else
			trace(msg);
		#end
	}

	static public function startCase(caseName:String) {
		#if UTEST_PRINT_TESTS
			immediately('Running $caseName...\n');
		#end
	}

	static public function startTest(name:String) {
		#if UTEST_PRINT_TESTS
			immediately('    $name\n');
		#end
	}
}