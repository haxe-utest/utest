package std.neutral;

import utest.Assert;

#if php
import php.FileSystem;
import php.io.File;
import php.Sys;
import php.Web;
#elseif neko
import neko.FileSystem;
import neko.io.File;
import neko.Sys;
import neko.Web;
#elseif cpp
import cpp.FileSystem;
import cpp.io.File;
import cpp.Sys;
#end

class TestFileSystem {
	public function new(){}
	
	static function testfile()
	{
		var file = #if neko "neko.test" #else "php.test" #end;
		return base() + "/" + file;
	}
	
	static function testdir()
	{
		var dir = #if neko "testdirneko" #else "testdirphp" #end;
		return base() + "/" + dir;
	}
	
	static function t1()
	{
		return testdir() + "/temp1";
	}
	
	static function t2()
	{
		return testdir() + "/temp2";
	}
	
	static function base()
	{
		var dir = Sys.getCwd();
#if (php || neko)
		if ("/" == dir || "\\" == dir)
			dir = Web.getCwd();
#end
		var last = dir.substr( -1);
		if ("/" == last || "\\" == last)
			dir = dir.substr(0, -1);
		return dir;
	}

	public static function aggressiveDelete(path : String)
	{
		var c = 0;
		// TODO: this should not be required but a simple delete
		// fails on Neko
		while (FileSystem.exists(path) && c < 10)
		{
			var done = false;
			try {
				if (FileSystem.isDirectory(path))
					FileSystem.deleteDirectory(path);
				else
					FileSystem.deleteFile(path);
				done = true;
			} catch (e : Dynamic) { }
			if (done) break;
			c++;
		}
	}
	
	public function teardown() {
		aggressiveDelete(testfile());
		aggressiveDelete(t1());
		aggressiveDelete(t2());
		aggressiveDelete(testdir());
	}

	public function testExists() {
		Assert.isTrue(FileSystem.exists(base()));
		Assert.isFalse(FileSystem.exists(base()+"/unexistent"));
	}

	public function testCreateRenameDelete() {
		try {
			FileSystem.createDirectory(testdir());
			Assert.isTrue(FileSystem.exists(testdir()));
			FileSystem.createDirectory(t1());
			Assert.isTrue(FileSystem.exists(t1()));
			FileSystem.rename(t1(), t2());
			Assert.isFalse(FileSystem.exists(t1()));
			Assert.isTrue(FileSystem.exists(t2()));
			Assert.isTrue(FileSystem.isDirectory(t2()));
			FileSystem.deleteDirectory(t2());
			Assert.isFalse(FileSystem.exists(t2()));
		} catch(e : Dynamic) {
			Assert.fail();
		}
		if(FileSystem.exists(t1()))
			FileSystem.deleteDirectory(t1());
		if(FileSystem.exists(t2()))
			FileSystem.deleteDirectory(t2());
		if(FileSystem.exists(testdir()))
			FileSystem.deleteDirectory(testdir());
	}

	public function testStat() {
		createTestFile();
		var s = FileSystem.stat(testfile());
		Assert.isTrue(s.size > 0);
	}

	public function testFullPath() {
		Assert.isTrue(FileSystem.fullPath("../").length > 0);
	}

	public function testKind() {
		createTestFile();
		var k = FileSystem.kind(testfile());
		Assert.equals(FileKind.kfile, k);
		FileSystem.createDirectory(testdir());
		k = FileSystem.kind(testdir());
		Assert.equals(FileKind.kdir, k);
	}


	public function testDeleteFile() {
		Assert.isFalse(FileSystem.exists(testfile()));
		createTestFile();
		Assert.isTrue(FileSystem.exists(testfile()));
		TestFileSystem.aggressiveDelete(testfile());
		Assert.isFalse(FileSystem.exists(testfile()));
	}

	public function testReadDirectory() {
		FileSystem.createDirectory(testdir());
		createTestFile();
		var dir = FileSystem.readDirectory(base());
		Assert.isTrue(dir.length >= 2);
		
		Assert.contains(testdir().split('/').pop(), dir);
		Assert.contains(testfile().split('/').pop(), dir);
	}

	function contains(arr : Array<String>, what : String) {
		for(v in arr)
			if(what == v) return true;
		return false;
	}

	function createTestFile() {
// requires php.io.File.putContent();
#if php
	php.io.File.putContent(testfile(), "x");
#elseif neko
	var fo = neko.io.File.write(testfile(), false);
	fo.writeString("x");
	fo.close();
#end
	}

}