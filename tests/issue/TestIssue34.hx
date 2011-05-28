package issue;

import utest.Assert;

class TestIssue34
{
	public function new(){}
	
	public function testIssueReference()
	{
		untyped __call__("ob_start");
		var a = new TestPrint(php.Lib.print);
		new TestPrint(php.Lib.print).printMe();
		var r : String = untyped __call__("ob_get_contents");
		untyped __call__("ob_end_clean");
		Assert.equals("test", r);
	}
}

private class TestPrint
{
	var output : Dynamic -> Void;
	
	public static function main()
	{
		new TestPrint(function(v : Dynamic) { trace(v); }).printMe();
		new TestPrint(php.Lib.print).printMe();
	}
	
	public function new(output : Dynamic -> Void)
	{
		this.output = output;
	}
	
	public function printMe()
	{
		output('test');
	}
}