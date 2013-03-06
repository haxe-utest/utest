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
		#if haxe3
		Assert.isFalse(StringTools.isEof(t));
		#else
		Assert.isFalse(StringTools.isEOF(t));
		#end
		Assert.equals(97, t);
		t = StringTools.fastCodeAt(s, 4);
		
		#if haxe3
		Assert.isTrue(StringTools.isEof(t));
		#else
		Assert.isTrue(StringTools.isEOF(t));
		#end
	}
}