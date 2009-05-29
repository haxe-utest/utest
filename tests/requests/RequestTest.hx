package tests.requests;

import utest.Assert;
import utest.Runner;
import utest.ui.text.TraceReport;

#if php
import php.Web;
#elseif neko
import neko.Web;
#elseif flash
import flash.external.ExternalInterface;
#end

class RequestTest {
	static inline var TIMEOUT = 500;
	public function new();
	
	public static function main() {
		var runner = new Runner();
		runner.addCase(new RequestTest());
		var report = new TraceReport(runner);
		runner.run();
	}

	public function testWorkingHttp() {
		var requestor = new haxe.Http( getUrl("real.html") );
		requestor.onData = Assert.createEvent(onData, TIMEOUT);
		requestor.request(false);
	}

	public function testFailingHttp() {
		var requestor = new haxe.Http( getUrl("fake.html") );
		requestor.onError = Assert.createEvent(onExpectedError, TIMEOUT);
		requestor.request(false);
	}

	function onData(msg:String) {
		Assert.isTrue(StringTools.startsWith(msg.toLowerCase(), "<html"));
    }

	public function onExpectedError(msg:String) {
		Assert.notNull(msg);
	}

	static function getUrl(path : String) {
#if (php || neko)
		var uri = Web.getURI();
		uri = uri.substr(0, uri.lastIndexOf("/")+1);
		return "http://"+Web.getClientHeader("HOST")+uri+"../files/"+(path == null? '': path);
#elseif js
		var uri : String = Std.string(js.Lib.window.location);
		uri = uri.substr(0, uri.lastIndexOf("/")+1);
		return uri+"files/"+(path == null? '': path);
#elseif (flash9 || flash8)
		var uri : String = ExternalInterface.call("window.location.href.toString");
		uri = uri.substr(0, uri.lastIndexOf("/")+1);
		return uri+"files/"+(path == null? '': path);
#elseif flash
// TODO: find a way to autodetect this
		return "http://localhost/utest/files/"+path;
#end
	}
}
