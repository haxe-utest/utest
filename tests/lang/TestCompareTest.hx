package lang;

import utest.Assert;

class TestCompareTest {
	public function new(){}

	var _null : Null<Int>;
	var bnull : Null<Bool>;

	public function testNullInt() {
		Assert.isFalse( _null == 5 );
	}

	public function testNullInt2(){
		Assert.isFalse( _null > 5 );
	}

	#if neko
	public function testNullInt3(){
		Assert.isFalse( _null < 5 );
	}

	public function testNullInt4(){
		Assert.isFalse( _null <= 5 );
	}
	#end

	public function testNullInt5(){
		Assert.isFalse( _null == 0 );
	}

	public function testNullInt6(){
		Assert.isFalse( _null < 0 );
	}

	public function testNullInt7(){
		Assert.isFalse( _null > 0 );
	}

	public function testNullFalse(){
		Assert.isFalse( bnull == false );
	}

	public function testNullTrue(){
		Assert.isFalse( bnull == true );
	}
}