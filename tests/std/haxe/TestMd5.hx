package std.haxe;

#if haxe3
import haxe.crypto.Md5;
#else
import haxe.Md5;
#end

import utest.Assert;

class TestMd5 {
	public function new(){}

	public function testEmpty(){
		Assert.equals("d41d8cd98f00b204e9800998ecf8427e",Md5.encode(""));
	}

	public function test2(){
		Assert.equals("098f6bcd4621d373cade4e832627b4f6",Md5.encode("test"));
	}

}
