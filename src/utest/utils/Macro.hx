package utest.utils;

import haxe.macro.Compiler;
import haxe.macro.Context;

class Macro {
	macro static public function checkHaxe() {
		#if (haxe_ver < '3.4.0')
		Context.warning('UTest will stop supporting Haxe 3.3 and older in UTest 2.0.0', Context.currentPos());
		#end
		return macro {};
	}

	macro static public function importEnvSettings() {
		var env = Sys.environment();
		for (name in env.keys()) {
			if (name.indexOf('UTEST_') == 0 && !Context.defined(name))
				Compiler.define(name, env[name]);
		}
		return macro {};
	}
}
