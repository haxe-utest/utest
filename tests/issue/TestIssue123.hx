/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue123
{
	public function new();
	
	public function testIssue()
	{
		var instance : I = new A();
        Assert.equals("test", cast(instance, A).test());
	}
}

private interface I
{
    function test() : String;
}

private class A implements I
{
    public function new ();
    public function test() {
        return "test";
	}
}
