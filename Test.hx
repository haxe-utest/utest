import utest.Runner;
import utest.ui.text.TraceReport;

class Test {
	public static function main() {
		/*
#if php
		php.Lib.print("<pre>");
#elseif neko
		neko.Lib.print("<pre>");
#end
*/
		var runner = new Runner();

		runner.addCase(new tests.std.ArrayTest());
		runner.addCase(new tests.std.DateTest());
#if (!flash || flash9)
		runner.addCase(new tests.std.ERegTest());
#end
		runner.addCase(new tests.std.HashTest());
		runner.addCase(new tests.std.IntHashTest());
		runner.addCase(new tests.std.ListTest());
		runner.addCase(new tests.std.StdTest());
		runner.addCase(new tests.std.StringTest());
		runner.addCase(new tests.std.StringToolsTest());
		runner.addCase(new tests.std.XmlTest());

		runner.addCase(new tests.std.haxe.Md5Test());
		runner.addCase(new tests.std.haxe.SerializerTest());

		runner.addCase(new tests.std.ReflectTest()); // CRASHES <= F8


#if (!flash || flash9)
		runner.addCase(new tests.std.haxe.TemplateTest());
#end


#if neko
		runner.addCase(new tests.std.neko.NekoSerializationTest());
#end

		runner.addCase(new tests.lang.CompareTest());

		haxe.Firebug.redirectTraces();

		var report = new TraceReport(runner);
		runner.run();
	}
}

class TestClass {
	public function new();

	public function test() { utest.Assert.isTrue(true); }
}