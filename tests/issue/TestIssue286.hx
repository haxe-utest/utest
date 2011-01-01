/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue286
{
	public function new();
	
	public function testIssue()
	{
		var f = function () return true;
		var a = function () return 1;
		var b = function () return 2;
		var t = true;
		Assert.equals(1, cond(t, a, b));
		Assert.equals(1, foo(f, a, b));
		Assert.equals(1, bar(f, a, b));
		Assert.equals(1, bar2(f, a, b));
	}
	
	static public inline function cond(c, a, b)
	{
		return c ? a() : b();
	}
	
	static public inline function foo(f,a,b):Int 
	{
		return f() ? a() : b();
	}
	
	static public inline function bar(f,a,b):Int 
	{
		return if(f()) a() else b();
	}
	
	static public inline function bar2(f,a,b):Int 
	{
		if(f()) return a() else return b();
	}
}