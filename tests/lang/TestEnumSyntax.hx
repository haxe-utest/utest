package lang;

import utest.Assert;

import lang.util.Quantity;

class TestEnumSyntax {
	public function new() {}
	
	public function testEmptyInstance() {
	  var e = None;
	  Assert.notNull(e);
	}
	
	public function testParamInstance() {
	  var e = One(1);
	  Assert.notNull(e);
	}
	
	public function testParamsInstance() {
	  var e = Two(1, 2);
	  Assert.notNull(e);
	}
}