/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue163
{
	public function new();
	
	public function testIssue4()
	{
		var s = Std.string(0.1);
		Assert.is(s, String);
	}
}