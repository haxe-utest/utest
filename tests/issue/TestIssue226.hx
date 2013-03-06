/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;
#if sys
import sys.FileSystem;
#end

class TestIssue226
{
	public function new(){}
	
	public function testIssue()
	{
		var files = FileSystem.readDirectory(".");
		Assert.isFalse(Lambda.has(files, ".") || Lambda.has(files, ".."));
	}
}