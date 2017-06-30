package utest.ui.text;

import utest.Runner;

#if php
import php.Lib;
#elseif neko
import neko.Lib;
#elseif cpp
import cpp.Lib;
#end

class PrintReport extends PlainTextReport {
#if (php || neko)
  var useTrace : Bool;
  public function new(runner : Runner, ?useTrace : Bool = false) {
    this.useTrace = useTrace;
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
    if(useTrace)
      _trace(report.getResults());
    else
      _print(report.getResults());

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
