package utest.ui.macro;

import haxe.macro.Context;
import haxe.PosInfos;
import neko.Lib;
import utest.ui.common.IReport;
import utest.ui.common.HeaderDisplayMode;

import utest.Runner;
import utest.TestResult;
import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;
import haxe.Stack;

using utest.ui.common.ReportTools;
using StringTools;

/**
* @todo add documentation
*/
class MacroReport 
{
	public function new(runner : Runner) 
	{
		runner.onStart.add(start);
		runner.onProgress.add(testDone);
		runner.onComplete.add(complete);
	}
	
	var startTime : Float;
	var totalTests : Int;
	var failedTests : Int;
	var testWarnings : Int;
	
	function start(e) 
	{
		totalTests = 0;
		failedTests = 0;
		testWarnings = 0;
		
		startTime = haxe.Timer.stamp();
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
		return r.join("\n");
	}

	// { setup => null, assertations => {Failure(expected 1 but was 3,{ className => UtestClass, fileName => src/UtestClass.hx, methodName => testHello, lineNumber => 20 })}, 
	// pack => , cls => UtestClass, teardown => null, method => testHello }
	function testDone(test : { result : TestResult, done : Int, totals : Int } )
	{
		for (assertation in test.result.assertations)
		{
			totalTests++;
			failedTests++;
			
			switch(assertation)
			{
				case Success(pos):
					failedTests--;
				case Failure(msg, pos):
					trace(pos.fileName + ":" + pos.lineNumber + ": " + msg, Context.currentPos());
				case Error(e, s):
					trace(Std.string(e) + ", see output for stack.", Context.currentPos());
					Lib.print(dumpStack(s));
				case SetupError(e, s):
					trace(Std.string(e) + ", see output for stack.", Context.currentPos());
					Lib.print(dumpStack(s));
				case TeardownError(e, s):
					trace(Std.string(e) + ", see output for stack.", Context.currentPos());
					Lib.print(dumpStack(s));
				case TimeoutError(missedAsyncs, s):
					trace("missed async calls: " + missedAsyncs + ", see output for stack.", Context.currentPos());
					Lib.print(dumpStack(s));
				case AsyncError(e, s):
					trace(Std.string(e) + ", see output for stack.", Context.currentPos());
					Lib.print(dumpStack(s));
				case Warning(msg):
					failedTests--;
					testWarnings++;
					trace(msg);
			}
		}
	}
	
	function complete(runner : Runner)
	{
		var end = haxe.Timer.stamp();
		var time = Std.string(Std.int((end - startTime) * 1000) / 1000);
		
		if (time.endsWith("."))
			time = time.substr(0, -1);
		
		trace("uTest results: " + totalTests + " tests run, " + failedTests + " failed, " + testWarnings + " warnings. Execution time: " + time + "ms.");
	}	
}
