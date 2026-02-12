package utest;

import haxe.io.Path;
import haxe.macro.Expr;

using haxe.macro.ComplexTypeTools;
using haxe.macro.Context;
using sys.FileSystem;

#if (haxe_ver < "4.1.0")
	#error 'Haxe 4.1.0 or later is required to run UTest'
#end

/**
 * Helper class to quickly generate test cases.
 */
final class UTest {
  public static function run<T:ITest>(cases : Array<T>, ?callback : ()->Void) {
    var runner = new Runner();
    for(eachCase in cases)
      runner.addCase(eachCase);
    if(null != callback)
      runner.onComplete.add(function(_) callback());
    utest.ui.Report.create(runner);
    runner.run();
  }

  /**
   * Runs all test cases found in the given packages. You can also specify
   * individual test cases. Sample usage:
   * 
   * ```haxe
   * UTest.runAll([new MyTest(), com.my.package]);
   * ```
   */
  macro public static function runAll(paths : ExprOf<Array<Dynamic>>, ?callback : ExprOf<() -> Void>) {
    return macro ${ prepareToRunAll(paths, callback) }.run();
  }

  /**
   * As `runAll()`, but returns the `Runner` without running it.
   */
  #if !macro macro #end
  public static function prepareToRunAll(paths : ExprOf<Array<Dynamic>>, ?callback : ExprOf<() -> Void>) {
    if(Context.defined('display')) {
      return macro new utest.Runner();
    }
    var pathsArray : Array<Expr>;
    switch(paths.expr) {
      case EArrayDecl(values):
        pathsArray = values;
      default:
        pathsArray = [paths];
    }
    var foundTests = false;
    var iTest = (macro:utest.ITest).toType();
    var haxeClass = ~/^([A-Z]\w+)\.hx$/;
    var exprs : Array<Expr> = [macro var runner = new utest.Runner()];
    function addTests(dir:String, pack:Array<String>, pos:Position) {
      if(!dir.exists()) return;
      for(file in dir.readDirectory()) {
        var fullPath = Path.join([dir, file]);
        if(fullPath.isDirectory()) {
          var pack = pack.copy();
          pack.push(file);
          addTests(fullPath, pack, pos);
          continue;
        }
        if(!haxeClass.match(file)) {
          continue;
        }
        var typePath = {
          pack: pack,
          name: haxeClass.matched(1)
        };
        try {
          var type = Context.resolveType(TPath(typePath), pos);
          if(!type.unify(iTest)) {
            continue;
          }
        } catch(typeNotFound:String) {
          continue;
        }
        exprs.push(macro @:pos(pos) runner.addCase(new $typePath()));
        foundTests = true;
      }
    }
    function parse(expr : Expr, result : Array<String>) {
      switch(expr.expr) {
        case EConst(CIdent(s)):
          result.push(s);
        case EField(e, s):
          parse(expr, result);
          result.push(s);
        default:
          Context.error('Expected a test case or package.', expr.pos);
      }
    }
    for(path in pathsArray) {
      var pack : Array<String> = [];
      switch(path.expr) {
        case ENew(_, _):
          exprs.push(macro runner.addCase($path));
          continue;
        case EConst(CString(s)):
          pack = s.split(".");
        default:
          parse(path, pack);
      }
      var relativePath = Path.join(pack);
      foundTests = false;
      for(classPath in Context.getClassPath()) {
        addTests(Path.join([classPath, relativePath]), pack, path.pos);
      }
      if(!foundTests) {
        // Allow Haxe to determine if `path` refers to an `ITest` instance.
        exprs.push(macro runner.addCase($path));
      }
    }
    exprs.push(macro utest.ui.Report.create(runner));
    exprs.push(macro var callback : () -> Void = $callback);
    exprs.push(macro if(null != callback)
      runner.onComplete.add(function(_) callback()));
    exprs.push(macro runner);
    return macro $b{ exprs };
  }
}
