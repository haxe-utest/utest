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

class TestFile {
	static function testfile()
	{
		var file = #if neko "neko.test" #else "php.test" #end;
		return base() + "/" + file;
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
	
	public function new();

	public function teardown() {
		TestFileSystem.aggressiveDelete(testfile());
	}

	public function testOutput() {
		var out = File.write(testfile(), false);
		out.writeString('haxe\nneko\nphp');
		out.close();

		var input = File.read(testfile(), false);
		Assert.equals('h'.charCodeAt(0), input.readByte());
		Assert.equals('axe\n', input.readString(4));
		Assert.equals('neko', input.readLine());
		Assert.equals('php', input.readAll().toString());
		input.close();
	}

	public function testBin() {
		var out = File.write(testfile(), true);
		out.write(haxe.io.Bytes.ofString('haxe'));
		out.writeByte(46);
		out.writeBytes(haxe.io.Bytes.ofString('haxehaxe'), 2, 4);
		out.writeDouble(-123456789.23456789);
		out.writeFloat(-1.23456);
		out.writeInt16(99);
		out.writeInt32(haxe.Int32.ofInt(1000));

		out.close();

		var input = File.read(testfile(), true);
		Assert.equals('haxe', input.readString(4));
		Assert.equals(46, input.readByte());
		var b = haxe.io.Bytes.ofString('    ');
		Assert.equals(2, input.readBytes(b, 1, 2));
		Assert.equals(' xe ', b.toString());
		Assert.equals('ha', input.readString(2));
		Assert.floatEquals(-123456789.23456789, input.readDouble());
		Assert.floatEquals(-1.23456, input.readFloat());
		Assert.equals(99, input.readInt16());
		Assert.equals(1000, haxe.Int32.toInt(input.readInt32()));
		input.close();
	}
}