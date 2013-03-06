package std.haxe.io;

import utest.Assert;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class TestBytes {
	public function new(){}

	public function testSimpleStringBlit(){
		var b1 = Bytes.ofString("ABCDE");
		var b2 = Bytes.ofString("12345");
		b1.blit(1, b2, 1, 3);
		Assert.equals("A234E", b1.toString());
	}
	
	public function testSimpleBytesInputOutput1() {
		var o = new BytesOutput();
		o.writeString("ABCDE");
		var i = new BytesInput(o.getBytes());
		Assert.equals(0, i.read(5).compare(Bytes.ofString("ABCDE")));
	}
	
	public function testSimpleBytesInputOutput2() {
		var o = new BytesOutput();
		o.writeByte(0x00);
		o.writeByte(0x01);
		var i = new BytesInput(o.getBytes());
		Assert.equals(0x00, i.readByte());
		Assert.equals(0x01, i.readByte());
	}

	public function testSimpleBytesInputOutput3() {
		var o = new BytesOutput();
		o.writeString("A");
		o.writeString("B");
		var b = o.getBytes();
		var i = new BytesInput(b);
		Assert.equals("AB", i.read(2).toString());
		Assert.equals("AB", b.toString());
	}
	
	public function testSimpleBytesInputOutput4() {
		var o = new BytesOutput();
		o.writeString("A");
		o.writeString("B");
		var b = o.getBytes();
		var i = new BytesInput(b);
		Assert.equals(0, i.read(2).compare(b));
	}

	public function testSimpleBytesInputOutput5() {
		var b = haxe.io.Bytes.ofString("ABCééé\r\n\t");
		var o = new haxe.io.BytesOutput();
		o.writeByte(0x00);
		o.writeByte(0x01);
		o.writeByte(0x02);
		o.writeByte(0x03);
		o.write(b);
		var i = new haxe.io.BytesInput(o.getBytes());
		Assert.equals(0x00, i.readByte());
		Assert.equals(0x01, i.readByte());
		Assert.equals(0x02, i.readByte());
		Assert.equals(0x03, i.readByte());
		Assert.equals(0, i.read(b.length).compare(b));
	}
	
	public function testSimpleBytesInputOutput6() {
		var endian = false;
		var b = haxe.io.Bytes.ofString("ABCééé\r\n\t");
		Assert.equals(12,  b.length);
		b.set(1,0);
		
		var o = new haxe.io.BytesOutput();
		o.bigEndian = endian;
		o.writeByte(0x00);
		o.writeByte(0x01);
		o.writeByte(0x02);
		o.writeByte(0x03);
		o.write(b);
		var i = new haxe.io.BytesInput(o.getBytes());
		i.bigEndian = endian;
		//Assert.equals(endian ? 0x00010203 : 0x03020100, i.readUInt30());
		Assert.equals(0, i.read(b.length).compare(b));
	}
}
