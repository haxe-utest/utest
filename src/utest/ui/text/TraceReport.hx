package utest.ui.text;

import haxe.PosInfos;

import utest.Runner;
import utest.TestResult;
import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;

/**
* @todo add documentation
*/
class TraceReport {
	var aggregator : ResultAggregator;
	var newline : String;
	var indent : String;
	public function new(runner : Runner) {
		aggregator = new ResultAggregator(runner, true);
		runner.onStart.add(start);
		aggregator.onComplete.add(complete);
#if php
		if(php.Lib.isCli()) {
			newline = "\n";
			indent  = "  ";
		} else {
			newline = "<br>";
			indent  = "&nbsp;&nbsp;";
		}
#elseif neko
		if(neko.Web.isModNeko) {
			newline = "<br>";
			indent  = "&nbsp;&nbsp;";
		} else {
			newline = "\n";
			indent  = "  ";
		}
#else
		newline = "\n";
		indent  = "  ";
#end
	}

	var startTime : Float;
	function start(e) {
		startTime = haxe.Timer.stamp();
	}

	function indents(c : Int) {
		var s = '';
		for(_ in 0...c)
			s += indent;
		return s;
	}

	function complete(result : PackageResult) {
		var end = haxe.Timer.stamp();
#if php
		var scripttime = Std.int(php.Sys.cpuTime()*1000)/1000;
#end
		var time = Std.int((end-startTime)*1000)/1000;
		var buf = new StringBuf();
		buf.add("results: " + (result.stats.isOk ? "ALL TESTS OK" : "SOME TESTS FAILURES")+newline+" "+newline);

		buf.add("assertations: "   + result.stats.assertations+newline);
		buf.add("successes: "      + result.stats.successes+newline);
		buf.add("errors: "         + result.stats.errors+newline);
		buf.add("failures: "       + result.stats.failures+newline);
		buf.add("warnings: "       + result.stats.warnings+newline);
		buf.add("execution time: " + time+newline);
#if php
		buf.add("script time: "    + scripttime+newline);
#end
		buf.add(newline);
		
		for(pname in result.packageNames()) {
			var pack = result.getPackage(pname);
			for(cname in pack.classNames()) {
				var cls = pack.getClass(cname);
				buf.add((pname == '' ? '' : pname+".")+cname+newline);
				for(mname in cls.methodNames()) {
					var fix = cls.get(mname);
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
							case Success(pos):
								buf.add('.');
							case Failure(msg, pos):
								buf.add('F');
								messages += indents(2)+"line: " + pos.lineNumber + ", " + msg + newline;
							case Error(e):
								buf.add('E');
								messages += indents(2)+ Std.string(e) + newline;
							case SetupError(e):
								buf.add('S');
								messages += indents(2)+ Std.string(e) + newline;
							case TeardownError(e):
								buf.add('T');
								messages += indents(2)+ Std.string(e) + newline;
							case TimeoutError(missedAsyncs):
								buf.add('O');
								messages += indents(2)+ "missed async calls: " + missedAsyncs + newline;
							case AsyncError(e):
								buf.add('A');
								messages += indents(2)+ Std.string(e) + newline;
							case Warning(msg):
								buf.add('W');
								messages += indents(2)+ msg + newline;
						}
					}
					buf.add(newline);
					buf.add(messages);
				}
			}
		}
		trace(buf.toString());
	}
}