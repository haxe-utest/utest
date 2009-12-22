package std.haxe;

import utest.Assert;

class TestMd5 {
	public function new(){}

	public function testEmpty(){
		Assert.equals("d41d8cd98f00b204e9800998ecf8427e",haxe.Md5.encode(""));
	}

	public function test2(){
		Assert.equals("098f6bcd4621d373cade4e832627b4f6",haxe.Md5.encode("test"));
	}

}
