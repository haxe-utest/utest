package utest.utils;

import haxe.macro.Context;

class Macro {
	macro static public function checkHaxe() {
		#if (haxe_ver < '3.4.0')
		Context.warning('UTest will stop supporting Haxe 3.3 and older in UTest 2.0.0', Context.currentPos());
		#end
		return macro {}
	}
}