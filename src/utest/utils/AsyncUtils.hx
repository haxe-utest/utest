package utest.utils;

class AsyncUtils {
	static public inline function orResolved(_async:Null<Async>):Async {
		return _async == null ? Async.getResolved() : _async;
	}
}