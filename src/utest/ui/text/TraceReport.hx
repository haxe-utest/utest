package utest.ui.text;

import haxe.PosInfos;

import utest.Runner;
import utest.TestResult;

#if js
import js.Dom;
#end

class TraceReport {
	public function new(runner : Runner) {
		runner.onStart    = start;
		runner.onComplete = complete;
		runner.onProgress = progress;
	}

	var counter : Int;

	static inline var STATUS_OK      = 0;
	static inline var STATUS_WARNING = 1;
	static inline var STATUS_FAIL    = 2;
	static inline var STATUS_ERROR   = 3;
	function printResult(result : TestResult) {
		counter++;
		var status   = STATUS_OK;
		var buff     = '';
		var messages = '';
		for(assertation in result.assertations) {
			switch(assertation) {
				case Success(pos):
					buff += '.';
				case Failure(msg, pos):
					if(status < STATUS_FAIL) status = STATUS_FAIL;
					buff += 'F';
					messages += "  line: " + pos.lineNumber + ", " + msg;
				case Error(e):
					if(status < STATUS_ERROR) status = STATUS_ERROR;
					buff += 'E';
					messages += "  " + Std.string(e);
				case SetupError(e):
					if(status < STATUS_ERROR) status = STATUS_ERROR;
					buff += 'S';
					messages += "  " + Std.string(e);
				case TeardownError(e):
					if(status < STATUS_ERROR) status = STATUS_ERROR;
					buff += 'T';
					messages += "  " + Std.string(e);
				case TimeoutError(missedAsyncs):
					if(status < STATUS_ERROR) status = STATUS_ERROR;
					buff += 'O';
					messages += "  " + "missed async calls: " + missedAsyncs;
				case AsyncError(e):
					if(status < STATUS_ERROR) status = STATUS_ERROR;
					buff += 'A';
					messages += "  " + Std.string(e);
				case Warning(msg):
					if(status < STATUS_WARNING) status = STATUS_WARNING;
					buff += 'W';
					messages += "  " + msg;
			}
		}
		var r = switch(status) {
			case STATUS_OK      : "OK";
			case STATUS_WARNING : "WARNING";
			case STATUS_FAIL    : "FAIL";
			case STATUS_ERROR   : "ERROR";
		};
		trace(counter +". "+result.cls + "." + result.method + ": "+r + " " + buff);
		if(messages != '') {
			trace(messages);
		}
	}

	function start(r : Runner) {
		counter = 0;
	}

	function complete(r : Runner) {
		trace("[DONE]");
	}

	function progress(r : Runner, result : TestResult, done : Int, totals : Int) {
		printResult(result);
	}
}