/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue190
{
	public function new();
	
	public function testList()
	{
		var list = new List(); // this triggers the compilation error because List cannot be found
		Assert.notNull(list);
	}
}

class List
{
	public function new();
}