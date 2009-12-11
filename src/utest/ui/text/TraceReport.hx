package utest.ui.text;

import haxe.PosInfos;

import utest.Runner;
import utest.TestResult;
import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;
import haxe.Stack;

/**
* @todo add documentation
*/
class TraceReport extends StringReport {
	var newline : String;
	var indent : String;
	public function new(runner : Runner) {
		super(runner, _trace);
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

	function _trace(s : String) {
		s = StringTools.replace(s, '  ', indent);
		s = StringTools.replace(s, '\n', newline);
		trace(s);
	}
}