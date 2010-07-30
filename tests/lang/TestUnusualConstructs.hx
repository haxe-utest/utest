package lang;

import utest.Assert;

class TestUnusualConstructs {
	public function new(){}
	
	var value: Int;

	public function testAssignReturn() {
		var v = setValue(10);
		Assert.equals(10, v);
	}

	public function testBooleanReturn() {
		var v = boolCheck();
		Assert.equals(true, v);
	}

	public function testBooleanReturn2() {
		var v = boolCheck2();
		Assert.equals(true, v);
	}

	private function setValue(v) {
		return value = v;
	}

	private function boolCheck() {
		var a: Int;
		return ((a = 10) == 10);
	}

	private function boolCheck2() {
		var a = 10;
		return (a  == 10);
	}
	
	public function testCreateInstanceAndUse() {
		Assert.equals("test", new TestAndUse().test());
	}
	
	public function testCreateInstanceAndUse2() {
		Assert.equals("test", (new TestAndUse()).test());
	}
	
	public function testCastAndUse() {
		var t = new TestAndUse();
		Assert.equals("test2", (cast t).hiddenTest());
	}
	
	public function testCastAndUse2() {
		var t = new TestAndUse2();
		Assert.equals("test", cast(t, TestAndUse).test());
	}
	
	public function testCreateInstanceAndVal() {
		Assert.equals("val", new TestAndUse().val);
	}
	
	public function testCreateInstanceAndVal2() {
		Assert.equals("val", (new TestAndUse()).val);
	}
	
	public function testCastAndVal() {
		var t = new TestAndUse();
		Assert.equals("val2", (cast t).hiddenVal);
	}
	
	public function testCastAndVal2() {
		var t = new TestAndUse2();
		Assert.equals("val", cast(t, TestAndUse).val);
	}
	
	public function testCastAndSetVal() {
		var t = new TestAndUse();
		(cast t).hiddenVal = "val3";
		Assert.equals("val3", (cast t).hiddenVal);
	}
	
	public function testCastAndSetVal2() {
		var t = new TestAndUse2();
		cast(t, TestAndUse).val = "val4";
		Assert.equals("val4", cast(t, TestAndUse).val);
	}
	
	public function testReturnAndConsumeFunction() {
		
		Assert.equals("test!", getFunction()("!"));
	}
	
	private function getFunction() {
		return f;
	}
	
	private function f(suf : String) {
		return "test" + suf;
	}

        public function testThisCase(){

		var reqAsString = function(req:String){
			return Lambda.map(req.split("\n"),function (line){ return "\""+line;} ).join("\n");
		}

		Assert.equals(reqAsString("A\nB"),"\"A\n\"B");

        }

}

class TestAndUse {
	public var val : String;
	public var hiddenVal : String;
	public function new() {
		val = "val";
		hiddenVal = "val2";
	}
	public function test() { return "test"; }
	private function hiddenTest() { return "test2"; }
}

class TestAndUse2 extends TestAndUse { }