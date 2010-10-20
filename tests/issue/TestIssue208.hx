/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

// this should not compile
class TestIssue208
{
	public function new();
	public var foo : String;
}

class SubTestIssue208 extends TestIssue208
{
	static public var foo : String;
}