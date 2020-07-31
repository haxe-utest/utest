utest
---

[![Build Status](https://travis-ci.org/haxe-utest/utest.svg?branch=master)](https://travis-ci.org/haxe-utest/utest)
[![Build status](https://ci.appveyor.com/api/projects/status/oy1ashccfh60ayl0/branch/master?svg=true)](https://ci.appveyor.com/project/haxe-utest/utest/branch/master)

[![Sauce Test Status](https://saucelabs.com/browser-matrix/fponticelli-utest.svg)](https://saucelabs.com/u/fponticelli-utest)

utest is an easy to use unit testing library for Haxe. It works on all the supported platforms including nodejs.

- [utest](#utest)
- [Installation](#installation)
- [Basic usage](#basic-usage)
- [Inter-test dependencies](#inter-test-dependencies)
- [Dependencies between test classes](#dependencies-between-test-classes)
- [Running single test from a test suite.](#running-single-test-from-a-test-suite)
- [Async tests](#async-tests)
- [Print test names being executed](#print-test-names-being-executed)
- [Convert failures into exceptions](#convert-failures-into-exceptions)
- [Assert](#assert)
- [Ignoring tests](#ignoring-tests)

## Installation

Install is as easy as:

```bash
haxelib install utest
```

## Basic usage

In your main method define the minimal instances needed to run your tests.

```haxe
import utest.Runner;
import utest.ui.Report;

class TestAll {
  public static function main() {
    //the long way
    var runner = new Runner();
    runner.addCase(new TestCase1());
    runner.addCase(new TestCase2());
    Report.create(runner);
    runner.run();

    //the short way in case you don't need to handle any specifics
    utest.UTest.run([new TestCase1(), new TestCase2()]);
  }
}
```

`TestCase` must extend `utest.Test` or implement `utest.ITest`.

`TestCase` needs to follow some conventions:

  * Every test case method name must be prefixed with `test` or `spec`;
  * If a method is prefixed with `spec` it is treated as the specification test. Every boolean binary operation will be wrapped in `Assert.isTrue()`

Following methods could be implemented to setup or teardown:
```haxe
/**
 * This method is executed once before running the first test in the current class.
 * If it accepts an argument, it is treated as an asynchronous method.
 */
function setupClass():Void;
function setupClass(async:Async):Void;
/**
 * This method is executed before each test.
  * If it accepts an argument, it is treated as an asynchronous method.
 */
function setup():Void;
function setup(async:Async):Void;
/**
 * This method is executed after each test.
  * If it accepts an argument, it is treated as an asynchronous method.
 */
function teardown():Void;
function teardown(async:Async):Void;
/**
 * This method is executed once after the last test in the current class is finished.
  * If it accepts an argument, it is treated as an asynchronous method.
 */
function teardownClass():Void;
function teardownClass(async:Async):Void;
```

Default timeout for asynchronous methods is 250ms. You can change it by adding `@:timeout(500)` meta.

To add all test cases from `my.pack` package use `runner.addCases(my.pack)`. Any module found in `my.pack` is treated as a test case. That means each module should contain a class implementing `utest.ITest` and that class should have the same name as the module name.

```haxe
import utest.Assert;
import utest.Async;

class TestCase extends utest.Test {
  var field:String;

  //synchronous setup
  public function setup() {
    field = "some";
  }

  function testFieldIsSome() {
    Assert.equals("some", field);
  }

  function specField() {
    field.charAt(0) == 's';
    field.length > 3;
  }

  //asynchronous teardown
  @:timeout(700) //default timeout is 250ms
  public function teardown(async:Async) {
    field = null; // not really needed

    //simulate asynchronous teardown
    haxe.Timer.delay(
      function() {
        //resolve asynchronous action
        async.done();
      },
      500
    );
  }
}
```

## Inter-test dependencies

It is possible to define how tests depend on each other with `@:depends` meta:
```haxe
class TestCase extends utest.Test {

	function testBasicThing1() {
		//...
	}

	function testBasicThing2() {
		//...
	}


	@:depends(testBasicThing, testBasicThing2)
	function testComplexThing() {
		//...
	}
}
```
In this example `testComplexThing` will be executed only if `testBasicThing1` and `testBasicThing2` pass.

## Dependencies between test classes

`@:depends` meta could also be used to define dependencies of one class with tests on other classes with tests.
```haxe
package some.pack;

class TestCase1 extends utest.Test {
	function test1() {
		//...
	}
}

@:depends(some.pack.TestCase2)
class TestCase2 extends utest.Test {
	function test2() {
		//...
	}
}
```
In this example tests from `some.pack.TestCase2` will be executed only if there were no failures in `some.pack.TestCase1`.

## Running single test from a test suite.

Adding `-D UTEST_PATTERN=pattern` to the compilation flags makes UTest to run only tests which have names matching the `pattern`. The pattern could be a plain string or a regular expression without delimiters.

Another option is to add `UTEST_PATTERN` to the environment variables at compile time.

## Async tests

If a test case accepts an argument, that test case is treated as an asynchronous test.

```haxe
@:timeout(500) //change timeout (default: 250ms)
function testSomething(async:utest.Async) {
  // do your async goodness and remember to call `done()` at the end.
  haxe.Timer.delay(function() {
    Assert.isTrue(true); // put a sensible test here
    async.done();
  }, 50);
}
```

It's also possible to "branch" asynchronous tests. In this case a test will be considered completed when all branches are finished.

```haxe
function testSomething(async:utest.Async) {
  var branch = async.branch();
  haxe.Timer.delay(function() {
    Assert.isTrue(true); // put a sensible test here
    branch.done();
  }, 50);

  // or create an asynchronous branch with a callback
  async.branch(function(branch) {
    haxe.Timer.delay(function() {
      Assert.isTrue(true); // put a sensible test here
      branch.done();
    }, 50);
  });
}
```

## Print test names being executed

`-D UTEST_PRINT_TESTS` makes UTest print test names in the process of tests execution.
The output will look like this:
```
Running my.tests.TestAsync...
    testSetTimeout
    testTimeout
Running my.tests.TestAnother...
    testThis
    testThat
```
And after finishing all the tests UTest will print usual report.

Another option is to add `UTEST_PRINT_TESTS` to the environment variables at compile time.

## Convert failures into exceptions

It is possible to make UTest throw an unhandled exception instead of adding a failure to the report.

Enable this behavior with `-D UTEST_FAILURE_THROW`, or by adding `UTEST_FAILURE_THROW` to the environment variables at compile time.

In this case any exception or failure in test or setup methods will lead to a crash.
Instead of a test report you will see an unhandled exception message with the exception
stack trace (depending on a target platform).

## Assert

[Assert](src/utest/Assert.hx) contains a plethora of methods to perform your tests:

> *`isTrue(cond:Bool, ?msg:String, ?pos:PosInfos)`*

Asserts successfully when the condition is true.

`cond` The condition to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`isFalse(value:Bool, ?msg:String, ?pos:PosInfos)`*

Asserts successfully when the condition is false.

`cond` The condition to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`isNull(value:Dynamic, ?msg:String, ?pos:PosInfos)`*

Asserts successfully when the value is null.

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`notNull(value:Dynamic, ?msg:String, ?pos:PosInfos)`*

Asserts successfully when the value is not null.

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`is(value:Dynamic, type:Dynamic, ?msg:String , ?pos:PosInfos)`*

Asserts successfully when the 'value' parameter is of the of the passed type 'type'.

`value` The value to test

`type` The type to test against

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`notEquals(expected:Dynamic, value:Dynamic, ?msg:String , ?pos:PosInfos)`*

Asserts successfully when the value parameter is not the same as the expected one.
```haxe
Assert.notEquals(10, age);
```

`expected` The expected value to check against

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`equals(expected:Dynamic, value:Dynamic, ?msg:String , ?pos:PosInfos)`*

Asserts successfully when the value parameter is equal to the expected one.
```haxe
Assert.equals(10, age);
```

`expected` The expected value to check against

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.


> *`match(pattern:EReg, value:Dynamic, ?msg:String , ?pos:PosInfos)`*

Asserts successfully when the value parameter does match against the passed EReg instance.
```haxe
Assert.match(~/x/i, "Haxe");
```

`pattern` The pattern to match against

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`floatEquals(expected:Float, value:Float, ?approx:Float, ?msg:String , ?pos:PosInfos)`*

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

> *`same(expected:Dynamic, value:Dynamic, ?recursive:Bool, ?msg:String, ?pos:PosInfos)`*

Check that value is an object with the same fields and values found in expected.
The default behavior is to check nested objects in fields recursively.
```haxe
Assert.same({ name:"utest"}, ob);
```

`expected` The expected value to check against

`value` The value to test

`recursive` States whether or not the test will apply also to sub-objects.
Defaults to true

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`raises(method:Void -> Void, ?type:Class<Dynamic>, ?msgNotThrown:String , ?msgWrongType:String, ?pos:PosInfos)`*

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

> *`allows<T>(possibilities:Array<T>, value:T, ?msg:String , ?pos:PosInfos)`*

Checks that the test value matches at least one of the possibilities.

`possibility` An array of possible matches

`value` The value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`contains<T>(match:T, values:Array<T>, ?msg:String , ?pos:PosInfos)`*

Checks that the test array contains the match parameter.

`match` The element that must be included in the tested array

`values` The values to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`notContains<T>(match:T, values:Array<T>, ?msg:String , ?pos:PosInfos)`*

Checks that the test array does not contain the match parameter.

`match` The element that must NOT be included in the tested array

`values` The values to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.

> *`stringContains(match:String, value:String, ?msg:String , ?pos:PosInfos)`*

Checks that the expected values is contained in value.

`match` the string value that must be contained in value

`value` the value to test

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it

> *`fail(msg = "failure expected", ?pos:PosInfos)`*

Forces a failure.

`msg` An optional error message. If not passed a default one will be used

`pos` Code position where the Assert call has been executed. Don't fill it
unless you know what you are doing.


> *`warn(msg)`*

Creates a warning message.

`msg` A mandatory message that justifies the warning.

`pos` Code position where the Assert call has been executed. Don't fill it

## Ignoring tests

You can easily ignore one of tests within specifying `@Ignored` meta.

```haxe
class TestCase extends utest.Test {

  @Ignored("Ignore this test")
  function testIgnoredWithReason() {}

  @Ignored
  function testIgnoredWithoutReason():Void {}
}

```
