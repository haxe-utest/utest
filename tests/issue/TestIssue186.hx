/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue186
{
	public function new(){}
	
	public function testIsSet()
	{
		Assert.isTrue(isSet());
	}
	
	public function isSet()
	{
		return true;
	}
}