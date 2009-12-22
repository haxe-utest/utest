package std.neutral;

import utest.Assert;
import haxe.io.Error;

#if php
import php.io.Process;
#else
import neko.io.Process;
#end

class TestProcess {
	public function new() { }
	public function testPhpProcess() {
		var process = new Process('php', []);
		process.stdin.writeString('<?php echo("haXe"); ?>');
		process.stdin.close();
		var out = null;
		try {
			out = process.stdout.readAll().toString();
		} catch(e : Error) {
//			trace(e);
//			trace(process.stderr.readAll().toString());
			Assert.fail();
		}
		Assert.equals('haXe', out);
	}
}