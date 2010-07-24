/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue36
{
	public function new();

	public function testIssue()
	{
		var b = true;
		var r = if (b) {
			var s = "a\\b;;c";
			s.split("\\").join("/").split(';;').join("/");
		} else "";
		Assert.equals("a/b/c", r);
	}
}