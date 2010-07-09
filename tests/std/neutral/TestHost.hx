package std.neutral;

import utest.Assert;

#if neko
import neko.net.Host;
#elseif php
import php.net.Host;
#elseif cpp
import cpp.net.Host;
#end

class TestHost {
	public function new() { }

	public function testHost() {
		var host = new Host('127.0.0.1');
		Assert.equals(16777343, haxe.Int32.toInt(host.ip));
		Assert.equals('127.0.0.1', host.toString());
	}

#if php
	public function testHostByName() {
		if (php.Lib.isCli())
		{
			Assert.warn("this test can only be run in a webserver");
			return;
		}
		var local = Host.localhost();
		Assert.notNull(local);
		var host = new Host(local);
		Assert.equals(16777343, haxe.Int32.toInt(host.ip));
		Assert.equals('127.0.0.1', host.toString());
	}
#end
}