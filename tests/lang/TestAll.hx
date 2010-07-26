/**
 * ...
 * @author Franco Ponticelli
 */

package lang;
import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new lang.TestAnonymousObject());
		runner.addCase(new lang.TestArraySyntax());
		runner.addCase(new lang.TestBitwise());
		runner.addCase(new lang.TestCallback());
		runner.addCase(new lang.TestCasts());
		runner.addCase(new lang.TestClassDefAccess());
		
		runner.addCase(new lang.TestClassInheritance());
		runner.addCase(new lang.TestCodeBlocks());
		runner.addCase(new lang.TestCompareTest());
		runner.addCase(new lang.TestDefaultArguments());
		runner.addCase(new lang.TestDynamicClass());
		runner.addCase(new lang.TestDynamicFunction());
#if !cpp
		runner.addCase(new lang.TestEnumAccess());
#end
		runner.addCase(new lang.TestEnumSyntax());

		runner.addCase(new lang.TestEqualityOperators());
		runner.addCase(new lang.TestExtensions());
		
		runner.addCase(new lang.TestForAccess());
		
		runner.addCase(new lang.TestIfAccess());
		runner.addCase(new lang.TestInline());
		runner.addCase(new lang.TestInterfaceAccess());
		runner.addCase(new lang.TestIntIteratorAccess());
		runner.addCase(new lang.TestNativeArray());
		runner.addCase(new lang.TestNativeString());
		runner.addCase(new lang.TestPrivateClassAccess());
#if !cpp
		runner.addCase(new lang.TestPropertyAccess());
#end
		runner.addCase(new lang.TestSwitchCaseAccess());
		runner.addCase(new lang.TestToString());
		runner.addCase(new lang.TestTryCatch());
		runner.addCase(new lang.TestTypedefAccess());
		runner.addCase(new lang.TestUnusualConstructs());
		runner.addCase(new lang.TestWhileAccess());

		runner.addCase(new lang.TestMeta());
#if php
		runner.addCase(new lang.TestPhpDollarEscape());
		runner.addCase(new lang.TestPhpReservedWords());
#end
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}