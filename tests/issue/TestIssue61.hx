/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue61
{
	public function new();
	
	public function testIssue()
	{
		Assert.equals(2.0, abs( -2.0));
	}
	
	public static inline function abs(a:Float) (return a < 0 ? -a : a)
}