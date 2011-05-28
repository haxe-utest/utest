/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue191
{
	public function new(){}
	
	public function testInterface()
	{
		var empty = new HasEmpty(); // this triggers the compilation error because empty in IHasEmpty is a reserved word
		Assert.notNull(empty);
	}
}

interface IHasEmpty
{
	public function empty() : Void;
}

class HasEmpty implements IHasEmpty
{
	public function new(){}
	public function empty() : Void {}
}