package std.neutral;

import utest.Assert;

#if php
import php.FileSystem;
import php.io.File;
import php.Sys;
#else
import neko.FileSystem;
import neko.io.File;
import neko.Sys;
#end

class TestFileSystem {
	var base : String;
	var testdir : String;
	var testfile : String;
	var t1 : String;
	var t2 : String;
	static var filename = #if neko "neko.test" #else "php.test" #end;
	static var dirname = #if neko "testdirneko" #else "testdirphp" #end;
	public function new() {
		base = Sys.getCwd();
		var last = base.substr(-1);
		if(last == '/' || last == '\\')
			base = base.substr(0, -1);
		testdir = base + "/" + dirname;
		testfile = base + "/" + filename;
		t1 = testdir + "/temp1";
		t2 = testdir + "/temp";
	}

	public function teardown() {
		if(FileSystem.exists(testfile))
			FileSystem.deleteFile(testfile);
		if(FileSystem.exists(t1))
			FileSystem.deleteDirectory(t1);
		if(FileSystem.exists(t2))
			FileSystem.deleteDirectory(t2);
		if(FileSystem.exists(testdir))
			FileSystem.deleteDirectory(testdir);
	}

	public function testExists() {
		Assert.isTrue(FileSystem.exists(base));
		Assert.isFalse(FileSystem.exists(base+"/unexistent"));
	}

	public function testCreateRenameDelete() {
		try {
			FileSystem.createDirectory(testdir);
			Assert.isTrue(FileSystem.exists(testdir));
			FileSystem.createDirectory(t1);
			Assert.isTrue(FileSystem.exists(t1));
			FileSystem.rename(t1, t2);
			Assert.isFalse(FileSystem.exists(t1));
			Assert.isTrue(FileSystem.exists(t2));
			Assert.isTrue(FileSystem.isDirectory(t2));
			FileSystem.deleteDirectory(t2);
			Assert.isFalse(FileSystem.exists(t2));
		} catch(e : Dynamic) {
			Assert.fail();
		}
		if(FileSystem.exists(t1))
			FileSystem.deleteDirectory(t1);
		if(FileSystem.exists(t2))
			FileSystem.deleteDirectory(t2);
		if(FileSystem.exists(testdir))
			FileSystem.deleteDirectory(testdir);
	}

	public function testStat() {
		createTestFile();
		var s = FileSystem.stat("file://"+testfile);
		Assert.isTrue(s.size > 0);
	}

	public function testFullPath() {
		Assert.isTrue(FileSystem.fullPath("../").length > 0);
	}

	public function testKind() {
		createTestFile();
		var k = FileSystem.kind(testfile);
		Assert.equals(FileKind.kfile, k);
		FileSystem.createDirectory(testdir);
		k = FileSystem.kind(testdir);
		Assert.equals(FileKind.kdir, k);
	}


	public function testDeleteFile() {
		Assert.isFalse(FileSystem.exists(testfile));
		createTestFile();
		Assert.isTrue(FileSystem.exists(testfile));
		FileSystem.deleteFile(testfile);
		Assert.isFalse(FileSystem.exists(testfile));
	}

	public function testReadDirectory() {
		FileSystem.createDirectory(testdir);
		createTestFile();
		var dir = FileSystem.readDirectory(base);
		Assert.isTrue(dir.length >= 2);
		Assert.isTrue(contains(dir, dirname));
		Assert.isTrue(contains(dir, filename));
	}

	function contains(arr : Array<String>, what : String) {
		for(v in arr)
			if(what == v) return true;
		return false;
	}

	function createTestFile() {
// requires php.io.File.putContent();
#if php
	php.io.File.putContent(testfile, "x");
#elseif neko
	var fo = neko.io.File.write(testfile, false);
	fo.writeString("x");
	fo.close();
#end
	}

}