package issue;

import utest.Assert;

class TestIssueMy001
{
	public function new(){}
	
	public function testIssue()
	{
		var t = true;
		var v = try inside(t) catch ( e : Dynamic ) 1;
		Assert.equals(1, v);
	}
	
	public static inline function inside(v)
	{
		if (v)
			throw "error";
		return 2;
	}
}