package tests.iterations;

import utest.ui.text.TraceReport;

class TestLang {
	static function main() {
		var runner = new Runner();
		runner.addCase(new tests.lang.AnonymousObject());
//		runner.addCase(new tests.lang.ArraySyntax());
		runner.addCase(new tests.lang.Bitwise());
		runner.addCase(new tests.lang.Callback());
		runner.addCase(new tests.lang.Casts());
		// reformulate some of this tests since other tests (from ClassDefAccess) can modify the results
		runner.addCase(new tests.lang.DynamicFunction());
		runner.addCase(new tests.lang.ClassDefAccess());
		runner.addCase(new tests.lang.ClassInheritance());
		runner.addCase(new tests.lang.CodeBlocks());
		runner.addCase(new tests.lang.DynamicClass());
		runner.addCase(new tests.lang.EnumAccess());
		runner.addCase(new tests.lang.EnumSyntax());
		runner.addCase(new tests.lang.EqualityOperators());
// problem with doc
//		runner.addCase(new tests.lang.Extensions());
		runner.addCase(new tests.lang.ForAccess());
		runner.addCase(new tests.lang.IfAccess());
		runner.addCase(new tests.lang.InterfaceAccess());
		runner.addCase(new tests.lang.IntIteratorAccess());
#if php
		runner.addCase(new tests.lang.NativeString());
		runner.addCase(new tests.lang.NativeArray());
		runner.addCase(new tests.lang.PhpDollarEscape());
		runner.addCase(new tests.lang.PhpReservedWords());
#end
		runner.addCase(new tests.lang.PrivateClassAccess());
		runner.addCase(new tests.lang.PropertyAccess());
		runner.addCase(new tests.lang.SwitchCaseAccess());
		runner.addCase(new tests.lang.TryCatch());
// problem with doc
//		runner.addCase(new tests.lang.TypedefAccess());
		runner.addCase(new tests.lang.UnusualConstructs());
		runner.addCase(new tests.lang.WhileAccess());
		var report = new TraceReport(runner);
		runner.run();
	}
}