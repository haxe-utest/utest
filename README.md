# utest

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

[Assert](src/utest/Assert.hx) contains a plethora of methods to perform your tests.

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