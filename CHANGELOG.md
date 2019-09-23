# v.X.X.X
- `async.branch()` to create multiple branches of asynchronous tests ([#94](https://github.com/haxe-utest/utest/issues/94))
- `UTEST_PATTERN` and `Runner.globalPattern` also check test class name now ([#93](https://github.com/haxe-utest/utest/issues/93))
- `-D UTEST_PRINT_TEST` to print test names in the process of execution ([#95](https://github.com/haxe-utest/utest/issues/95))
- Fixed compatibility with Haxe 3 (was broken since 1.9.6)

# v.1.9.6
- Better failure messages for collections ([#81](https://github.com/haxe-utest/utest/issues/81))
- Fixed for as3 target ([#78](https://github.com/haxe-utest/utest/pull/78))
- Fixed test app shutdown before all tests are finished in some rare case on Java (see https://github.com/HaxeFoundation/haxe/issues/8131)

# v.1.9.5
- Fixed UTest trying to execute static method whose name starts with 'test' ([#71](https://github.com/haxe-utest/utest/issues/71))

# v.1.9.4
- Fixed signature of UTest.run(), which led to variance problems when the array isn't declared directly against the call argument. ([#70](https://github.com/haxe-utest/utest/pull/70))

# v.1.9.3
- Added `utest.Async.setTimeout(ms)` to change async test timeout from within the test code ([#67](https://github.com/haxe-utest/utest/pull/67))
- Added `@:timeout(999)` support at class level to change default timeout for all tests in a class ([#67](https://github.com/haxe-utest/utest/pull/67))

# v.1.9.2
- Fixed `ITest requires __initializeUtest__` error for test cases with macros

# v.1.9.1
- Fixed compatibility with `-dce full` flag ([#62](https://github.com/haxe-utest/utest/pull/62))

# v.1.9.0
- Introduced `utest.ITest` and `utest.Test`. Test cases should implement or extend them. See README.md for details.
- Implemented `.setupClass()`/`.teardownClass()` to setup once before the first test in a test case and teardown once after the last one.
- Added a deprecation notice for test cases which don't implement `utest.ITest`.
- Use the compile-time environment variable or the compiler define "UTEST_PATTERN" to skip tests, which don't match its value.
- Add a failure to the result if no tests were executed.

# v.1.8.4
- Fixed exit code value for `--interp` target.

# v.1.8.3
- Avoid recursion while running synchronous tests (could deplete stack on big test suites)

# v.1.8.2
- Fixed waiting for completion of asynchronous tests on php, neko, python, java, lua
- Check for phantomjs before nodejs on shutting down the tests ([#55](https://github.com/haxe-utest/utest/issues/55))

# v.1.8.1
- Fixed "duplicated fixture" error caused by other utest bugs ([#52](https://github.com/haxe-utest/utest/issues/52))
- Fixed HtmlReporter exception if a script tag is added to a head tag ([#54](https://github.com/haxe-utest/utest/issues/54))

# v1.8.0
- Added `Runner.addCases(my.pack)`, which adds all test cases located in `my.pack` package.
- Reverted async tests for Haxe < 3.4.0 (https://github.com/haxe-utest/utest/pull/39#issuecomment-353660192)

# v1.7.2
- Fix broken compilation for js target (Caused by `@Ignored` functionality in `HtmlReport`).

# v1.7.1
- Fix exiting from tests in case TeamcityReport.
- Add functionality of ignoring tests withing `@Ignored` meta.
- Force `Runner#globalPattern` overriding withing `pattern` argument from `Runner#addCase` (https://github.com/fponticelli/utest/issues/42)

# v1.7.0
- Fix Assert.raises for unspecified exception types
- Add PlainTextReport#getTime implementation for C#
- Fix null pointer on clear `PlainTextReport.hx` reported.
- Add Teamcity reporter (enables with flag `-Dteamcity`).
- Enabled async tests for all platforms

# v1.6.0
- HL support fixed
- Compatibility with Lua target.

# v1.5.0
- Added async setup/teardown handling
- Add executing of java tests synchronously
- Add C++ pointers comparison

# v1.4.0
- Initial support for phantomjs.
- Added handlers to catch test start/complete.
- Assert.same supports an optional parameter to set float precision comparison.
- Added `globalPattern` to filter only the desired results.
- Fixes.

# v1.3.10
- Fixed Assert.raises.

# v1.3.9
- Fixed issue with PHP.

# v1.3.8
- Minor fix for HTML output.

# v1.3.7
- Improved Java experience and simplified API.

# v1.3.6
- Message improvements and fixed recursion issue with Python.

# v1.3.5
- Minor message improvement.

# v1.3.4
- Added `Assert.pass()` (thanks Andy White) and other minor improvements.

# v1.3.3
- Added support for phantomjs

# v1.3.2
- Future proof IMap check.

# v1.3.1
- Fixed issues with Map/IMap in Assert.same()

# v1.3.0
- library is now Travis/travis-hx friendly

# v1.2.0
- added async tests to Java

# v1.1.3
- minor improvements

# v1.1.2
- Haxe3 release
