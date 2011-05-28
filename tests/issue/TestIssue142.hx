/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;
import haxe.Http;

class TestIssue142
{
	public function new(){}

	public function testIssue()
	{
		Assert.equals(0, Type.enumIndex(B));
		Assert.equals(1, Type.enumIndex(A));
		Assert.same(B, Type.createEnumIndex(MyEnum, 0));
		Assert.same(A, Type.createEnumIndex(MyEnum, 1));
	}
}

private enum MyEnum
{
	B;
	A;
}