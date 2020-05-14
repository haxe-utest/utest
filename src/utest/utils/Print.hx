package utest.utils;

class Print {
	static public function immediately(msg:String) {
		#if sys
			Sys.print(msg);
		#elseif js
			#if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end('console.log({0})', msg);
		#else
			trace(msg);
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