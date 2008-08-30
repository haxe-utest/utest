package utest.ui.text;

import haxe.PosInfos;

import utest.Runner;
import utest.TestResult;
import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;


class TraceReport {
	var aggregator : ResultAggregator;
	var newline : String;
	var indent : String;
	public function new(runner : Runner) {
		aggregator = new ResultAggregator(runner, true);
		aggregator.onComplete = complete;
		aggregator.onStart    = start;
		aggregator.onProgress = progress;
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

	function indents(c : Int) {
		var s = '';
		for(_ in 0...c)
			s += indent;
		return s;
	}

	function start() {

	}

	function complete(result : PackageResult) {
		var buf = new StringBuf();
		buf.add("results: " + (result.isOk ? "ALL TESTS OK" : "SOME TESTS FAILURES")+newline+" "+newline);

		buf.add("assertations: " + result.assertations+newline);
		buf.add("successes: "    + result.successes+newline);
		buf.add("errors: "       + result.errors+newline);
		buf.add("failures: "     + result.failures+newline);
		buf.add("warnings: "     + result.warnings+newline);
		buf.add("total time: "   + result.executionTime+newline);
		buf.add(newline);


		for(pname in result.packageNames()) {
			var pack = result.getPackage(pname);
			for(cname in pack.classNames()) {
				var cls = pack.getClass(cname);
				buf.add(pname+newline);
				for(mname in cls.methodNames()) {
					var fix = cls.get(mname);
					buf.add(indents(1)+mname+": ");
					if(fix.isOk) {
						buf.add("OK ");
					} else if(fix.hasErrors) {
						buf.add("ERROR ");
					} else if(fix.hasFailures) {
						buf.add("FAILURE ");
					} else if(fix.hasWarnings) {
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

	function progress(done : Int, totals : Int) {
	}
}