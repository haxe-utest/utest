package utest.utils;

import haxe.macro.Compiler;
import haxe.macro.Context;

class Macro {
	macro static public function importEnvSettings() {
		var env = Sys.environment();
		for (name in env.keys()) {
			if (name.indexOf('UTEST_') == 0 && !Context.defined(name))
				Compiler.define(name, env[name]);
		}
		return macro {};
	}
}
