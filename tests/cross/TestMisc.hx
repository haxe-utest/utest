package cross;

import utest.Assert;

enum EmptyEnum {
}

class TestMisc {
	public function new(){}

	#if !(flash8 || flash7 || flash6 || js)
	public function testZero(){
		var s = "x\001\000y";
		Assert.equals(4,s.length);
		Assert.equals(1,s.charCodeAt(1));
		Assert.equals(0,s.charCodeAt(2));
		Assert.equals("y",s.charAt(3));
	}
	#end

	public function testEmptyEnum(){
		try {
			Assert.equals(null,Type.resolveEnum("EmptyEnum"));
		}catch( e : Dynamic )
			Assert.isTrue(true);
	}

	public function testForInt(){
		var sb = new StringBuf();
		for( i in 0...5 ){
			sb.add( Std.string(i) );
		}
		Assert.equals("01234",sb.toString());
	}

	public function testForIntBreak(){
		var sb = new StringBuf();
		for( i in 0...5 ){
			sb.add( Std.string(i) );
			if( i == 2 )
				break;
		}
		Assert.equals("012",sb.toString());
	}

	public function testForIntContinue(){
		var sb = new StringBuf();
		for( i in 0...5 ){
			sb.add( Std.string(i) );
			if( i == 2 )
				continue;
		}
		Assert.equals("01234",sb.toString());
	}

	public function testForIntIter(){
		var sb = new StringBuf();
		var ii = new IntIter(0,5);

		for( i in ii ){
			sb.add( Std.string(i) );
			if( i == 2 ){
				i++;
				continue;
			}
		}
		Assert.equals("01234",sb.toString());
	}
}
