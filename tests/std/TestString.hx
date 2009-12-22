package std;

import utest.Assert;

class TestString {
	public function new(){}

	var _null : Null<Int>;

	public function testSub(){
		Assert.equals("","".substr(-1,5));
	}

	public function testSub2(){
		Assert.equals("9","0123456789".substr(-1,1));
	}

	public function testSub3(){
		Assert.equals("56","0123456789".substr(-5,2));
	}

	public function testSub4(){
		Assert.equals("01234","0123456789".substr(0,-5));
	}

	public function testSub5(){
		Assert.equals("56789","0123456789".substr(-5,10));
	}

	public function testSub6(){
		Assert.equals("56789","0123456789".substr(5,10));
	}

	public function testSub7(){
		var s = "0123456789";
		Assert.equals("56789",s.substr(5,s.length));
		Assert.equals("56789",s.substr(5));
	}

	public function testSub9(){
		Assert.equals("01234","0123456789".substr(_null,5));
	}

	public function testSub10(){
		Assert.equals("abc","abc".substr(-5,5));
	}

	public function testSub12(){
		Assert.equals("","0123456789".substr(1,-1));
	}

	public function testSub13(){
		Assert.equals("","0123456789".substr(-1,-1));
	}

	public function testSub14(){
		Assert.equals("012345678","0123456789".substr(_null,-1));
	}

	public function testSub15(){
		Assert.equals("","".substr(5,2));
	}

	public function testSub16(){
		Assert.equals("89","0123456789".substr(-2));
	}

	public function testSub17(){
		Assert.equals("0123456789","0123456789".substr(_null));
	}

	public function testLastIndexOf(){
		var str = "c:\\great\\stuff";
		Assert.equals(8,str.lastIndexOf("\\",str.length));
		Assert.equals(8,str.lastIndexOf("\\"));
		Assert.equals(-1,str.lastIndexOf("\\",0));
	}
}