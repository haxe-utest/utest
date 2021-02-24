package utest.ui.text;

import utest.ui.common.IReport;
import utest.ui.common.HeaderDisplayMode;

import utest.Runner;
import utest.ui.common.ResultAggregator;
using utest.ui.common.ReportTools;
import utest.ui.common.PackageResult;
import haxe.CallStack;

class PlainTextReport implements IReport<PlainTextReport> {
  public var displaySuccessResults : SuccessResultsDisplayMode;
  public var displayHeader : HeaderDisplayMode;
  public var handler : PlainTextReport -> Void;

  var aggregator : ResultAggregator;
  var newline : String;
  var indent : String;
  public function new(runner : Runner, ?outputHandler : PlainTextReport -> Void) {
    aggregator = new ResultAggregator(runner, true);
    runner.onStart.add(start);
    aggregator.onComplete.add(complete);
    if (null != outputHandler)
      setHandler(outputHandler);
    displaySuccessResults = AlwaysShowSuccessResults;
    displayHeader = AlwaysShowHeader;
  }

  public function setHandler(handler : PlainTextReport -> Void) : Void
    this.handler = handler;

  var startTime : Float;
  function start(e) {
    startTime = getTime();
  }

  function getTime():Float
    #if java
    return Date.now().getTime()/1000;
    #elseif cs
    return cast (cs.system.DateTime.UtcNow.Ticks - new cs.system.DateTime(1970, 1, 1).Ticks) / cs.system.TimeSpan.TicksPerSecond;
    #else
    return haxe.Timer.stamp();
    #end

  function indents(c : Int) {
    var s = '';
    while(--c >= 0)
      s += indent;
    return s;
  }

  function dumpStack(stack : Array<StackItem>) {
    if (stack.length == 0)
      return "";
    var parts = CallStack.toString(stack).split("\n"),
      r = [];
    for (part in parts) {
      if (part.indexOf(" utest.") >= 0) continue;
      r.push(part);
    }
    return r.join(newline);
  }

  function addHeader(buf : StringBuf, result : PackageResult) {
    if (!this.hasHeader(result.stats))
      return;

    var end = getTime();
#if php
    var scripttime = Std.int(Sys.cpuTime()*1000)/1000;
#end
    var time = Std.int((end-startTime)*1000)/1000;


    buf.add("\nassertations: "   + result.stats.assertations+newline);
    buf.add("successes: "      + result.stats.successes+newline);
    buf.add("errors: "         + result.stats.errors+newline);
    buf.add("failures: "       + result.stats.failures+newline);
    buf.add("warnings: "       + result.stats.warnings+newline);
    buf.add("execution time: " + time+newline);
#if php
    buf.add("script time: "    + scripttime+newline);
#end
    buf.add(newline);
    buf.add("results: " + (result.stats.isOk ? "ALL TESTS OK (success: true)" : "SOME TESTS FAILURES (success: false)"));
    buf.add(newline);
  }

  var result : PackageResult;
  public function getResults() : String {
    var buf = new StringBuf();
    addHeader(buf, result);

    for(pname in result.packageNames()) {
      var pack = result.getPackage(pname);
      if (this.skipResult(pack.stats, result.stats.isOk)) continue;
      for(cname in pack.classNames()) {
        var cls = pack.getClass(cname);
        if (this.skipResult(cls.stats, result.stats.isOk)) continue;
        buf.add((pname == '' ? '' : pname+".")+cname+newline);
        for(mname in cls.methodNames()) {
          var fix = cls.get(mname);
          if (this.skipResult(fix.stats, result.stats.isOk)) continue;
          buf.add(indents(1)+mname+": ");
          if(fix.stats.isOk) {
            buf.add("OK ");
          } else if(fix.stats.hasErrors) {
            buf.add("ERROR ");
          } else if(fix.stats.hasFailures) {
            buf.add("FAILURE ");
          } else if(fix.stats.hasWarnings) {
            buf.add("WARNING ");
          }
          var messages = '';
          for(assertation in fix.iterator()) {
            switch(assertation) {
              case Success(_):
                buf.add('.');
              case Failure(msg, pos):
                buf.add('F');
                messages += indents(2)+"line: " + pos.lineNumber + ", " + msg + newline;
              case Error(e, s):
                buf.add('E');
                messages += indents(2)+ Std.string(e) + dumpStack(s) + newline ;
              case SetupError(e, s):
                buf.add('S');
                messages += indents(2)+ Std.string(e) + dumpStack(s) + newline;
              case TeardownError(e, s):
                buf.add('T');
                messages += indents(2)+ Std.string(e) + dumpStack(s) + newline;
              case TimeoutError(missedAsyncs, s):
                buf.add('O');
                messages += indents(2)+ "missed async calls: " + missedAsyncs + dumpStack(s) + newline;
              case AsyncError(e, s):
                buf.add('A');
                messages += indents(2)+ Std.string(e) + dumpStack(s) + newline;
              case Warning(msg):
                buf.add('W');
                messages += indents(2)+ msg + newline;
              case Ignore(reason):
                buf.add('I');
                if (reason != null && reason != "") {
                  messages += indents(2) + 'With reason: ${reason}' + newline;
                }
            }
          }
          buf.add(newline);
          buf.add(messages);
        }
      }
    }
    return buf.toString();
  }

  function complete(result : PackageResult) {
    this.result = result;
    if (handler != null) handler(this);
#if (php || neko || cpp || cs || java || python || lua || eval || hl)
    Sys.exit(result.stats.isOk ? 0 : 1);
#elseif js
    if(#if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end('typeof phantom != "undefined"'))
      #if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end('phantom').exit(result.stats.isOk ? 0 : 1);
    if(#if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end('typeof process != "undefined"'))
      #if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end('process').exit(result.stats.isOk ? 0 : 1);
#elseif air
    flash.desktop.NativeApplication.nativeApplication.exit(result.stats.isOk ? 0 : 1);		
#elseif (flash && exit)
      if(flash.system.Security.sandboxType == "localTrusted") {
        var delay = 5;
        trace('all done, exiting in $delay seconds');
        haxe.Timer.delay(function() try {
            flash.system.System.exit(result.stats.isOk ? 0 : 1);
          } catch(e : Dynamic) {
            // do nothing
          }, delay * 1000);
      }
#end
  }
}
