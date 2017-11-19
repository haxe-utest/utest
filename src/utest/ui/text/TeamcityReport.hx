package utest.ui.text;

import haxe.macro.Compiler;
import utest.Assertation;
import utest.Runner;
import utest.ui.common.ClassResult;
import utest.ui.common.FixtureResult;
import utest.ui.common.PackageResult;

/**
 * Prints report of unit test execution in Teamcity manner.
 *
 * @see https://confluence.jetbrains.com/display/TCD10/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ReportingTests
 *
 * Current reported doesn't support next fields:
 * <code>displaySuccessResults</code>
 * <code>displayHeader</code>
 *
 * Settings:
 * If `teamcity_suite_name` flag was defined, it's value will be used as root test suite name.
 * Otherwise `"Target: {TARGET_NAME}"` will be used.
 */
class TeamcityReport extends PlainTextReport {
  public function new(runner:Runner, ?outputHandler:PlainTextReport -> Void) {
    super(runner, outputHandler);
    newline = "\n";
    indent = "  ";
  }

  override public function getResults():String {
    var buf:StringBuf = new StringBuf();
    buf.add(newline);

    var rootSuiteName:String = getRootSuiteName();
    addSuiteStarted(buf, rootSuiteName);
    for (pname in result.packageNames()) {
      var pack:PackageResult = result.getPackage(pname);
      for (cname in pack.classNames()) {
        var cls:ClassResult = pack.getClass(cname);
        var classSuiteName:String = getClassName(pname, cname);
        addSuiteStarted(buf, classSuiteName);
        for (mname in cls.methodNames()) {
          var fix:FixtureResult = cls.get(mname);
          var testName:String = getTestName(pname, cname, mname);
          addTestStarted(buf, testName);


          if (fix.stats.isOk) {
            if (fix.stats.hasIgnores) {
              addTestIgnored(buf, testName, getIgnoreReason(fix));
            }
            addTestSucceed(buf, testName);
            continue;
          }

          var message = new StringBuf();
          var details = '';
          for (assertation in fix.iterator()) {
            switch(assertation) {
              case Assertation.Success(_):
                message.add('.');
              case Assertation.Failure(msg, pos):
                message.add('F');
                details += indents(2) + "line: " + pos.lineNumber + ", " + msg + newline;
              case Assertation.Error(e, s):
                message.add('E');
                details += indents(2) + Std.string(e) + dumpStack(s) + newline ;
              case Assertation.SetupError(e, s):
                message.add('S');
                details += indents(2) + Std.string(e) + dumpStack(s) + newline;
              case Assertation.TeardownError(e, s):
                message.add('T');
                details += indents(2) + Std.string(e) + dumpStack(s) + newline;
              case Assertation.TimeoutError(missedAsyncs, s):
                message.add('O');
                details += indents(2) + "missed async calls: " + missedAsyncs + dumpStack(s) + newline;
              case Assertation.AsyncError(e, s):
                message.add('A');
                details += indents(2) + Std.string(e) + dumpStack(s) + newline;
              case Assertation.Warning(msg):
                message.add('W');
                details += indents(2) + msg + newline;
              case Assertation.Ignore(reason):
                message.add('I');
                if (reason != null && reason != "") details += indents(2) + 'With reason: ${reason}' + newline;

            }
          }
          addTestFailed(buf, testName, message.toString(), details);
        }
        addSuiteFinished(buf, classSuiteName);
      }
    }
    addSuiteFinished(buf, rootSuiteName);

    return buf.toString();
  }

  private function getIgnoreReason(fix:FixtureResult):String {
    for (assertation in fix.iterator()) {
     switch(assertation) {
       case Assertation.Ignore(reason):
        return reason != null ? reason : "";
       default: // Do nothing.
     }
    }
    return null;
  }

  override function complete(result:PackageResult) {
    this.result = result;

    trace(getResults());

    super.complete(result);
  }

  private function addSuiteStarted(buf:StringBuf, suiteName:String):Void {
    addTeamcityEvent(buf, "testSuiteStarted", [
      "name" => suiteName
    ]);
  }

  private function addSuiteFinished(buf:StringBuf, suiteName:String):Void {
    addTeamcityEvent(buf, "testSuiteFinished", [
      "name" => suiteName
    ]);
  }

  private function addTestStarted(buf:StringBuf, testName:String):Void {
    addTeamcityEvent(buf, "testStarted", [
      "name" => testName
    ]);
  }

  private function addTestSucceed(buf:StringBuf, testName:String):Void {
    addTeamcityEvent(buf, "testFinished", [
      "name" => testName
    ]);
  }

  private function addTestIgnored(buf:StringBuf, testName:String, reason:String = null):Void {
    addTeamcityEvent(buf, "testIgnored", [
      "name" => testName,
      "message" => ((reason != null && reason != "") ? 'With reason: ${reason}.' : "Without specifying the reason.")
    ]);
  }

  private function addTestFailed(buf:StringBuf, testName:String, message:String, details:String):Void {
    addTeamcityEvent(buf, "testFailed", [
      "name" => testName,
      "message" => message,
      "details" => replaceAll(details, [
        String.fromCharCode(10) => "|n",
        String.fromCharCode(13) => "|r"
      ])
    ]);
  }

  private function getClassName(pack:String, className:String):String {
    return '${StringTools.replace(pack, ".", "_")}.${className}';
  }

  private function getTestName(pack:String, className:String, methodName:String):String {
    return '${getClassName(pack, className)}.${methodName}';
  }

  private function addTeamcityEvent(buf:StringBuf, eventName:String, ?args:Map<String, String>):Void {
    buf.add('##teamcity[${eventName}');
    var argsArray = [];
    for (argName in args.keys()) {
      var value = args.get(argName);
      argsArray.push('${argName}=\'${StringTools.replace(value, "'", "|'")}\'');
    }
    if (argsArray.length > 0) {
      buf.add(" ");
      buf.add(argsArray.join(" "));
    }
    buf.add("]");
    buf.add(newline);
  }

  private function getRootSuiteName():String {
    var suiteName:String = Compiler.getDefine("teamcity_suite_name");
    if (suiteName != null) {
      return suiteName;
    }
    return 'Target: ${getTargetName()}';
  }

  private inline function getTargetName():String {
    #if flash
    return "Flash";
    #elseif neko
    return "Neko";
    #elseif js
    return "JavaScript";
    #elseif php
    return "PHP";
    #elseif cpp
    return "C++";
    #elseif java
    return "Java";
    #elseif cs
    return "C#";
    #elseif lua
    return "Lua";
    #elseif php7
    return "PHP7";
    #elseif hs
    return "Hashlink";
    #else
    return "Undefined";
    #end
  }

  private static function replaceAll(where:String, replacements:Map<String, String>):String {
    for (what in replacements.keys()) {
      var with:String = replacements.get(what);
      where = StringTools.replace(where, what, with);
    }
    return where;
  }
}
