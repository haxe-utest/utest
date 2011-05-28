/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue229
{
	public function new(){}
	
#if php
	public function testIssue()
	{
		var a = php.Lib.toPhpArray([]);
		Assert.isTrue(untyped __call__("is_array", a));
	}
#end
}