/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue46
{
	public function new(){}

	public function testIssue()
	{
		Assert.isTrue(proxyIsSet("http://example.com"));
		Assert.isFalse(proxyIsSet(""));
		Assert.isFalse(proxyIsSet(null));
	}
	
	private function proxyIsSet(proxyUrl:String)
	{
        return if (proxyUrl != null && proxyUrl != "" && isValidQueryString(proxyUrl) == true)
			true
		else
			false;
    }
	
	private function isValidQueryString(proxyUrl:String)
	{
		return true;
	}
}