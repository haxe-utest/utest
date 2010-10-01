package utest;

import haxe.macro.Expr;
import haxe.macro.Context;

import utest.ui.macro.MacroReport;
import utest.Runner;

class MacroRunner
{
	@:macro public static function run(n : Expr)
	{
		try
		{
			var runner = new Runner();
			
			switch(n.expr)
			{
				case EConst(c):
					switch(c)
					{
						case CType(s):
							var testClass = Type.createInstance(Type.resolveClass(s), []);
							addClass(runner, testClass);
						
						default:
							Context.error("Argument must be a class type.", Context.currentPos());
					}
				
				default:
					Context.error("Argument must be a class type.", Context.currentPos());
			}
		
			new MacroReport(runner);
			runner.run();
		}
		catch (e : Dynamic)
		{
			trace(e);
		}
		
		return { expr: EConst(CType("Void")), pos: Context.currentPos() };
	}
	
	//@:macro public static function debugExpr(n : Expr)
	//{
	//	trace(n);
	//	return { expr: EConst(CType("Void")), pos: Context.currentPos() };
	//}
	
	static function addClass(runner : Runner, testClass : Class<Dynamic>)
	{
		runner.addCase(testClass);
		
		var addTests = Reflect.field(testClass, "addTests");
		
		if (addTests != null && Reflect.isFunction(addTests))
		{
			Reflect.callMethod(testClass, addTests, [runner]);
		}
	}
}