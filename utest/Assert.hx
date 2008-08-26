package utest;

import utest.Assertation;
import haxe.PosInfos;

class Assert {
	public static var results : List<Assertation>;
	public static function isTrue(cond : Bool, msg = "true expected", ?pos : PosInfos) {
		if(results == null) throw "Assert.results is not currently bound to any assert context";
		if(cond)
			results.add(Success(pos));
		else
			results.add(Failure(msg, pos));
	}

	public static function isFalse(value : Bool, msg = "expected false but was true", ?pos : PosInfos) {
		isTrue(value == false, msg, pos);
	}

	public static function isNull(value : Dynamic, msg = "expected null but was not null", ?pos : PosInfos) {
		isTrue(value == null, msg, pos);
	}

	public static function notNull(value : Dynamic, msg = "expected not null but was null", ?pos : PosInfos) {
		isTrue(value != null, msg, pos);
	}

	public static function is(value : Dynamic, type : Dynamic, ?msg : String , ?pos : PosInfos) {
		if(msg == null) msg = "expected type " + Std.string(type) + " but was " + Type.typeof(value);
		isTrue(Std.is(value, type), msg, pos);
	}

	public static function equals(expected : Dynamic, value : Dynamic, ?msg : String , ?pos : PosInfos) {
		if(msg == null) msg = "expected " + expected + " but was " + value;
		isTrue(expected == value, msg, pos);
	}

	public static function floatEquals(expected : Float, value : Float, ?msg : String , ?pos : PosInfos) {
		if(msg == null) msg = "expected " + expected + " but was " + value;
		isTrue(Math.abs(value-expected) < 1e-5, msg, pos);
	}

	public static function raises(method:Void -> Void, type:Class<Dynamic>, ?msg : String , ?pos : PosInfos) {
		try {
			method();
			fail("exception of type " + type + " not raised", pos);
		} catch (ex : Dynamic) {
			isTrue(Std.is(ex, type), "expected throw of type " + type + " but was "  + ex, pos);
		}
	}

	public static function fail(msg = "failure expected", ?pos : PosInfos) {
		isTrue(false, msg, pos);
	}

	public static dynamic function createAsync(f : Void->Void, ?timeout : Int) {
		return function(){};
	}
	public static dynamic function createEvent<EventArg>(f : EventArg->Void, ?timeout : Int) {
		return function(e){};
	}
}