package utest.ui.text;

import haxe.PosInfos;
import utest.ui.common.IReport;
import utest.ui.common.HeaderDisplayMode;

import utest.Runner;
import utest.TestResult;
import utest.ui.common.ResultAggregator;
using utest.ui.common.ReportTools;
import utest.ui.common.PackageResult;
import haxe.Stack;

/**
* @todo add documentation
*/
class StringReport implements IReport {
	public var displaySuccessResults : SuccessResultsDisplayMode;
	public var displayHeader : HeaderDisplayMode;
	
	var aggregator : ResultAggregator;
	var newline : String;
	var indent : String;
	var outputHandler : String -> Void;
	public function new(runner : Runner, outputHandler : String -> Void) {
		aggregator = new ResultAggregator(runner, true);
		runner.onStart.add(start);
		aggregator.onComplete.add(complete);
		this.outputHandler = outputHandler;
		displaySuccessResults = AlwaysShowSuccessResults;
		displayHeader = AlwaysShowHeader;
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
	
	function dumpStack(stack : Array<StackItem>)
	{
		if (stack.length == 0)
			return "";
		
		var parts = Stack.toString(stack).split("\n");
		var r = [];
		for (part in parts)
		{
			if (part.indexOf(" utest.") >= 0) continue;
			r.push(part);
		}
		return r.join(newline);
	}

	function addHeader(buf : StringBuf, result : PackageResult)
	{
		if (!this.hasHeader(result.stats))
			return;
		
		var end = haxe.Timer.stamp();
#if php
		var scripttime = Std.int(php.Sys.cpuTime()*1000)/1000;
#end
		var time = Std.int((end-startTime)*1000)/1000;
		
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
	}

	function complete(result : PackageResult) {
		
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
							case Success(pos):
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
						}
					}
					buf.add(newline);
					buf.add(messages);
				}
			}
		}
		outputHandler(buf.toString());
	}
}