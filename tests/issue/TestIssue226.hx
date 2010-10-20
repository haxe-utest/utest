/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;
#if php
import php.FileSystem;
#end
#if neko
import neko.FileSystem;
#end

class TestIssue226
{
	public function new();
	
	public function testIssue()
	{
		var files = FileSystem.readDirectory(".");
		Assert.isFalse(Lambda.has(files, ".") || Lambda.has(files, ".."));
	}
}