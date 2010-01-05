/**
 * ...
 * @author Franco Ponticelli
 */

package lang;

import utest.Assert;

class TestDefaultArguments
{
	public function new();

	static function f(?a : Null<Int> = 1, ?pos : haxe.PosInfos)
	{
		return a;
	}

	public function testWithPosInfos()
	{
		Assert.equals(1, f());
	}
}