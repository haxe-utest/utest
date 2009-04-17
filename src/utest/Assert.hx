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

	static function getTypeName(v : Dynamic) {
		try {
			if(v == null) return null;
			if(Std.is(v, Bool)) return "Bool";
			if(Std.is(v, Int)) return "Int";
			if(Std.is(v, Float)) return "Float";
			if(Std.is(v, String)) return "String";
			var s = Type.getClassName(Type.getClass(v));
			if(s != null) return s;
			if(Reflect.isObject(v)) return "{}";
			return Type.getEnumName(Type.getEnum(v));
		} catch(e : Dynamic) {
			trace("ERROR: "+v + " (" + Type.typeof(v) + ")");
			return null;
		}
	}

	static function isIterable(v : Dynamic, isAnonym : Bool) {
		var fields = isAnonym ? Reflect.fields(v) : Type.getInstanceFields(Type.getClass(v));
		if(!Lambda.has(fields, "iterator")) return false;
		return Reflect.isFunction(Reflect.field(v, "iterator"));
	}

	static function isIterator(v : Dynamic, isAnonym : Bool) {
		var fields = isAnonym ? Reflect.fields(v) : Type.getInstanceFields(Type.getClass(v));
		if(!Lambda.has(fields, "next") || !Lambda.has(fields, "hasNext")) return false;
		return Reflect.isFunction(Reflect.field(v, "next")) && Reflect.isFunction(Reflect.field(v, "hasNext"));
	}

	static function sameAs(expected : Dynamic, value : Dynamic, status : LikeStatus) {
		var texpected = getTypeName(expected);
		var tvalue = getTypeName(value);
		var isanonym = texpected == '{}';

		if(texpected != tvalue) {
			status.error = "expected type "+texpected+" but it is " + tvalue + (status.path == '' ? '' : ' at '+status.path);
			return false;
		}

		// null
		if(expected == null) {
			if(value != null) {
				status.error = "expected null but it is " + value + (status.path == '' ? '' : ' at '+status.path);
				return false;
			}
			return true;
		}

		// bool, int, float, string
		if(Std.is(expected, Bool) || Std.is(expected, Int) || Std.is(expected, Float) || Std.is(expected, String)) {
			if(expected != value) {
				status.error = "expected "+expected+" but it is " + value + (status.path == '' ? '' : ' at '+status.path);
				return false;
			}
			return true;
		}

		// date
		if(Std.is(expected, Date)) {
			if(expected.getTime() != value.getTime()) {
				status.error = "expected "+expected+" but it is " + value + (status.path == '' ? '' : ' at '+status.path);
				return false;
			}
			return true;
		}

		// enums
		if(Type.getEnum(expected) != null) {
			if(status.recursive || status.path == '') {
				var ename = Type.enumIndex(expected);
				var vname = Type.enumIndex(value);
				if(ename != vname) {
					status.error = "expected "+ename+" constructor but is "+vname + (status.path == '' ? '' : ' at '+status.path);
					return false;
				}
				var eparams = Type.enumParameters(expected);
				var vparams = Type.enumParameters(value);
				var path = status.path;
				for(i in 0...eparams.length) {
					status.path = path == '' ? 'enum['+i+']' : path + '['+i+']';
					if(!sameAs(eparams[i], vparams[i], status))
						return false;
				}
			}
			return true;
		}

		// arrays
		if(Std.is(expected, Array)) {
			if(status.recursive || status.path == '') {
				if(expected.length != value.length) {
					status.error = "expected "+expected.length+" elements but they were "+value.length + (status.path == '' ? '' : ' at '+status.path);
					return false;
				}
				var path = status.path;
				for(i in 0...expected.length) {
					status.path = path == '' ? 'array['+i+']' : path + '['+i+']';
					if(!sameAs(expected[i], value[i], status))
						return false;
				}
			}
			return true;
		}

		// hash, inthash
		if(Std.is(expected, Hash) || Std.is(expected, IntHash)) {
			if(status.recursive || status.path == '') {
				var keys  = Lambda.array({ iterator : function() return expected.keys() });
				var vkeys = Lambda.array({ iterator : function() return value.keys() });
				if(keys.length != vkeys.length) {
					status.error = "expected "+keys.length+" keys but they were "+vkeys.length + (status.path == '' ? '' : ' at '+status.path);
					return false;
				}
				var path = status.path;
				for(key in keys) {
					status.path = path == '' ? 'hash['+key+']' : path + '['+key+']';
					if(!sameAs(expected.get(key), value.get(key), status))
						return false;
				}
			}
			return true;
		}

		// iterator
		if(isIterator(expected, isanonym)) {
			if(isanonym && !(isIterator(value, true))) {
				status.error = "expected Iterable but it is not " + (status.path == '' ? '' : ' at '+status.path);
				return false;
			}
			if(status.recursive || status.path == '') {
				var evalues = Lambda.array({ iterator : function() return expected });
				var vvalues = Lambda.array({ iterator : function() return value });
				if(evalues.length != vvalues.length) {
					status.error = "expected "+evalues.length+" values in Iterator but they were "+vvalues.length + (status.path == '' ? '' : ' at '+status.path);
					return false;
				}
				var path = status.path;
				for(i in 0...evalues.length) {
					status.path = path == '' ? 'iterator['+i+']' : path + '['+i+']';
					if(!sameAs(evalues[i], vvalues[i], status))
						return false;
				}
			}
			return true;
		}

		// iterable
		if(isIterable(expected, isanonym)) {
			if(isanonym && !(isIterable(value, true))) {
				status.error = "expected Iterator but it is not " + (status.path == '' ? '' : ' at '+status.path);
				return false;
			}
			if(status.recursive || status.path == '') {
				var evalues = Lambda.array(expected);
				var vvalues = Lambda.array(value);
				if(evalues.length != vvalues.length) {
					status.error = "expected "+evalues.length+" values in Iterable but they were "+vvalues.length + (status.path == '' ? '' : ' at '+status.path);
					return false;
				}
				var path = status.path;
				for(i in 0...evalues.length) {
					status.path = path == '' ? 'iterable['+i+']' : path + '['+i+']';
					if(!sameAs(evalues[i], vvalues[i], status))
						return false;
				}
			}
			return true;
		}

		// objects
		if(Reflect.isObject(expected)) {
			if(status.recursive || status.path == '') {
				var fields = texpected == "{}" ? Reflect.fields(expected) : Type.getInstanceFields(Type.getClass(expected));
				var path = status.path;
				for(field in fields) {
					status.path = path == '' ? field : path+'.'+field;
					if(texpected == "{}" && !Reflect.hasField(value, field)) {
						status.error = "expected field "+status.path+" does not exist in " + value;
						return false;
					}
					var e = Reflect.field(expected, field);
					if(Reflect.isFunction(e)) continue;
					var v = Reflect.field(value, field);
					if(!sameAs(e, v, status))
						return false;
				}
			}
			return true;
		}

		return throw "Unable to compare values: " +expected+" and " + value;
	}

	/**
	* Check that value is an object with the same fields and values found in expected.
	* The default behavior is to check nested objects in fields recursively.
	*/
	public static function same(expected : Dynamic, value : Dynamic, recursive : Null<Bool> = true, ?msg : String, ?pos : PosInfos) {
		var status = { recursive : recursive, path : '', error : null };
		if(sameAs(expected, value, status)) {
			Assert.isTrue(true, msg, pos);
		} else {
			Assert.fail(msg == null ? status.error : msg, pos);
		}
	}

	public static function raises(method:Void -> Void, type:Class<Dynamic>, ?msg : String , ?pos : PosInfos) {
		try {
			method();
			fail("exception of type " + type + " not raised", pos);
		} catch (ex : Dynamic) {
			isTrue(Std.is(ex, type), "expected throw of type " + type + " but was "  + ex, pos);
		}
	}

	public static function allows<T>(possibilities : Array<T>, value : T, ?msg : String , ?pos : PosInfos) {
		if(Lambda.has(possibilities, value)) {
			isTrue(true, msg, pos);
		} else {
			fail(msg == null ? "value "+value+" not found in the expected possibilities "+possibilities : msg, pos);
		}
	}

	public static function contains<T>(match : T, values : Array<T>, ?msg : String , ?pos : PosInfos) {
		if(Lambda.has(values, match)) {
			isTrue(true, msg, pos);
		} else {
			fail(msg == null ? "values "+values+" do not contain "+match: msg, pos);
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

private typedef LikeStatus = {
	recursive : Bool,
	path : String,
	error : String
};