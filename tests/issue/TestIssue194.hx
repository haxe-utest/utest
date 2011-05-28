/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue194
{
	public function new(){}
	
	static function encode(v : String)
	{
		return ~/("|\\)/g.replace(v, "\\$1");
	}
	
	public function testReplace()
	{
		Assert.equals('\\"foo\\"', encode('"foo"'));
		Assert.equals("\\\\foo\\\\", encode("\\foo\\"));
	}
}