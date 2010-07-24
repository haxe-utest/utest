/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;
import haxe.Http;

class TestIssue132
{
	public function new();

	public function testIssue()
	{
		Assert.isFalse("00" == "0");
		Assert.isTrue("00" == "00");
		var a = "00";
		var b = "0";
		Assert.isFalse(a == b);
		var a : Dynamic = "00";
		var b : Dynamic = "0";
		Assert.isFalse(a == b);
	}
}