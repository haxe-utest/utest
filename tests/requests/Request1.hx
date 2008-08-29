package tests.requests;

import utest.Assert;
import utest.Assertation;
import utest.TestFixture;
import utest.TestHandler;
import utest.Runner;
import utest.ui.text.TraceReport;

class Request1 {
	
	static inline var TIMEOUT = 500;
	
	static function main() {
		//var t = new Request1();
		//t.testRequest();
		//t.testRequestFail();
		
		var r = new Runner();
		r.addCase(new RequestTest());
		var report = new TraceReport(r);
		r.run();
		
	}
	
	public function new();
	
	// #1 - asynchronous usage
	function testRequest() {
		var testCase = new RequestTest();
		var fixture = new TestFixture(testCase, "testHttp");
		var handler = new TestHandler(fixture);
		
		var async = handler.addAsync(function(){ trace("running async"); }, TIMEOUT);
		testCase.onFinish = async;
		
		handler.onTimeout = function(h) {
			trace("TIMEOUT");
		}
		
		handler.onComplete = function(h) {
			trace("COMPLETE");
			var results = handler.results;
			
			if (h.results.length != 1) {
				trace("FAIL (wrong number of results ("+h.results.length+"))");
			} else {
				switch(h.results.pop()) {
					case Success(p):
						trace("OK #1");
					default:
						trace("FAIL (expected success)");
				}
			}
		}
		
		handler.execute();
	}
	
	// #2 - asynchronous usage with a failure
	function testRequestFail() {
		var testCase = new RequestTest();
		var fixture = new TestFixture(testCase, "testHttpFail");
		var handler = new TestHandler(fixture);
		
		var async = handler.addAsync(function(){ trace("running async"); }, TIMEOUT);
		testCase.onFinish = async;
		
		handler.onTimeout = function(h) {
			trace("TIMEOUT");
		}
		
		handler.onComplete = function(h) {
			trace("COMPLETE");
			var results = handler.results;
			
			if (h.results.length != 1) {
				trace("FAIL (wrong number of results ("+h.results.length+"))");
			} else {
				switch(h.results.pop()) {
					case Failure(msg , pos ):
						trace("OK #2");
					default:
						trace("FAIL (expected failure)");
				}
			}
		}
		
		handler.execute();
	}
}

class RequestTest {
	
	// Edit url to match your server.
	private static var baseURL = "http://localhost:8888/utest/requests/";
	
	// A handle on the returned function from addAsync().
	public var onFinish : Void->Void;
	
	public function new();
	
	/*
		Makes a http request that will work.
	*/
	public function testHttp() {
		var requestor = new haxe.Http( baseURL + "hello.html" );
		requestor.onData = onData;
		requestor.onError = onError;
		requestor.request(false);
	}
	
	/*
		Makes a http request that will not work.
	*/
	public function testHttpFail() {
		var requestor = new haxe.Http( baseURL + "doesntexist.html" );
		requestor.onData = onData;
		requestor.onError = onError;
		requestor.request(false);
	}
	
	/*
		Handles results from SUCCESSFUL http requests.
	*/
	function onData(msg:String) {
		trace(msg);
		Assert.equals("<P>hello world</P>", msg);
		onFinish();
    }
	
	/*
		Handles results from UNSUCCESSFUL http requests.
	*/
	public function onError(msg:String) {
		trace(msg);
		Assert.fail(msg);
		onFinish();
	}
	
}