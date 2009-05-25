package utest;

import utest.Assertation;
import haxe.PosInfos;

/**
* This class contains only static members used to perform assertations inside a test method.
* It's use is straight forward:
* <pre>
* public function testObvious() {
*   Assert.equals(1, 0); // fails
*   Assert.isFalse(1 == 1, "guess what?"); // fails and returns the passed message
*   Assert.isTrue(true); // successfull
* }
* </pre>
*/
class Assert {
	/**
	* A stack of results for the current testing workflow. It is used internally
	* by other classes of the utest library.
	*/
	public static var results : List<Assertation>;
	/**
	* Asserts successfully when the condition is true.
	* @param cond: The condition to test
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function isTrue(cond : Bool, msg = "true expected", ?pos : PosInfos) {
		if(results == null) throw "Assert.results is not currently bound to any assert context";
		if(cond)
			results.add(Success(pos));
		else
			results.add(Failure(msg, pos));
	}
	/**
	* Asserts successfully when the condition is false.
	* @param cond: The condition to test
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function isFalse(value : Bool, msg = "expected false but was true", ?pos : PosInfos) {
		isTrue(value == false, msg, pos);
	}
	/**
	* Asserts successfully when the value is null.
	* @param value: The value to test
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function isNull(value : Dynamic, ?msg : String, ?pos : PosInfos) {
		if(msg == null) msg = "expected null but was " + Std.string(value);
		isTrue(value == null, msg, pos);
	}
	/**
	* Asserts successfully when the value is not null.
	* @param value: The value to test
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function notNull(value : Dynamic, msg = "expected not null but was null", ?pos : PosInfos) {
		isTrue(value != null, msg, pos);
	}
	/**
	* Asserts successfully when the 'value' parameter is of the of the passed type 'type'.
	* @param value: The value to test
	* @param type: The type to test against
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function is(value : Dynamic, type : Dynamic, ?msg : String , ?pos : PosInfos) {
		if(msg == null) msg = "expected type " + Std.string(type) + " but was " + Type.typeof(value);
		isTrue(Std.is(value, type), msg, pos);
	}
	/**
	* Asserts successfully when the value parameter is equal to the expected one.
	* <pre>
	* Assert.equals(10, age);
	* </pre>
	* @param expected: The expected value to check against
	* @param value: The value to test
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function equals(expected : Dynamic, value : Dynamic, ?msg : String , ?pos : PosInfos) {
		if(msg == null) msg = "expected " + expected + " but was " + value;
		isTrue(expected == value, msg, pos);
	}

	/**
	* Same as Assert.equals but considering an approximation error.
	* <pre>
	* Assert.floatEquals(Math.PI, value);
	* </pre>
	* @param expected: The expected value to check against
	* @param value: The value to test
	* @param approx: The approximation tollerance. Default is 1e-5
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	* @todo test the approximation argument
	*/
	public static function floatEquals(expected : Float, value : Float, approx = 1e-5, ?msg : String , ?pos : PosInfos) {
		if(msg == null) msg = "expected " + expected + " but was " + value;
		isTrue(Math.abs(value-expected) < approx, msg, pos);
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
	* <pre>
	* Assert.same({ name : "utest"}, ob);
	* </pre>
	* @param expected: The expected value to check against
	* @param value: The value to test
	* @param recursive: States whether or not the test will apply also to sub-objects.
	* Defaults to true
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function same(expected : Dynamic, value : Dynamic, recursive : Null<Bool> = true, ?msg : String, ?pos : PosInfos) {
		var status = { recursive : recursive, path : '', error : null };
		if(sameAs(expected, value, status)) {
			Assert.isTrue(true, msg, pos);
		} else {
			Assert.fail(msg == null ? status.error : msg, pos);
		}
	}

	/**
	* It is used to test an application that under certain circumstances must
	* react throwing an error. This assert guarantees that the error is of the
	* correct type (or Dynamic if non is specified).
	* <pre>
	* Assert.raises(function() { throw "Error!"; }, String);
	* </pre>
	* @param method: A method that generates the exception.
	* @param type: The type of the expected error. Defaults to Dynamic (catch all).
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	* @todo test the optional type parameter
	*/
	public static function raises(method:Void -> Void, ?type:Class<Dynamic>, ?msg : String , ?pos : PosInfos) {
		if(type == null)
			type = String;
		try {
			method();
			var name = Type.getClassName(type);
			if (name == null) name = ""+type;
			fail("exception of type " + name + " not raised", pos);
		} catch (ex : Dynamic) {
			var name = Type.getClassName(type);
			if (name == null) name = ""+type;
			isTrue(Std.is(ex, type), "expected throw of type " + name + " but was "  + ex, pos);
		}
	}
	/**
	* Checks that the test value matches at least one of the possibilities.
	* @param possibility: An array of mossible matches
	* @param value: The value to test
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function allows<T>(possibilities : Array<T>, value : T, ?msg : String , ?pos : PosInfos) {
		if(Lambda.has(possibilities, value)) {
			isTrue(true, msg, pos);
		} else {
			fail(msg == null ? "value "+value+" not found in the expected possibilities "+possibilities : msg, pos);
		}
	}
	/**
	* Checks that the test array contains the match parameter.
	* @param match: The element that must be included in the tested array
	* @param values: The values to test
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function contains<T>(match : T, values : Array<T>, ?msg : String , ?pos : PosInfos) {
		if(Lambda.has(values, match)) {
			isTrue(true, msg, pos);
		} else {
			fail(msg == null ? "values "+values+" do not contain "+match: msg, pos);
		}
	}
	/**
	* Forces a failure.
	* @param msg: An optional error message. If not passed a default one will be used
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function fail(msg = "failure expected", ?pos : PosInfos) {
		isTrue(false, msg, pos);
	}
	/**
	* Creates a warning message.
	* @param msg: A mandatory message that justifies the warning.
	* @param pos: Code position where the Assert call has been executed. Don't fill it
	* unless you know what you are doing.
	*/
	public static function warn(msg) {
		results.add(Warning(msg));
	}

	/**
	* Creates an asynchronous context for test execution. Assertions should be included
	* in the passed function.
	* <pre>
	* public function assertAsync() {
	*   var async = Assert.createAsync(function() Assert.isTrue(true));
	*   haxe.Timer.delay(async, 50);
	* }
	* @param f: A function that contains other Assert tests
	* @param timeout: Optional timeout value in milliseconds.
	*/
	public static dynamic function createAsync(f : Void->Void, ?timeout : Int) {
		return function(){};
	}
	/**
	* Creates an asynchronous context for test execution of an event like method.
	* Assertions should be included in the passed function.
	* It works the same way as Assert.assertAsync() but accepts a function with one
	* argument (usually some event data) instead of a function with no arguments
	* @param f: A function that contains other Assert tests
	* @param timeout: Optional timeout value in milliseconds.
	*/
	public static dynamic function createEvent<EventArg>(f : EventArg->Void, ?timeout : Int) {
		return function(e){};
	}
}

private typedef LikeStatus = {
	recursive : Bool,
	path : String,
	error : String
};