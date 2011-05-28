/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue126
{
	public function new(){}
	
	public function testIssue()
	{
		var a = new T();
		Assert.equals("aa", a.aa);
	}
}

private class T implements Dynamic
{
	public function new()
	{
		for (f in Type.getInstanceFields(Type.getClass(this)))
		{
			var t = this;
			var fun = function() return t.resolve(f);
			Reflect.setField(this, "get_" + f, fun);
		}
	}
	
	function resolve(str:String):Dynamic
	{
		return str;
	}
	
	public var aa(dynamic, dynamic):String;
}