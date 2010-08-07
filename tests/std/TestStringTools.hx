package std;

import utest.Assert;

class TestStringTools {
	public function new(){}

	var _null : Null<Int>;

	public function testUrlEncode(){
		Assert.equals("abcdefghij",StringTools.urlEncode("abcdefghij"));
	}

	public function testUrlEncode2(){
		Assert.equals("%3D%20%C3%A9",StringTools.urlEncode("= é"));
	}

	public function testUrlDecode(){
		Assert.equals("abcdefghij",StringTools.urlDecode("abcdefghij"));
	}

	public function testUrlDecode2(){
		Assert.equals("= é",StringTools.urlDecode("%3D%20%C3%A9"));
	}

	public function testUrlDecode3(){
		Assert.equals("= é",StringTools.urlDecode("%3D+%C3%A9"));
	}

	public function testUnhtml(){
		Assert.equals("&lt;a href=\"\"&gt;Coucou &amp;gt;&lt;/a&gt;",StringTools.htmlEscape("<a href=\"\">Coucou &gt;</a>"));
	}

	public function testRehtml(){
		Assert.equals("<a href=\"\">Coucou &gt;</a>",StringTools.htmlUnescape("&lt;a href=\"\"&gt;Coucou &amp;gt;&lt;/a&gt;"));
	}

	public function testStartsWith(){
		Assert.isTrue( StringTools.startsWith("0123456789","0123") );
	}

	public function testStartsWith2(){
		Assert.isFalse( StringTools.startsWith("0123456789","1234") );
	}

	public function testStartsWith3(){
		Assert.isFalse( StringTools.startsWith("0123456789","01234567890") );
	}

	public function testEndsWith(){
		Assert.isTrue( StringTools.endsWith("0123456789","6789") );
	}

	public function testEndsWith2(){
		Assert.isFalse( StringTools.endsWith("0123456789","5678") );
	}

	public function testEndsWith3(){
		Assert.isFalse( StringTools.endsWith("0123456789","01234567890") );
	}

	public function testRtrim(){
		Assert.equals("  test",StringTools.rtrim("  test "));
	}

	public function testLtrim(){
		Assert.equals("test ",StringTools.ltrim("  test "));
	}

	public function testTrim(){
		Assert.equals("test",StringTools.trim("  test  "));
	}

	public function testTrim2(){
		Assert.equals("",StringTools.trim("  \t  "));
	}

	public function testTrim3(){
		Assert.equals("lala",StringTools.trim("  \t\r\nlala\r\n\r  "));
	}

	public function testRpad(){
		Assert.equals("heheabcab",StringTools.rpad("hehe","abc",9));
	}

	public function testRpad2(){
		Assert.equals("hehe",StringTools.rpad("hehe","abc",3));
	}

	public function testLpad(){
		Assert.equals("abcabhehe",StringTools.lpad("hehe","abc",9));
	}

	public function testLpad2(){
		Assert.equals("hehe",StringTools.lpad("hehe","abc",3));
	}
	
	public function testHex()
	{
		Assert.equals("96B43F", StringTools.hex(9876543));
	}
	
	public function testHex2()
	{
		Assert.equals("0004D2", StringTools.hex(1234, 6));
	}
/*
	public function testBaseEncode1(){
		Assert.equals("706F7565743D3F",StringTools.baseEncode("pouet=?","0123456789ABCDEF"));
	}

	public function testBaseDecode1(){
		Assert.equals("pouet=?",StringTools.baseDecode("706F7565743D3F","0123456789ABCDEF"));
	}
	*/
}