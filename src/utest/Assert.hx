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

	public static function isNull(value : Dynamic, ?msg : String, ?pos : PosInfos) {
		if(msg == null) msg = "expected null but was " + Std.string(value);
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

	/**
	* Check that value is an object and contains at least the same fields and values found in expcted.
	* The default behavior is to check nested objects in fields recursively.
	*/
	public static function like(expected : Dynamic, value : Dynamic, recursive = true, ?path = '', ?msg : String, ?pos : PosInfos) {
		if(expected == null && value == null) {
			isTrue(true, msg, pos);
			return;
		}
		var fields = Reflect.fields(expected);
		for(field in fields) {
			if(!Reflect.hasField(value, field)) {
				Assert.fail("value doesn't have the expected field '"+path+field+"'");
				return;
			}
			var e = Reflect.field(expected, field);
			var v = Reflect.field(value, field);
			if(Reflect.isObject(e) && recursive) {
				like(e, v, true, field+'.', msg, pos);
			} else {
				if(e != v) {
					Assert.fail("the expected value for the field '"+path+field+"' was '"+e+"' but it is '"+v+"'");
					return;
				}
			}
		}
		Assert.isTrue(true, msg, pos);
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

	public static function warn(msg) {
		results.add(Warning(msg));
	}

	public static dynamic function createAsync(f : Void->Void, ?timeout : Int) {
		return function(){};
	}
	public static dynamic function createEvent<EventArg>(f : EventArg->Void, ?timeout : Int) {
		return function(e){};
	}
}