package std.neutral;

import utest.Assert;

#if neko
import neko.net.Host;
import neko.net.Socket;
#elseif php
import php.net.Host;
import php.net.Socket;
#end


class TestSocket {
	public function new() {}
	
	public function testConnect() {
		var s = new Socket();
		s.connect(new Host('127.0.0.1'), 80);
		s.output.writeString('GET / HTTP/1.0\r\nHost: localhost\r\nAccept: */*\r\n\r\n');
		var r = s.input.readLine();
		Assert.equals('HTTP/1.1 200 OK', r);
		s.close();
	}
}