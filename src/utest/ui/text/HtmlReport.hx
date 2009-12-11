package utest.ui.text;

import haxe.PosInfos;
import haxe.Timer;

import utest.Runner;
import utest.TestResult;
import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;
import utest.ui.common.ResultStats;
import haxe.Stack;

/**
* @todo add documentation
*/
class HtmlReport {
	public var traceRedirected(default, null) : Bool;
	
	var aggregator : ResultAggregator;
	var outpudtandler : String -> Void;
	var returnFullPage : Bool;
	var oldTrace : Dynamic;
	var _traces : Array<{ msg : String, infos : PosInfos, time : Float, delta : Float, stack : Array<StackItem> }>;
	
	public function new(runner : Runner, outpudtandler : String -> Void, returnFullPage = false, traceRedirected = true) {
		aggregator = new ResultAggregator(runner, true);
		runner.onStart.add(start);
		aggregator.onComplete.add(complete);
		this.outpudtandler = outpudtandler;
		this.returnFullPage = returnFullPage;
		if (traceRedirected)
			redirectTrace();
	}
	
	public function redirectTrace()
	{
		if (traceRedirected)
			return;
		_traces = [];
		oldTrace = haxe.Log.trace;
		haxe.Log.trace = _trace;
	}
	
	public function restoreTrace()
	{
		if (!traceRedirected)
			return;
		haxe.Log.trace = oldTrace;
	}

	var _traceTime : Null<Float>;
	function _trace(v : Dynamic, ?infos : PosInfos)
	{
		var time = Timer.stamp();
		var delta = _traceTime == null ? 0 : time - _traceTime;
		_traces.push( {
			msg : Std.string(v),
			infos : infos,
			time : time - startTime,
			delta : delta,
			stack : Stack.callStack()
		} );
		_traceTime = Timer.stamp();
	}
	
	var startTime : Float;
	function start(e) {
		startTime = Timer.stamp();
	}
	
	function cls(stats : ResultStats)
	{
		if (stats.hasErrors)
			return 'error';
		else if (stats.hasFailures)
			return 'failure';
		else if (stats.hasWarnings)
			return 'warn';
		else
			return 'ok';
	}
	
	function addTitle(buf : StringBuf, stats : ResultStats, time : Float)
	{
		var msg = 'TESTS ARE OK';
		if (stats.hasErrors)
			msg = 'TESTS HAVE ERRORS';
		else if (stats.hasFailures)
			msg = 'TESTS ARE FAILED';
		else if (stats.hasWarnings)
			msg = 'WARNINGS REPORTED';
			
		buf.add('<h1 class="' + cls(stats) + 'bg header">' + msg + "</h1>\n");
		var platform = #if neko 'neko' #elseif php 'php' #else 'unknown' #end;
		buf.add('<div class="headerinfo">');
		
//		buf.add(' ');
		resultNumbers(buf, stats);
//		buf.add('');
		buf.add(' performed on <strong>' + platform + '</strong>, executed in <strong> ' + time + ' sec. </strong></div >\n ');
	}
	
	function resultNumbers(buf : StringBuf, stats : ResultStats)
	{
		var numbers = [];
		if (stats.assertations == 1)
			numbers.push('<strong>1</strong> test');
		else
			numbers.push('<strong>' + stats.assertations + '</strong> tests');
		
		if (stats.successes != stats.assertations)
		{
			if (stats.successes == 1)
				numbers.push('<strong>1</strong> pass');
			else if (stats.successes > 0)
				numbers.push('<strong>' + stats.successes + '</strong> passes');
		}
		
		if (stats.errors == 1)
			numbers.push('<strong>1</strong> error');
		else if (stats.errors > 0)
			numbers.push('<strong>' + stats.errors + '</strong> errors');
			
		if (stats.failures == 1)
			numbers.push('<strong>1</strong> failure');
		else if (stats.failures > 0)
			numbers.push('<strong>' + stats.failures + '</strong> failures');
			
		if (stats.warnings == 1)
			numbers.push('<strong>1</strong> warning');
		else if (stats.warnings > 0)
			numbers.push('<strong>' + stats.warnings + '</strong> warnings');
		
		buf.add(numbers.join(', '));
	}
	
	function blockNumbers(buf : StringBuf, stats : ResultStats)
	{
		buf.add('<div class="' + cls(stats) + 'bg statnumbers">');
		resultNumbers(buf, stats);
		buf.add('</div>');
	}
	
	function formatStack(stack : Array<StackItem>, addNL = true)
	{
		var parts = [];
		var nl = addNL ? '\n' : '';
		for (part in Stack.toString(stack).split('\n'))
		{
			if (StringTools.trim(part) == '')
				continue;
			if ( -1 < part.indexOf('Called from utest.'))
				continue;
#if neko
			if ( -1 < part.indexOf('Called from a C function'))
				continue;
#end
			parts.push(part);
		}
		
		var s = '<ul><li>' + parts.join('</li>'+nl+'<li>') + '</li></ul>'+nl;
		
		return "<div>" + s + "</div>"+nl;
	}
	
	function addPackage(buf : StringBuf, result : PackageResult)
	{
		buf.add('<ul>\n');
		for (pname in result.packageNames(false))
		{
			var pack = result.getPackage(pname);
			if (pname == '' && pack.classNames().length == 0) continue;
			buf.add('<li>');
			buf.add('<h2>' + pname + '</h2>');
			blockNumbers(buf, pack.stats);
			buf.add('<ul>\n');
			for (cname in pack.classNames())
			{
				buf.add('<li>');
				var c = pack.getClass(cname);
				buf.add('<h2 class="classname">' + cname + '</h2>');
				blockNumbers(buf, c.stats);
				buf.add('<ul>\n');
				for (mname in c.methodNames()) {
					buf.add('<li class="fixture"><div class="li">');
					var fix = c.get(mname);
					buf.add('<span class="' + cls(fix.stats) + 'bg fixtureresult">');
					if(fix.stats.isOk) {
						buf.add("OK ");
					} else if(fix.stats.hasErrors) {
						buf.add("ERROR ");
					} else if(fix.stats.hasFailures) {
						buf.add("FAILURE ");
					} else if(fix.stats.hasWarnings) {
						buf.add("WARNING ");
					}
					buf.add('</span>');
					buf.add('<div class="fixturedetails">');
					buf.add('<strong>' + mname + '</strong>');
					buf.add(': ');
					resultNumbers(buf, fix.stats);
					var messages = [];
					for(assertation in fix.iterator()) {
						switch(assertation) {
							case Success(pos):
							case Failure(msg, pos):
								messages.push("<strong>line " + pos.lineNumber + "</strong>: <em>" + msg + "</em>");
							case Error(e, s):
								messages.push("<strong>error</strong>: <em>" + Std.string(e) + "</em>\n" + formatStack(s));
							case SetupError(e, s):
								messages.push("<strong>setup error</strong>: " + Std.string(e) + "\n" + formatStack(s));
							case TeardownError(e, s):
								messages.push("<strong>tear-down error</strong>: " + Std.string(e) + "\n" + formatStack(s));
							case TimeoutError(missedAsyncs, s):
								messages.push("<strong>missed async call(s)</strong>: " + missedAsyncs);
							case AsyncError(e, s):
								messages.push("<strong>async error</strong>: " + Std.string(e) + "\n" + formatStack(s));
							case Warning(msg):
								messages.push( msg);
						}
					}
					if (messages.length > 0)
					{
						buf.add('<div class="testoutput">');
						buf.add(messages.join('<br/>'));
						buf.add('</div>\n');
					}
					buf.add('</div>\n');
					buf.add('</div></li>\n');
				}
				buf.add('</ul>\n');
				buf.add('</li>\n');
			}
			buf.add('</ul>\n');
			// classes
			// sub packages
			buf.add('</li>\n');
		}
		buf.add('</ul>\n');
	}
	
	function complete(result : PackageResult) {
		var end = haxe.Timer.stamp();
		var time = Std.int((end-startTime)*1000)/1000;
		var buf = new StringBuf();
		addTitle(buf, result.stats, time);
		addTrace(buf);
		addPackage(buf, result);
		if(returnFullPage)
			outpudtandler(wrapHtml(buf.toString()));
		else
			outpudtandler(buf.toString());
		restoreTrace();
	}
	
	
	function addTrace(buf : StringBuf)
	{
		if (_traces == null || _traces.length == 0) return;
		buf.add('<div class="trace"><h2>traces</h2><ol>');
		var lastmethod = null;
		for (t in _traces)
		{
			buf.add('<li><div class="li">');
			var stack = StringTools.replace(formatStack(t.stack, false), "'", "\\'");
			var method = '<span class="tracepackage">' + t.infos.className + "</span><br/>" + t.infos.methodName + "(" + t.infos.lineNumber + ")";
			if (lastmethod != method)
			{
				buf.add('<span class="tracepos" onmouseover="utestTooltip(this.parentNode, \'' + stack + '\')" onmouseout="utestRemoveTooltip()">');
				buf.add(method);
				lastmethod = method;
			} else {
				buf.add('<span class="traceposempty">');
				buf.add('&nbsp;');
			}
			
			// time
			buf.add('</span><span class="tracetime">');
			buf.add("@ " + formatTime(t.time));
			if(Math.round(t.delta * 1000) > 0)
				buf.add(", ~" + formatTime(t.delta));
			
			buf.add('</span><span class="tracemsg">');
			buf.add(StringTools.replace(StringTools.trim(t.msg), "\n", "<br/>\n"));
			
			buf.add('</span><div class="clr"></div></div></li>');
		}
		buf.add('</ol></div>');
	}
	
	function formatTime(t : Float)
	{
		return Math.round(t * 1000) + " ms";
	}
	
	function wrapHtml(s : String)
	{
		return '<head>\n<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />\n<title>utest</title><style type="text/css">
body, dd, dt {
	font-family: Verdana, Arial, Sans-serif;
	font-size: 12px;
}
dl {
	width: 180px;
}
dd, dt {
	margin : 0;
	padding : 2px 5px;
	border-top: 1px solid #f0f0f0;
	border-left: 1px solid #f0f0f0;
	border-right: 1px solid #CCCCCC;
	border-bottom: 1px solid #CCCCCC;
}
dd.value {
	text-align: center;
	background-color: #eeeeee;
}
dt {
	text-align: left;
	background-color: #e6e6e6;
	float: left;
	width: 100px;
}

h1, h2, h3, h4, h5, h6 {
	margin: 0;
	padding: 0;
}

h1 {
	text-align: center;
	font-weight: bold;
	padding: 5px 0 4px 0;
	font-family: Arial, Sans-serif;
	font-size: 18px;
	border-top: 1px solid #f0f0f0;
	border-left: 1px solid #f0f0f0;
	border-right: 1px solid #CCCCCC;
	border-bottom: 1px solid #CCCCCC;
	margin: 0 2px 0px 2px;
}

h2 {
	font-weight: bold;
	padding: 2px 0 2px 8px;
	font-family: Arial, Sans-serif;
	font-size: 13px;
	border-top: 1px solid #f0f0f0;
	border-left: 1px solid #f0f0f0;
	border-right: 1px solid #CCCCCC;
	border-bottom: 1px solid #CCCCCC;
	margin: 0 0 0px 0;
	background-color: #FFFFFF;
	color: #777777;
}

h2.classname {
	color: #000000;
}

.okbg {
	background-color: #66FF55;
}
.errorbg {
	background-color: #CC1100;
}
.failurebg {
	background-color: #EE3322;
}
.warnbg {
	background-color: #FFCC99;
}
.headerinfo {
	text-align: right;
	font-size: 11px;
	font - color: 0xCCCCCC;
	margin: 0 2px 5px 2px;
/*	border-top: 1px solid #f0f0f0; */
	border-left: 1px solid #f0f0f0;
	border-right: 1px solid #CCCCCC;
	border-bottom: 1px solid #CCCCCC;
	padding: 2px;
}

li {
	padding: 4px;
	margin: 2px;
	border-top: 1px solid #f0f0f0;
	border-left: 1px solid #f0f0f0;
	border-right: 1px solid #CCCCCC;
	border-bottom: 1px solid #CCCCCC;
	background-color: #e6e6e6;
}

li.fixture {
	background-color: #f6f6f6;
	padding-bottom: 6px;
}

div.fixturedetails {
	padding-left: 108px;
}

ul {
	padding: 0;
	margin: 6px 0 0 0;
	list-style-type: none;
}

ol {
	padding: 0 0 0 28px;
	margin: 0px 0 0 0;
}

.statnumbers {
	padding: 2px 8px;
}

.fixtureresult {
	width: 100px;
	text-align: center;
	display: block;
	float: left;
	font-weight: bold;
	padding: 1px;
	margin: 0 0 0 0;
}

.testoutput {
	border: 1px dashed #CCCCCC;
	margin: 4px 0 0 0;
	padding: 4px 8px;
	background-color: #eeeeee;
}

span.tracepos, span.traceposempty {
	display: block;
	float: left;
	font-weight: bold;
	font-size: 9px;
	width: 170px;
	margin: 2px 0 0 2px;
}

span.tracepos:hover {
	cursor : pointer;
	background-color: #ffff99;
}

span.tracemsg {
	display: block;
	margin-left: 180px;
	background-color: #eeeeee;
	padding: 7px;
}

span.tracetime {
	display: block;
	float: right;
	margin: 2px;
	font-size: 9px;
	color: #777777;
}


div.trace ol {
	padding: 0 0 0 40px;
	color: #777777;
}

div.trace li {
	padding: 0;
}

div.trace li div.li {
	color: #000000;
}

div.trace h2 {
	margin: 0 2px 0px 2px;
	padding-left: 4px;
}

.tracepackage {
	color: #777777;
	font-weight: normal;
}

.clr {
	clear: both;
}

#utesttip {
	margin-top: -3px;
	margin-left: 170px;
	font-size: 9px;
}

#utesttip li {
	margin: 0;
	background-color: #ffff99;
	padding: 2px 4px;
	border: 0;
	border-bottom: 1px dashed #ffff33;
}

</style>
<script type="text/javascript">
function utestTooltip(ref, text) {
	var el = document.getElementById("utesttip");
	if(!el) {
		var el = document.createElement("div")
		el.id = "utesttip";
		el.style.position = "absolute";
		document.body.appendChild(el)
	}
	var p = utestFindPos(ref);
//	alert(p);
	el.style.left = p[0];
	el.style.top = p[1];
	
	el.innerHTML =  text;
}

function utestFindPos(el) {
	var left = 0;
	var top = 0;
	do {
		left += el.offsetLeft;
		top += el.offsetTop;
	} while(el = el.offsetParent)
	return [left, top];
}

function utestRemoveTooltip() {
	var el = document.getElementById("utesttip")
	if(el)
		document.body.removeChild(el)
}
</script>
</head>\n<body>\n'
			+ s +
			'\n</body>\n</html>';
	}
}