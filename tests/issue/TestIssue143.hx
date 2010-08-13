/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;
import haxe.Http;

class TestIssue143
{
	public function new();

	public function testIssue()
	{
		var h = new Http("https://www.google.com/");
		h.onData = function(data)
		{
			Assert.notNull(data);
		};
		h.onError = function(e)
		{
			Assert.fail(e);
		};
        h.request(false);
	}
}