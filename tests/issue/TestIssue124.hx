/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue124
{
	public var prop(getProp, setProp):String;
	public var prop2(getProp, null):String;

	public function new(){}
	
	public function getProp()
	{
        if (this.prop == null)
		{
            this.prop = "foo";
		}
		return this.prop;
	}
	
	public function setProp(p:String)
	{
			return this.prop = p;
	}

	
	public function testIssue()
	{
		Assert.equals("foo", prop);
		Assert.equals("foo", prop2);
	}
}