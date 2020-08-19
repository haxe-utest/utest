package utest;

import utest.utils.Misc;
import haxe.io.Bytes;
import utest.Assertation;
import haxe.PosInfos;
import Map;
import haxe.Constraints;

/**
 * This class contains only static members used to perform assertations inside a test method.
 * Its use is straight forward:
 * ```haxe
 * public function testObvious() {
 *   Assert.equals(1, 0); // fails
 *   Assert.isFalse(1 == 1, "guess what?"); // fails and returns the passed message
 *   Assert.isTrue(true); // successful
 * }
 * ```
 * Each method returns `true` if assertion holds or `false` if assertion fails.
 */
class Assert {
  /**
   * A stack of results for the current testing workflow. It is used internally
   * by other classes of the utest library.
   */
  public static var results : List<Assertation>;

  static inline function processResult(cond : Bool, getMessage : Void -> String, ?pos : PosInfos) : Bool {
    if (results == null) {
      throw 'Assert at ${pos.fileName}:${pos.lineNumber} out of context. Most likely you are trying to assert after a test timeout.';
    }
    if(cond)
      results.add(Success(pos));
    else {
      #if UTEST_FAILURE_THROW
      throw '${pos.fileName}:${pos.lineNumber}: ${getMessage()}';
      #else
      results.add(Failure(getMessage(), pos));
      #end
    }
	return cond;
  }

  /**
   * Asserts successfully when the condition is true.
   * @param cond The condition to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function isTrue(cond : Bool, ?msg : String, ?pos : PosInfos) : Bool {
    return processResult(cond, function() return msg != null ? msg : "expected true", pos);
  }

  /**
   * Asserts successfully when the condition is false.
   * @param cond The condition to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function isFalse(value : Bool, ?msg : String, ?pos : PosInfos) : Bool {
    return processResult(value == false, function() return msg != null ? msg : "expected false", pos);
  }

  /**
   * Asserts successfully when the value is null.
   * @param value The value to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function isNull(value : Dynamic, ?msg : String, ?pos : PosInfos) : Bool {
    return processResult(value == null, function() return msg != null ? msg : "expected null but it is " + q(value), pos);
  }

  /**
   * Asserts successfully when the value is not null.
   * @param value The value to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function notNull(value : Dynamic, ?msg : String, ?pos : PosInfos) : Bool {
    return processResult(value != null, function() return msg != null ? msg : "expected not null", pos);
  }

  /**
   * Asserts successfully when the 'value' parameter is of the of the passed type 'type'.
   * @param value The value to test
   * @param type The type to test against
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  @:deprecated("utest.Assert.is is deprecated. Use utest.Assert.isOfType instead.")
  public static function is(value : Dynamic, type : Dynamic, ?msg : String , ?pos : PosInfos) : Bool {
    return isOfType(value, type, msg, pos);
  }

  /**
   * Asserts successfully when the 'value' parameter is of the of the passed type 'type'.
   * @param value The value to test
   * @param type The type to test against
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function isOfType(value : Dynamic, type : Dynamic, ?msg : String , ?pos : PosInfos) : Bool {
    return processResult(Misc.isOfType(value, type), function() return msg != null ? msg : "expected type " + typeToString(type) + " but it is " + typeToString(value), pos);
  }

  /**
   * Asserts successfully when the value parameter is not the same as the expected one.
   * ```haxe
   * Assert.notEquals(10, age);
   * ```
   * @param expected The expected value to check against
   * @param value The value to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function notEquals(expected : Dynamic, value : Dynamic, ?msg : String , ?pos : PosInfos) : Bool {
    return processResult(expected != value, function() return msg != null ? msg : "expected " + q(expected) + " and test value " + q(value) + " should be different", pos);
  }

  /**
   * Asserts successfully when the value parameter is equal to the expected one.
   * ```haxe
   * Assert.equals(10, age);
   * ```
   * @param expected The expected value to check against
   * @param value The value to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function equals(expected : Dynamic, value : Dynamic, ?msg : String , ?pos : PosInfos) : Bool {
    return processResult(expected == value, function() return msg != null ? msg : "expected " + q(expected) + " but it is " + q(value), pos);
  }

  /**
   * Asserts successfully when the value parameter does match against the passed EReg instance.
   * ```haxe
   * Assert.match(~/x/i, "haXe");
   * ```
   * @param pattern The pattern to match against
   * @param value The value to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function match(pattern : EReg, value : Dynamic, ?msg : String , ?pos : PosInfos) : Bool {
    return processResult(pattern.match(value), function() return msg != null ? msg : "the value " + q(value) + " does not match the provided pattern", pos);
  }

  /**
   * Same as Assert.equals but considering an approximation error.
   * ```haxe
   * Assert.floatEquals(Math.PI, value);
   * ```
   * @param expected The expected value to check against
   * @param value The value to test
   * @param approx The approximation tollerance. Default is 1e-5
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   * @todo test the approximation argument
   */
  public static function floatEquals(expected : Float, value : Float, ?approx : Float, ?msg : String , ?pos : PosInfos) : Bool{
    return processResult(_floatEquals(expected, value, approx), function() return msg != null ? msg : "expected " + q(expected) + " but it is " + q(value), pos);
  }

  static function _floatEquals(expected : Float, value : Float, ?approx : Float)
  {
    if (Math.isNaN(expected))
      return Math.isNaN(value);
    else if (Math.isNaN(value))
      return false;
    else if (!Math.isFinite(expected) && !Math.isFinite(value))
      return (expected > 0) == (value > 0);
    if (null == approx)
      approx = 1e-5;
    return Math.abs(value-expected) <= approx;
  }

  static function getTypeName(v : Dynamic) {
    switch(Type.typeof(v))
    {
      case TNull    : return "`null`";
      case TInt     : return "Int";
      case TFloat   : return "Float";
      case TBool    : return "Bool";
      case TFunction: return "function";
      case TClass(c): return Type.getClassName(c);
      case TEnum(e) : return Type.getEnumName(e);
      case TObject  : return "Object";
      case TUnknown : return "`Unknown`";
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

  static function sameAs(expected : Dynamic, value : Dynamic, status : LikeStatus, approx : Float) {
    var texpected = getTypeName(expected);
    var tvalue = getTypeName(value);
    status.expectedValue = expected;
    status.actualValue = value;

    if(texpected != tvalue && !((texpected == "Int" && tvalue == "Float") || (texpected == "Float" && tvalue == "Int"))) { //Int and Float are treated as same so that an int and float comaparison will use floatEquals

      status.error = "expected type " + texpected + " but it is " + tvalue + (status.path == '' ? '' : ' for field ' + status.path);
      return false;
    }
    switch(Type.typeof(expected))
    {
      case TFloat, TInt:
        if (!_floatEquals(expected, value, approx))
        {
          status.error = "expected " + q(expected) + " but it is " + q(value) + (status.path == '' ? '' : ' for field '+status.path);
          return false;
        }
        return true;
      case TNull, TBool:
        if(expected != value) {
          status.error = "expected " + q(expected) + " but it is " + q(value) + (status.path == '' ? '' : ' for field '+status.path);
          return false;
        }
        return true;
      case TFunction:
        if (!Reflect.compareMethods(expected, value))
        {
          status.error = "expected same function reference" + (status.path == '' ? '' : ' for field '+status.path);
          return false;
        }
        return true;
      case TClass(c):
        var cexpected = Type.getClassName(c);
        var cvalue = Type.getClassName(Type.getClass(value));
#if cpp
        if (cexpected == 'cpp::Pointer') {
          return expected == value;
        }
#end
        if (cexpected != cvalue)
        {
          status.error = "expected instance of " + q(cexpected) + " but it is " + q(cvalue) + (status.path == '' ? '' : ' for field '+status.path);
          return false;
        }

        // string
        if (Misc.isOfType(expected, String)) {
          if(expected == value)
            return true;
          else {
            status.error = "expected string '" + expected + "' but it is '" + value + "'";
            return false;
          }
        }

        // arrays
        if(Misc.isOfType(expected, Array)) {
          if(status.recursive || status.path == '') {
            if(expected.length != value.length) {
              status.error = "expected "+expected.length+" elements but they are "+value.length + (status.path == '' ? '' : ' for field '+status.path);
              return false;
            }
            var path = status.path;
            for(i in 0...expected.length) {
              status.path = path == '' ? 'array['+i+']' : path + '['+i+']';
              if (!sameAs(expected[i], value[i], status, approx))
              {
                status.error = "expected array element at ["+i+"] to have " + q(status.expectedValue) + " but it is " + q(status.actualValue) + (status.path == '' ? '' : ' for field '+status.path);
                return false;
              }
            }
          }
          return true;
        }

        // date
        if(Misc.isOfType(expected, Date)) {
          if(expected.getTime() != value.getTime()) {
            status.error = "expected " + q(expected) + " but it is " + q(value) + (status.path == '' ? '' : ' for field '+status.path);
            return false;
          }
          return true;
        }

        // bytes
        if(Misc.isOfType(expected, Bytes)) {
          if(status.recursive || status.path == '') {
            var ebytes : Bytes = expected;
            var vbytes : Bytes = value;
            if (ebytes.length != vbytes.length) {
              status.error = "expected " + ebytes.length + " bytes length but it is " + vbytes.length;
              return false;
            }
            for (i in 0...ebytes.length)
              if (ebytes.get(i) != vbytes.get(i))
              {
                status.error = "expected byte #" + i + " to be " + ebytes.get(i) + " but it is " + vbytes.get(i) + (status.path == '' ? '' : ' for field '+status.path);
                return false;
              }
          }
          return true;
        }

        // hash, inthash
        if (Misc.isOfType(expected, IMap)) {
          if(status.recursive || status.path == '') {
            var map = cast(expected, IMap<Dynamic, Dynamic>);
            var vmap = cast(value, IMap<Dynamic, Dynamic>);
            var keys:Array<Dynamic> = [for (k in map.keys()) k];
            var vkeys:Array<Dynamic> = [for (k in vmap.keys()) k];

            if(keys.length != vkeys.length) {
              status.error = "expected "+keys.length+" keys but they are "+vkeys.length + (status.path == '' ? '' : ' for field '+status.path);
              return false;
            }
            var path = status.path;
            for(key in keys) {
              status.path = path == '' ? 'hash['+key+']' : path + '['+key+']';
              if (!sameAs(map.get(key), vmap.get(key), status, approx))
              {
                status.error = "expected " + q(status.expectedValue) + " but it is " + q(status.actualValue) + (status.path == '' ? '' : ' for field '+status.path);
                return false;
              }
            }
          }
          return true;
        }

        // iterator
        if(isIterator(expected, false)) {
          if(status.recursive || status.path == '') {
            var evalues = Lambda.array({ iterator : function() return expected });
            var vvalues = Lambda.array({ iterator : function() return value });
            if(evalues.length != vvalues.length) {
              status.error = "expected "+evalues.length+" values in Iterator but they are "+vvalues.length + (status.path == '' ? '' : ' for field '+status.path);
              return false;
            }
            var path = status.path;
            for(i in 0...evalues.length) {
              status.path = path == '' ? 'iterator['+i+']' : path + '['+i+']';
              if (!sameAs(evalues[i], vvalues[i], status, approx))
              {
                status.error = "expected " + q(status.expectedValue) + " but it is " + q(status.actualValue) + (status.path == '' ? '' : ' for field '+status.path);
                return false;
              }
            }
          }
          return true;
        }

        // iterable
        if(isIterable(expected, false)) {
          if(status.recursive || status.path == '') {
            var evalues = Lambda.array(expected);
            var vvalues = Lambda.array(value);
            if(evalues.length != vvalues.length) {
              status.error = "expected "+evalues.length+" values in Iterable but they are "+vvalues.length + (status.path == '' ? '' : ' for field '+status.path);
              return false;
            }
            var path = status.path;
            for(i in 0...evalues.length) {
              status.path = path == '' ? 'iterable['+i+']' : path + '['+i+']';
              if(!sameAs(evalues[i], vvalues[i], status, approx))
                return false;
            }
          }
          return true;
        }

        // custom class
        if(status.recursive || status.path == '') {
          var fields = Type.getInstanceFields(Type.getClass(expected));
          var path = status.path;
          for(field in fields) {
            status.path = path == '' ? field : path+'.'+field;
            var e = Reflect.field(expected, field);
            if(Reflect.isFunction(e)) continue;
            var v = Reflect.field(value, field);
            if(!sameAs(e, v, status, approx))
              return false;
          }
        }

        return true;
      case TEnum(e) :
        var eexpected = Type.getEnumName(e);
        var evalue = Type.getEnumName(Type.getEnum(value));
        if (eexpected != evalue)
        {
          status.error = "expected enumeration of " + q(eexpected) + " but it is " + q(evalue) + (status.path == '' ? '' : ' for field '+status.path);
          return false;
        }
        if (status.recursive || status.path == '')
        {
          if (Type.enumIndex(expected) != Type.enumIndex(value))
          {
            status.error = 'expected enum constructor ' + q(Type.enumConstructor(expected)) + ' but it is ' + q(Type.enumConstructor(value)) + (status.path == '' ? '' : ' for field '+status.path);
            return false;
          }
          var eparams = Type.enumParameters(expected);
          var vparams = Type.enumParameters(value);
          var path = status.path;
          for (i in 0...eparams.length)
          {
            status.path = path == '' ? 'enum[' + i + ']' : path + '[' + i + ']';
            if (!sameAs(eparams[i], vparams[i], status, approx))
            {
              status.error = "expected enum param " + q(expected) + " but it is " + q(value) + (status.path == '' ? '' : ' for field ' + status.path) + ' with ' + status.error;
              return false;
            }
          }
        }
        return true;
      case TObject  :
        // anonymous object
        if(status.recursive || status.path == '') {
          var tfields = Reflect.fields(value);
          var fields = Reflect.fields(expected);
          var path = status.path;
          for(field in fields) {
            tfields.remove(field);
            status.path = path == '' ? field : path+'.'+field;
            if(!Reflect.hasField(value, field)) {
              status.error = "expected field " + status.path + " does not exist in " + q(value);
              return false;
            }
            var e = Reflect.field(expected, field);
            if(Reflect.isFunction(e))
              continue;
            var v = Reflect.field(value, field);
            if(!sameAs(e, v, status, approx))
              return false;
          }
          if(tfields.length > 0)
          {
            status.error = "the tested object has extra field(s) (" + tfields.join(", ") + ") not included in the expected ones";
            return false;
          }
        }

        // iterator
        if(isIterator(expected, true)) {
          if(!(isIterator(value, true))) {
            status.error = "expected Iterable but it is not " + (status.path == '' ? '' : ' for field '+status.path);
            return false;
          }
          if(status.recursive || status.path == '') {
            var evalues = Lambda.array({ iterator : function() return expected });
            var vvalues = Lambda.array({ iterator : function() return value });
            if(evalues.length != vvalues.length) {
              status.error = "expected "+evalues.length+" values in Iterator but they are "+vvalues.length + (status.path == '' ? '' : ' for field '+status.path);
              return false;
            }
            var path = status.path;
            for(i in 0...evalues.length) {
              status.path = path == '' ? 'iterator['+i+']' : path + '['+i+']';
              if (!sameAs(evalues[i], vvalues[i], status, approx))
              {
                status.error = "expected " + q(status.expectedValue) + " but it is " + q(status.actualValue) + (status.path == '' ? '' : ' for field '+status.path);
                return false;
              }
            }
          }
          return true;
        }

        // iterable
        if(isIterable(expected, true)) {
          if(!(isIterable(value, true))) {
            status.error = "expected Iterator but it is not " + (status.path == '' ? '' : ' for field '+status.path);
            return false;
          }
          if(status.recursive || status.path == '') {
            var evalues = Lambda.array(expected);
            var vvalues = Lambda.array(value);
            if(evalues.length != vvalues.length) {
              status.error = "expected "+evalues.length+" values in Iterable but they are "+vvalues.length + (status.path == '' ? '' : ' for field '+status.path);
              return false;
            }
            var path = status.path;
            for(i in 0...evalues.length) {
              status.path = path == '' ? 'iterable['+i+']' : path + '['+i+']';
              if(!sameAs(evalues[i], vvalues[i], status, approx))
                return false;
            }
          }
          return true;
        }
        return true;
      case TUnknown :
        return throw "Unable to compare two unknown types";
    }
    return throw "Unable to compare values: " + q(expected) + " and " + q(value);
  }

  static function q(v : Dynamic)
  {
    if (Misc.isOfType(v, String))
      return '"' + StringTools.replace(v, '"', '\\"') + '"';
    else
      return Std.string(v);
  }

  /**
   * Check that value is an object with the same fields and values found in expected.
   * The default behavior is to check nested objects in fields recursively.
   * ```haxe
   * Assert.same({ name : "utest"}, ob);
   * ```
   * @param expected The expected value to check against
   * @param value The value to test
   * @param recursive States whether or not the test will apply also to sub-objects.
   * Defaults to true
   * @param msg An optional error message. If not passed a default one will be used
   * @param approx The approximation tollerance. Default is 1e-5
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function same(expected : Dynamic, value : Dynamic, ?recursive : Bool, ?msg : String, ?approx : Float,  ?pos : PosInfos) : Bool {
    if (null == approx)
      approx = 1e-5;
    var status = {
      recursive : null == recursive ? true : recursive,
      path : '',
      error : null,
      expectedValue : expected,
      actualValue : value
    };
    return if(sameAs(expected, value, status, approx)) {
      pass(msg, pos);
    } else {
      fail(msg == null ? status.error : msg, pos);
    }
  }

  /**
   * It is used to test an application that under certain circumstances must
   * react throwing an error. This assert guarantees that the error is of the
   * correct type (or Dynamic if non is specified).
   * ```haxe
   * Assert.raises(function() { throw "Error!"; }, String);
   * ```
   * @param method A method that generates the exception.
   * @param type The type of the expected error. Defaults to Dynamic (catch all).
   * @param msgNotThrown An optional error message used when the function fails to raise the expected
   *      exception. If not passed a default one will be used
   * @param msgWrongType An optional error message used when the function raises the exception but it is
   *      of a different type than the one expected. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function raises(method:Void -> Void, ?type:Class<Dynamic>, ?msgNotThrown : String , ?msgWrongType : String, ?pos : PosInfos) : Bool {
    var name = type != null ? Type.getClassName(type) : "Dynamic";
    try {
      method();
    } catch (ex : Dynamic) {
      return if(null == type) {
        pass(pos);
      } else {
        if (null == msgWrongType)
          msgWrongType = "expected throw of type " + name + " but it is "  + ex;
        isTrue(Misc.isOfType(ex, type), msgWrongType, pos);
      }
    }
    if (null == msgNotThrown)
      msgNotThrown = "exception of type " + name + " not raised";
    return fail(msgNotThrown, pos);
  }

  /**
   * Checks that the test value matches at least one of the possibilities.
   * @param possibility An array of possible matches
   * @param value The value to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function allows<T>(possibilities : Array<T>, value : T, ?msg : String , ?pos : PosInfos) : Bool {
    return if(Lambda.has(possibilities, value)) {
      isTrue(true, msg, pos);
    } else {
      fail(msg == null ? "value " + q(value) + " not found in the expected possibilities " + possibilities : msg, pos);
    }
  }

  /**
   * Checks that the test array contains the match parameter.
   * @param match The element that must be included in the tested array
   * @param values The values to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function contains<T>(match : T, values : Array<T>, ?msg : String , ?pos : PosInfos) : Bool {
    return if(Lambda.has(values, match)) {
      isTrue(true, msg, pos);
    } else {
      fail(msg == null ? "values " + q(values) + " do not contain "+match: msg, pos);
    }
  }

  /**
   * Checks that the test array does not contain the match parameter.
   * @param match The element that must NOT be included in the tested array
   * @param values The values to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function notContains<T>(match : T, values : Array<T>, ?msg : String , ?pos : PosInfos) : Bool {
    return if(!Lambda.has(values, match)) {
      isTrue(true, msg, pos);
    } else {
      fail(msg == null ? "values " + q(values) + " do contain "+match: msg, pos);
    }
  }

  /**
   * Checks that the expected values is contained in value.
   * @param match the string value that must be contained in value
   * @param value the value to test
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed.
   */
  public static function stringContains(match : String, value : String, ?msg : String , ?pos : PosInfos) : Bool {
    return if (value != null && value.indexOf(match) >= 0) {
      isTrue(true, msg, pos);
    } else {
      fail(msg == null ? "value " + q(value) + " does not contain " + q(match) : msg, pos);
    }
  }

  /**
   * Checks that the test string contains all the values in `sequence` in the order
   * they are defined.
   * @param sequence the values to match in the string
   * @param value the value to test
   * @param msg An optional error message. If not passed a default one is be used
   * @param pos Code position where the Assert call has been executed.
   */
  public static function stringSequence(sequence : Array<String>, value : String, ?msg : String , ?pos : PosInfos) : Bool {
    if (null == value)
    {
      return fail(msg == null ? "null argument value" : msg, pos);
    }
    var p = 0;
    for (s in sequence)
    {
      var p2 = value.indexOf(s, p);
      if (p2 < 0)
      {
        if (msg == null)
        {
          msg = "expected '" + s + "' after ";
          if (p > 0)
          {
            var cut = value.substr(0, p);
            if (cut.length > 30)
              cut = '...' + cut.substr( -27);
            msg += " '" + cut + "'" ;
          } else
            msg += " begin";
        }
        return fail(msg, pos);
      }
      p = p2 + s.length;
    }
    return isTrue(true, msg, pos);
  }

  /**
   * Adds a successful assertion for cases where there are no values to assert.
   * @param msg An optional success message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function pass(msg = "pass expected", ?pos : PosInfos) : Bool {
    return isTrue(true, msg, pos);
  }

  /**
   * Forces a failure.
   * @param msg An optional error message. If not passed a default one will be used
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function fail(msg = "failure expected", ?pos : PosInfos) : Bool {
    return isTrue(false, msg, pos);
  }

  /**
   * Creates a warning message.
   * @param msg A mandatory message that justifies the warning.
   * @param pos Code position where the Assert call has been executed. Don't fill it
   * unless you know what you are doing.
   */
  public static function warn(msg : String) {
    results.add(Warning(msg));
  }

  /**
   * Creates an asynchronous context for test execution. Assertions should be included
   * in the passed function.
   * ```haxe
   * public function assertAsync() {
   *   var async = Assert.createAsync(function() Assert.isTrue(true));
   *   haxe.Timer.delay(async, 50);
   * }
   * ```
   * @param f A function that contains other Assert tests
   * @param timeout Optional timeout value in milliseconds.
   */
  public static dynamic function createAsync(?f : Void -> Void, ?timeout : Int) {
    return function(){};
  }

  /**
   * Creates an asynchronous context for test execution of an event like method.
   * Assertions should be included in the passed function.
   * It works the same way as Assert.createAsync() but accepts a function with one
   * argument (usually some event data) instead of a function with no arguments
   * @param f A function that contains other Assert tests
   * @param timeout Optional timeout value in milliseconds.
   */
  public static dynamic function createEvent<EventArg>(f : EventArg -> Void, ?timeout : Int) {
    return function(e){};
  }

  static function typeToString(t : Dynamic) {
    try {
      var _t = Type.getClass(t);
      if (_t != null)
        t = _t;
    } catch(e : Dynamic) { }
    try return Type.getClassName(t) catch (e : Dynamic) { }
    try {
      var _t = Type.getEnum(t);
      if (_t != null)
        t = _t;
    } catch(e : Dynamic) { }
    try return Type.getEnumName(t) catch(e : Dynamic) {}
    try return Std.string(Type.typeof(t)) catch (e : Dynamic) { }
    try return Std.string(t) catch (e : Dynamic) { }
    return '<unable to retrieve type name>';
  }
}

private typedef LikeStatus = {
  recursive : Bool,
  path : String,
  error : String,
  expectedValue:Dynamic,
  actualValue:Dynamic
};
