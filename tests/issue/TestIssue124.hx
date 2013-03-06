/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue124
{
	@:isVar public var prop(get_prop, set_prop):String;
	@:isVar public var prop2(get_prop2, null):String;

	public function new(){}
	
	public function get_prop()
	{
        if (this.prop == null)
		{
            this.prop = "foo";
		}
		return this.prop;
	}
	
	public function set_prop(p:String)
	{
			return this.prop = p;
	}
	
	public function get_prop2() { return get_prop(); }

	
	public function testIssue()
	{
		Assert.equals("foo", prop);
		Assert.equals("foo", prop2);
	}
}