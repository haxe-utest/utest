package utest.utils;

class AsyncUtils {
	static public inline function orResolved(async:Null<Async>):Async {
		return async == null ? Async.getResolved() : async;
	}
}