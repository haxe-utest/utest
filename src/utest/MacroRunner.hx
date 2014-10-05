package utest;

import haxe.rtti.Meta;
import haxe.unit.TestRunner;

#if macro
import neko.io.File;
import haxe.macro.Expr;
import haxe.macro.Context;
import neko.Lib;
#end

import utest.ui.macro.MacroReport;
import utest.Runner;

class MacroRunner {
  #if macro
/**
Run the unit tests from a macro, displaying errors and a summary in the macro Context.
@param  testClass Class where the tests are located.
*/
  public static function run(testClass : Dynamic) {
    var runner = new Runner();
    addClass(runner, testClass);

    new MacroReport(runner);
    runner.run();

    return { expr: EConst(CType("Void")), pos: Context.currentPos() };
  }
  #end

/**
Displays stub code for using MacroRunner.
@param n: String of test class to use, "package.ClassName" for example.
@todo Parse real package/class references instead of just a string.
*/
  macro public static function generateMainCode(n : Expr) {
    var className = "YOURTESTCLASS";

    switch n.expr {
      case EConst(c):
        switch c {
          case CString(s):
            className = s;
          default:
        }
      default:
    }

    trace("MacroRunner.run() can only be executed from a macro context.\nUse this code as a template in the main class:\n\n" +
    "class Main\n{\n\tstatic function main()\n\t{\n\t\tMain.runTests();\n\t}\n\n" +
    "\tmacro static function runTests()\n\t{\n\t\treturn MacroRunner.run(new " + className + "());\n\t}\n}\n");

    return { expr: EConst(CType("Void")), pos: Context.currentPos() };
  }

  static function addClass(runner : Runner, testClass : Class<Dynamic>) {
    runner.addCase(testClass);

    var addTests = Reflect.field(testClass, "addTests");

    if (addTests != null && Reflect.isFunction(addTests)) {
      Reflect.callMethod(testClass, addTests, [runner]);
    }
  }
}