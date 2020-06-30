package utest.ui.text;

import haxe.PosInfos;
import haxe.Timer;
import utest.ui.common.ClassResult;
import utest.ui.common.FixtureResult;
import utest.ui.common.IReport;
import utest.ui.common.HeaderDisplayMode;
import utest.utils.Misc;
import utest.Runner;
import utest.ui.common.ResultAggregator;
import utest.ui.common.PackageResult;
import utest.ui.common.ResultStats;

import haxe.CallStack;

using utest.ui.common.ReportTools;

#if php
import php.Lib;
#elseif neko
import neko.Lib;
#elseif cpp
import cpp.Lib;
#elseif js
import js.Browser;
#end

class HtmlReport implements IReport<HtmlReport> {
  static var platform = #if neko 'neko' #elseif php 'php'  #elseif cpp 'cpp'  #elseif js 'javascript' #elseif flash 'flash' #else 'unknown' #end;

  public var traceRedirected(default, null) : Bool;
  public var displaySuccessResults : SuccessResultsDisplayMode;
  public var displayHeader : HeaderDisplayMode;
  public var handler : HtmlReport -> Void;

  var aggregator : ResultAggregator;
  var oldTrace : Dynamic;
  var _traces : Array<{ msg : String, infos : PosInfos, time : Float, delta : Float, stack : Array<StackItem> }>;

  public function new(runner : Runner, ?outputHandler : HtmlReport -> Void, traceRedirected = true) {
    aggregator = new ResultAggregator(runner, true);
    runner.onStart.add(start);
    aggregator.onComplete.add(complete);
    if (null == outputHandler)
      setHandler(_handler);
    else
      setHandler(outputHandler);
    if (traceRedirected)
      redirectTrace();
    displaySuccessResults = AlwaysShowSuccessResults;
    displayHeader = AlwaysShowHeader;
  }

  public function setHandler(handler : HtmlReport -> Void) : Void
    this.handler = handler;

  public function redirectTrace() {
    if (traceRedirected)
      return;
    _traces = [];
    oldTrace = haxe.Log.trace;
    haxe.Log.trace = _trace;
  }

  public function restoreTrace() {
    if (!traceRedirected)
      return;
    haxe.Log.trace = oldTrace;
  }

  var _traceTime : Null<Float>;
  function _trace(v : Dynamic, ?infos : PosInfos) {
    var time = Timer.stamp();
    var delta = _traceTime == null ? 0 : time - _traceTime;
    _traces.push({
      msg : StringTools.htmlEscape(Std.string(v)),
      infos : infos,
      time : time - startTime,
      delta : delta,
      stack : CallStack.callStack()
    });
    _traceTime = Timer.stamp();
  }

  var startTime : Float;
  function start(e)
    startTime = Timer.stamp();

  function cls(stats : ResultStats) {
    if (stats.hasErrors)
      return 'error';
    else if (stats.hasFailures)
      return 'failure';
    else if (stats.hasWarnings)
      return 'warn';
    else
      return 'ok';
  }

  function resultNumbers(buf : StringBuf, stats : ResultStats) {
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

  function blockNumbers(buf : StringBuf, stats : ResultStats) {
    buf.add('<div class="' + cls(stats) + 'bg statnumbers">');
    resultNumbers(buf, stats);
    buf.add('</div>');
  }

  function formatStack(stack : Array<StackItem>, addNL = true) {
    var parts = [];
    var nl = addNL ? '\n' : '';
    var last = null;
    var count = 1;
    for (part in CallStack.toString(stack).split('\n')) {
      if (StringTools.trim(part) == '')
        continue;
      if ( -1 < part.indexOf('Called from utest.'))
        continue;
#if neko
      if ( -1 < part.indexOf('Called from a C function'))
        continue;
#end
      if (part == last) {
        parts[parts.length - 1] = part + " (#" + (++count) + ")";
      } else {
        count = 1;
        parts.push(last = part);
      }
    }

    var s = '<ul><li>' + parts.join('</li>'+nl+'<li>') + '</li></ul>'+nl;
    return "<div>" + s + "</div>"+nl;
  }

  function addFixture(buf : StringBuf, result : FixtureResult, name : String, isOk : Bool) {
    if (this.skipResult(result.stats, isOk)) return;
    buf.add('<li class="fixture"><div class="li">');
    buf.add('<span class="' + cls(result.stats) + 'bg fixtureresult">');
    if(result.stats.isOk) {
      buf.add("OK ");
    } else if(result.stats.hasErrors) {
      buf.add("ERROR ");
    } else if(result.stats.hasFailures) {
      buf.add("FAILURE ");
    } else if(result.stats.hasWarnings) {
      buf.add("WARNING ");
    }
    buf.add('</span>');
    buf.add('<div class="fixturedetails">');
    buf.add('<strong>' + name + '</strong>');
    buf.add(': ');
    resultNumbers(buf, result.stats);
    var messages = [];
    for(assertation in result.iterator()) {
      switch(assertation) {
        case Success(_):
        case Failure(msg, pos):
          messages.push("<strong>line " + pos.lineNumber + "</strong>: <em>" + StringTools.htmlEscape(msg) + "</em>");
        case Error(e, s):
          messages.push("<strong>error</strong>: <em>" + getErrorDescription(e) + "</em>\n<br/><strong>stack</strong>:" + getErrorStack(s, e));
        case SetupError(e, s):
          messages.push("<strong>setup error</strong>: " + getErrorDescription(e) + "\n<br/><strong>stack</strong>:" + getErrorStack(s, e));
        case TeardownError(e, s):
          messages.push("<strong>tear-down error</strong>: " + getErrorDescription(e) + "\n<br/><strong>stack</strong>:" + getErrorStack(s, e));
        case TimeoutError(missedAsyncs, _):
          messages.push("<strong>missed async call(s)</strong>: " + missedAsyncs);
        case AsyncError(e, s):
          messages.push("<strong>async error</strong>: " + getErrorDescription(e) + "\n<br/><strong>stack</strong>:" + getErrorStack(s, e));
        case Warning(msg):
          messages.push(StringTools.htmlEscape(msg));
        case Ignore(reason):
          messages.push(StringTools.htmlEscape(reason));

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

  function getErrorDescription(e : Dynamic) {
#if flash9
    if (Misc.isOfType(e, flash.errors.Error)) {
      var err = cast(e, flash.errors.Error);
      return err.name + ": " + err.message;
    } else {
      return Std.string(e);
    }
#else
    return Std.string(e);
#end
  }

  function getErrorStack(s : Array<StackItem>, e : Dynamic) {
#if flash9
    if (Misc.isOfType(e, flash.errors.Error)) {
      var stack = cast(e, flash.errors.Error).getStackTrace();
      if (null != stack) {
        var parts = stack.split("\n");
        // cleanup utest calls
        var result = [];
        for (p in parts)
          if (p.indexOf("at utest::") < 0)
            result.push(p);
        // pops the last 2 calls
        result.pop();
        result.pop();
        return result.join("<br/>");
      }
    }
    return formatStack(s);
#else
    return formatStack(s);
#end
  }

  function addClass(buf : StringBuf, result : ClassResult, name : String, isOk : Bool) {
    if (this.skipResult(result.stats, isOk)) return;
    buf.add('<li>');
    buf.add('<h2 class="classname">' + name + '</h2>');
    blockNumbers(buf, result.stats);
    buf.add('<ul>\n');
    for (mname in result.methodNames()) {
      addFixture(buf, result.get(mname), mname, isOk);
    }
    buf.add('</ul>\n');
    buf.add('</li>\n');
  }

  function addPackages(buf : StringBuf, result : PackageResult, isOk : Bool) {
    if (this.skipResult(result.stats, isOk)) return;
    buf.add('<ul id="utest-results-packages">\n');
    for (name in result.packageNames(false)) {
      addPackage(buf, result.getPackage(name), name, isOk);
    }
    buf.add('</ul>\n');
  }

  function addPackage(buf : StringBuf, result : PackageResult, name : String, isOk : Bool) {
    if (this.skipResult(result.stats, isOk)) return;
    if (name == '' && result.classNames().length == 0) return;
    buf.add('<li>');
    buf.add('<h2>' + name + '</h2>');
    blockNumbers(buf, result.stats);
    buf.add('<ul>\n');
    for (cname in result.classNames())
      addClass(buf, result.getClass(cname), cname, isOk);
    buf.add('</ul>\n');
    buf.add('</li>\n');
  }

  public function getTextResults() : String {
    var newline = "\n";
    function indents(count : Int) {
      return [for(i in 0...count) "  "].join("");
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
    var buf = new StringBuf();
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


  public function getHeader() : String {
    var buf = new StringBuf();
    if (!this.hasHeader(result.stats))
      return "";

    var end = haxe.Timer.stamp();
    var time = Std.int((end-startTime)*1000)/1000;
    var msg = 'TEST OK';
    if (result.stats.hasErrors)
      msg = 'TEST ERRORS';
    else if (result.stats.hasFailures)
      msg = 'TEST FAILED';
    else if (result.stats.hasWarnings)
      msg = 'WARNING REPORTED';

    buf.add('<h1 class="' + cls(result.stats) + 'bg header">' + msg + "</h1>\n");
    buf.add('<div class="headerinfo">');

    resultNumbers(buf, result.stats);
    buf.add(' performed on <strong>' + platform + '</strong>, executed in <strong> ' + time + ' sec. </strong></div >\n ');
    return buf.toString();
  }

  public function getTrace() : String {
    var buf = new StringBuf();
    if (_traces == null || _traces.length == 0)
      return "";
    buf.add('<div class="trace"><h2>traces</h2><ol>');
    for (t in _traces) {
      buf.add('<li><div class="li">');
      var stack = StringTools.replace(formatStack(t.stack, false), "'", "\\'");
      var method = '<span class="tracepackage">' + t.infos.className + "</span><br/>" + t.infos.methodName + "(" + t.infos.lineNumber + ")";
      buf.add('<span class="tracepos" onmouseover="utestTooltip(this.parentNode, \'' + stack + '\')" onmouseout="utestRemoveTooltip()">');
      buf.add(method);

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
    return buf.toString();
  }

  public function getResults() : String {
    var buf = new StringBuf();
    addPackages(buf, result, result.stats.isOk);
    return buf.toString();
  }

  public function getAll() : String {
    if (!this.hasOutput(result.stats))
      return "";
    else
      return getHeader() + getTrace() + getResults();
  }

  public function getHtml(?title : String) : String {
    if(null == title)
      title = "utest: " + platform;
    var s = getAll();
    if ('' == s)
      return '';
    else
      return wrapHtml(title, s);
  }

  var result : PackageResult;
  function complete(result : PackageResult) {
    this.result = result;
    handler(this);
    restoreTrace();

    var exposedResult = {
      isOk : result.stats.isOk,
      message : getTextResults()
    };

    #if js
    if(#if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end("'undefined' != typeof window")) {
      #if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end("window").utest_result = exposedResult;
    }
    #elseif flash
      flash.external.ExternalInterface.call('(function(result){ window.utest_result = result; })', exposedResult );
    #end
  }

  function formatTime(t : Float)
    return Math.round(t * 1000) + " ms";

  function cssStyle()
    return 'body, dd, dt {
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
}';

  function jsScript()
    return
'function utestTooltip(ref, text) {
  var el = document.getElementById("utesttip");
  if(!el) {
    var el = document.createElement("div")
    el.id = "utesttip";
    el.style.position = "absolute";
    document.body.appendChild(el)
  }
  var p = utestFindPos(ref);
  el.style.left = (4 + p[0]) + "px";
  el.style.top = (p[1] - 1) + "px";
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
}';

  function wrapHtml(title : String, s : String)
    return
      '<head>\n<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />\n<title>' + title + '</title>
      <style type="text/css">' + cssStyle() + '</style>
      <script type="text/javascript">\n' + jsScript() + '\n</'+'script>\n</head>
      <body>\n'+ s + '\n</body>\n</html>';

  function _handler(report : HtmlReport) {
#if (php || neko || cpp || java || lua)
    Sys.stdout().writeString(report.getHtml());
#elseif js
    if(Browser.document.readyState == 'loading') {
      function onReadyStateChange() {
        if(Browser.document.readyState != 'loading') {
          Browser.document.removeEventListener('readystatechange', onReadyStateChange);
          _handler(report);
        }
      }
      Browser.document.addEventListener('readystatechange', onReadyStateChange);
      return;
    }

    var isDef = function(v) : Bool return #if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end("typeof v != 'undefined'");
    var hasProcess : Bool = #if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end("typeof process != 'undefined'");

    if(hasProcess) {
      #if (haxe_ver >= 4.0) js.Syntax.code #else untyped __js__ #end("process.stdout.write")(report.getHtml());
      return;
    }

    var head = Browser.document.getElementsByTagName("head")[0];
    // add script
    var script = Browser.document.createElement('script');
    untyped script.type = 'text/javascript';
    var sjs = report.jsScript();
    untyped if (isDef(script.text)) {
      script.text = sjs;
    } else {
      script.innerHTML = sjs;
    }
    head.appendChild(script);

    // add style
    var style = Browser.document.createElement('style');
    untyped style.type = 'text/css';

    var scss = report.cssStyle();
    untyped
    if (isDef(style.styleSheet)) {
      style.styleSheet.cssText = scss;
    } else if (isDef(style.cssText)) {
      style.cssText = scss;
    } else if (isDef(style.innerText)) {
      style.innerText = scss;
    } else {
      style.innerHTML = scss;
    }
    head.appendChild(style);

    // add content
    var el = Browser.document.getElementById("utest-results");
    if (null == el) {
      el = Browser.document.createElement("div");
      el.id = "utest-results";
      Browser.document.body.appendChild(el);
    }
    el.innerHTML = report.getAll();
#elseif flash
    var quote = function(s : String) {
      s = StringTools.replace(s, '\r', '');
      s = StringTools.replace(s, '\n', '\\n');
      s = StringTools.replace(s, '"', '\\"');
      return '"' + s + '"';
    };

    var fHeader = "function() {
var head = document.getElementsByTagName('head')[0];
// add script
var script = document.createElement('script');
script.type = 'text/javascript';
script.innerHTML = " + quote(report.jsScript()) + ";
head.appendChild(script);
// add style
var isDef = function(v) { return typeof v != 'undefined'; };
var style = document.createElement('style');
style.type = 'text/css';
var styleContent = " + quote(report.cssStyle()) + ";
if (isDef(style.cssText))
{
  style.cssText = styleContent;
} else if (isDef(style.innerText)) {
  style.innerText = styleContent;
} else {
  style.innerHTML = styleContent;
}
head.appendChild(style);
if(typeof utest == 'undefined')
  utest = { };
utest.append_result = function(s) {
  var el = document.getElementById('utest-results');
  if (null == el) {
    el = document.createElement('div');
    el.id = 'utest-results';
    document.body.appendChild(el);
  }
  el.innerHTML += s;
};
utest.append_package = function(s) {
  var el = document.getElementById('utest-results-packages');
  el.innerHTML += s;
};
}";
    var fResult = "function() { utest.append_result(" + quote(report.getAll().substr(0, 7000)) + "); }";

    var ef = function(s : String) { flash.external.ExternalInterface.call('(' + s + ')()'); };
    var er = function(s : String) { ef("function() { utest.append_result(" + quote(s) + "); }"); };
    var ep = function(s : String) { ef("function() { utest.append_package(" + quote(s) + "); }"); };

    var me = this;
    haxe.Timer.delay(function() {
      ef(fHeader);
      er(report.getHeader());
      er(report.getTrace());
      if (me.skipResult(me.result.stats, me.result.stats.isOk)) return;
      er('<ul id="utest-results-packages"></ul>');

      for (name in me.result.packageNames(false))
      {
        var buf = new StringBuf();
        me.addPackage(buf, me.result.getPackage(name), name, me.result.stats.isOk);
        ep(buf.toString());
      }
    }, 100);
#else
    throw "no default handler for this platform";
#end
  }
}
