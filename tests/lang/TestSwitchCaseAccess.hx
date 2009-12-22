package lang;

import utest.Assert;

class TestSwitchCaseAccess {
	public function new() {}
	
	public function testIntSwitch() {
		Assert.equals("other", intSwitch(0));
		Assert.equals("one",   intSwitch(1));
		Assert.equals("two",   intSwitch(2));
		Assert.equals("other", intSwitch(3));
	}
	
	static function intSwitch(i : Int) {
		switch(i) {
			case 1:  return "one";
			case 2:  return "two";
			default: return "other";
		}
	}
	
	public function testStringSwitch() {
		Assert.equals(-1, stringSwitch("zero"));
		Assert.equals(1,  stringSwitch("one"));
		Assert.equals(2,  stringSwitch("two"));
		Assert.equals(-1, stringSwitch("three"));
	}
	
	static function stringSwitch(s : String) {
		switch(s) {
			case "one":  return 1;
			case "two":  return 2;
			default: return -1;
		}
	}
	
	public function testCalcSwitch() {
		Assert.equals(-1, calcSwitch(1));
		Assert.equals(2, calcSwitch(2));
		Assert.equals(3, calcSwitch(3));
	}
	
	static function calcSwitch(i : Int) {
		switch(i) {
			case 1+1:  return 2;
			case subtractOne(4):  return 3;
			default: return -1;
		}
	}
	
	static function subtractOne(i : Int) {
	  return i - 1;
	}
	
	public function testSwitchBlock() {
		Assert.equals("one", switch(1) {
			case 1:  "one";
			default: "none";
		});
		
		Assert.equals("none", switch(-1) {
			case 1:  "one";
			default: "none";
		});
	}
}