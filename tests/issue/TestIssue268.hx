/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue268
{
	public function new(){}
	
	public function testIssue()
	{
		var s = "haxe";
		var t = StringTools.fastCodeAt(s, 1);
		Assert.isFalse(StringTools.isEOF(t));
		Assert.equals(97, t);
		t = StringTools.fastCodeAt(s, 4);
		Assert.isTrue(StringTools.isEOF(t));
	}
}