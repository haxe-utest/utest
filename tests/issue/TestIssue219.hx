/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

// this should not compile
class TestIssue219
{
	public function new();
	public function testPushReturnLength()
	{
		var a = [];
		Assert.equals(1, a.push(1));
	}
}