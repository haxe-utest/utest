# utest

[![Build Status](https://travis-ci.org/fponticelli/utest.svg?branch=master)](https://travis-ci.org/fponticelli/utest)

[![Sauce Test Status](https://saucelabs.com/browser-matrix/fponticelli-utest.svg)](https://saucelabs.com/u/fponticelli-utest)

utest is an easy to use unit testing library for Haxe. It works on all the supported platforms including nodejs.

## install

Install is as easy as:

```bash
haxelib install utest
```

## usage

In your main method define the minimal instances needed to run your tests.

```haxe
import utest.Runner;
import utest.ui.Report;

class TestAll {
  public static function main() {
    var runner = new Runner();
    runner.addCase(new TestCase());
    Report.create(runner);
    runner.run();
  }
}
```

`TestCase` doesn't need to implement anything special but needs to follow some conventions:

  * every test case method must be `public` and prefixed with `test`.
  * if the class provides public methods named `setup` and/or `teardown` they will be
    executed before and/or after each test case method.

```haxe
import utest.Assert;

class TestCase {
  var field : String;
  public function new() {};

  public function setup() {
    field = "some";
  }

  public function testFieldIsSome() {
    Assert.equals("some", field);
  }

  public function teardown() {
    field = null; // not really needed
  }
}
```

## Async tests

Creating an asynchronous test is easy:

```haxe
public function testAsync() {
  var done = Assert.createAsync(); // optionally pass a time in ms to define a max timeout
  // do your async goodness and remember to call `done()` at the end.
  haxe.Timer.delay(function() {
    Assert.isTrue(true); // put a sensible test here
    done();
  }, 50);
}
```

Note: Asynchronous tests work correctly for JS and Flash. The support for other platforms will be added ASAP.

## Assert

[Assert](src/utest/Assert.hx) contains a plethora of methods to perform your tests:

#### `isTrue(cond : Bool, ?msg : String, ?pos : PosInfos)`
Asserts successfully when the condition is true.

`cond` The condition to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `isFalse(value : Bool, ?msg : String, ?pos : PosInfos)`
Asserts successfully when the condition is false.

`cond` The condition to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `isNull(value : Dynamic, ?msg : String, ?pos : PosInfos)`
Asserts successfully when the value is null.

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `notNull(value : Dynamic, ?msg : String, ?pos : PosInfos)`
Asserts successfully when the value is not null.

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `is(value : Dynamic, type : Dynamic, ?msg : String , ?pos : PosInfos)`
Asserts successfully when the 'value' parameter is of the of the passed type 'type'.

`value` The value to test

`type` The type to test against

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `notEquals(expected : Dynamic, value : Dynamic, ?msg : String , ?pos : PosInfos)`
Asserts successfully when the value parameter is not the same as the expected one.
```haxe
Assert.notEquals(10, age);
```

`expected` The expected value to check against

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `equals(expected : Dynamic, value : Dynamic, ?msg : String , ?pos : PosInfos)`
Asserts successfully when the value parameter is equal to the expected one.
```haxe
Assert.equals(10, age);
```

`expected` The expected value to check against

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.


#### `match(pattern : EReg, value : Dynamic, ?msg : String , ?pos : PosInfos)`
Asserts successfully when the value parameter does match against the passed EReg instance.
```haxe
Assert.match(~/x/i, "Haxe");
```

`pattern` The pattern to match against

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `floatEquals(expected : Float, value : Float, ?approx : Float, ?msg : String , ?pos : PosInfos)`
Same as Assert.equals but considering an approximation error.
```haxe
Assert.floatEquals(Math.PI, value);
```

`expected` The expected value to check against

`value` The value to test

`approx` The approximation tollerance. Default is 1e-5

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `same(expected : Dynamic, value : Dynamic, ?recursive : Bool, ?msg : String, ?pos : PosInfos)`
Check that value is an object with the same fields and values found in expected.
The default behavior is to check nested objects in fields recursively.
```haxe
Assert.same({ name : "utest"}, ob);
```

`expected` The expected value to check against

`value` The value to test

`recursive` States whether or not the test will apply also to sub-objects.
Defaults to true

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `raises(method:Void -> Void, ?type:Class<Dynamic>, ?msgNotThrown : String , ?msgWrongType : String, ?pos : PosInfos)`
It is used to test an application that under certain circumstances must
react throwing an error. This assert guarantees that the error is of the
correct type (or Dynamic if non is specified).
```haxe
Assert.raises(function() { throw "Error!"; }, String);
```

`method` A method that generates the exception.

`type` The type of the expected error. Defaults to Dynamic (catch all).

`msgNotThrown` An optional error message used when the function fails to raise the expected
     exception. If not passed a default one will be used

`msgWrongType` An optional error message used when the function raises the exception but it is
     of a different type than the one expected. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.
@todo test the optional type parameter

#### `allows<T>(possibilities : Array<T>, value : T, ?msg : String , ?pos : PosInfos)`
Checks that the test value matches at least one of the possibilities.

`possibility` An array of possible matches

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `contains<T>(match : T, values : Array<T>, ?msg : String , ?pos : PosInfos)`
Checks that the test array contains the match parameter.

`match` The element that must be included in the tested array

`values` The values to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `notContains<T>(match : T, values : Array<T>, ?msg : String , ?pos : PosInfos)`
Checks that the test array does not contain the match parameter.

`match` The element that must NOT be included in the tested array

`values` The values to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

#### `stringContains(match : String, value : String, ?msg : String , ?pos : PosInfos)`
Checks that the expected values is contained in value.

`match` the string value that must be contained in value

`value` the value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it

#### `fail(msg = "failure expected", ?pos : PosInfos)`
Forces a failure.

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.


#### `warn(msg)`
Creates a warning message.

`msg` A mandatory message that justifies the warning.

`pos` Code position where the Assert call has been executed. Don't fill it

#### `createAsync(?f : Void -> Void, ?timeout : Int)`
Creates an asynchronous context for test execution. Assertions should be included
in the passed function.
```haxe
public function assertAsync() {
  var async = Assert.createAsync(function() Assert.isTrue(true));
  haxe.Timer.delay(async, 50);
}
```

`f` A function that contains other Assert tests

`timeout` Optional timeout value in milliseconds.

#### `createEvent<EventArg>(f : EventArg -> Void, ?timeout : Int)`
Creates an asynchronous context for test execution of an event like method.
Assertions should be included in the passed function.
It works the same way as Assert.assertAsync() but accepts a function with one
argument (usually some event data) instead of a function with no arguments

`f` A function that contains other Assert tests

`timeout` Optional timeout value in milliseconds.
