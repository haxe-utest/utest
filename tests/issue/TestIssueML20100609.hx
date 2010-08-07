/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssueML20100609
{

	public function new();
#if php
	public function testIssue()
	{
		Assert.isTrue(rootFolder.length > 0);
	}
	
	public static var rootFolder(getRootFolder, setRootFolder):String;
	
	static function __init__ () {
        rootFolder = untyped __php__("dirname(__FILE__)");
    }
	
    static function getRootFolder ():String {
        return rootFolder;
    }

    static function setRootFolder (folder:String):String {
        return rootFolder = folder;
    }
#end
}