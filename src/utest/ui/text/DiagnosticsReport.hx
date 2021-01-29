package utest.ui.text;

import haxe.CallStack;
import utest.Runner;
import utest.ui.common.PackageResult;

using utest.ui.common.ReportTools;

#if sys
class DiagnosticsReport extends PlainTextReport {
  public function new(runner:Runner) {
    super(runner, handleResults);
    newline = "\n";
    indent = "  ";
  }

  function printStats(result:PackageResult) {
    if (!this.hasHeader(result.stats))
      return;

    var end = getTime();
    var time = Std.int((end - startTime) * 1000) / 1000;

    Sys.println('assertions: ${result.stats.successes}/${result.stats.assertations} (${time}s)');
    if (!result.stats.isOk) {
      Sys.println('errors: ${result.stats.errors} - failures: ${result.stats.failures} - warnings: ${result.stats.warnings}');
    }
  }

  override function dumpStack(stack:Array<StackItem>) {
    if (stack.length == 0) {
      return "";
    }

    var buf:StringBuf = new StringBuf();
    buf.add(newline);
    for (item in stack) {
      buf.add(indents(1) + "Called from ");
      buf.add(stackItemToString(item));
      buf.add(newline);
    }
    return buf.toString();
  }

  function stackItemToString(item:Null<StackItem>):String {
    return switch (item) {
      case null:
        "";
      case CFunction:
        "a C function";
      case Module(m):
        'module $m';
      case FilePos(s, file, line, column):
        '${stackItemToString(s)} ($file:$line:$column:)';
      case Method(null, method):
        '<unknown>.$method';
      case Method(classname, method):
        '$classname.$method';
      case LocalFunction(v):
        'local function #$v';
    }
  }

  function handleResults(report:PlainTextReport) {
    var messages:Array<String> = [];
    for (pname in result.packageNames()) {
      var pack = result.getPackage(pname);
      if (this.skipResult(pack.stats, result.stats.isOk))
        continue;
      for (cname in pack.classNames()) {
        var cls = pack.getClass(cname);
        if (this.skipResult(cls.stats, result.stats.isOk))
          continue;
        Sys.println((pname == '' ? '' : pname + ".") + cname);
        for (mname in cls.methodNames()) {
          var fix = cls.get(mname);
          if (this.skipResult(fix.stats, result.stats.isOk))
            continue;
          Sys.print(indents(1) + mname + ": ");
          if (fix.stats.isOk) {
            Sys.print("OK ");
          } else if (fix.stats.hasErrors) {
            Sys.print("ERROR ");
          } else if (fix.stats.hasFailures) {
            Sys.print("FAILURE ");
          } else if (fix.stats.hasWarnings) {
            Sys.print("WARNING ");
          }
          for (assertation in fix.iterator()) {
            switch (assertation) {
              case Success(_):
                Sys.print('.');
              case Failure(msg, pos):
                Sys.print('F');
                messages.push('${pos.fileName}:${pos.lineNumber}: Test failed: $msg');
              case Error(e, s):
                Sys.print('E');
                messages.push(Std.string(e) + dumpStack(s));
              case SetupError(e, s):
                Sys.print('S');
                messages.push(Std.string(e) + dumpStack(s));
              case TeardownError(e, s):
                Sys.print('T');
                messages.push(Std.string(e) + dumpStack(s));
              case TimeoutError(missedAsyncs, s):
                Sys.print('O');
                messages.push("missed async calls: " + missedAsyncs + dumpStack(s));
              case AsyncError(e, s):
                Sys.print('A');
                messages.push(Std.string(e) + dumpStack(s));
              case Warning(msg):
                Sys.print('W');
                messages.push(msg);
              case Ignore(reason):
                Sys.print('I');
                if (reason != null && reason != "") {
                  messages.push('With reason: ${reason}');
                }
            }
          }
          Sys.println("");
        }
      }
    }
    Sys.println("");
    printStats(result);
    if (messages.length > 0) {
      Sys.println("");
      for (message in messages) {
        Sys.println(message);
      }
      Sys.println("");
    }
  }
}
#end
