package utest.ui.text;

import haxe.PosInfos;

import utest.Runner;
import utest.TestResult;
import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;

#if php
import php.Lib;
#elseif neko
import neko.Lib;
#elseif cpp
import cpp.Lib;
#end

class PrintReport extends PlainTextReport {
#if (php || neko)
  var print : String -> Void;
  public function new(runner : Runner, ?useTrace : Bool = false) {
    if(useTrace)
      print = _trace;
    else
      print = _print;
    super(runner, _handler);
#if php
    if (php.Lib.isCli()) {
#elseif neko
    if (!neko.Web.isModNeko) {
#end
      newline = "\n";
      indent  = "  ";
    } else {
      newline = "<br>";
      indent  = "&nbsp;&nbsp;";
    }
  }

  function _handler(report : PlainTextReport)
    print(report.getResults());

#else
  public function new(runner : Runner) {
    super(runner, _handler);
    newline = "\n";
    indent  = "  ";
  }

  function _handler(report : PlainTextReport)
    _trace(report.getResults());
#end

  function _trace(s : String) {
    s = StringTools.replace(s, '  ', indent);
    s = StringTools.replace(s, '\n', newline);
    haxe.Log.trace(s);
  }
#if (php || neko || cpp)
  function _print(s : String)
    Lib.print(s);
#end
}
