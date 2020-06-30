package utest.utils;

class Misc {
	static public inline function isOfType(v:Dynamic, t:Dynamic):Bool {
		#if (haxe_ver >= 4.1)
		return Std.isOfType(v, t);
		#else
		return Std.is(v, t);
		#end
	}
}