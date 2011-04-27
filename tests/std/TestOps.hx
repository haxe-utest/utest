package std;

/**
 * ...
 * @author Franco Ponticelli
 */

import utest.Assert;

class TestOps 
{
	public function testOps()
	{
		Assert.equals(1 + 2 + "", "3");
		Assert.equals((1 + 2) + "", "3");
		Assert.equals(1 + (2 + ""), "12");

		Assert.equals(4 - 3 + "", "1");
		Assert.equals((4 - 3) + "", "1");
		//Assert.equals(4 - (3 + ""), "1");

		Assert.equals(4 | 3 & 1, 1);
		Assert.equals((4 | 3) & 1, 1);
		Assert.equals(4 | (3 & 1), 5);

		Assert.equals(4 & 3 | 1, 1);
		Assert.equals((4 & 3) | 1, 1);
		Assert.equals(4 & (3 | 1), 0);

		Assert.equals( - 5 + 1, -4 );
		Assert.equals( - (5 + 1), -6 );

		Assert.isTrue( 5 << 2 == 20 );
		Assert.isTrue( (5 << 2) == 20 );
		Assert.isTrue( 20 == 5 << 2 );
		Assert.isTrue( 20 == (5 << 2) );

		Assert.equals( 5 % 3 * 4, 8 );
		Assert.equals( (5 % 3) * 4, 8 );
		Assert.equals( 5 % (3 * 4), 5 );

		Assert.equals( 20 / 2 / 2, 5 );
		Assert.equals( (20 / 2) / 2, 5 );
		Assert.equals( 20 / (2 / 2), 20 );

		Assert.equals( 2 << 3 >> 1, 8 );
		Assert.equals( (2 << 3) >> 1, 8 );
		Assert.equals( 2 << (3 >> 1), 4 );

		Assert.isFalse( (1 & 0x8000) != 0 );
		Assert.isFalse( 1 & 0x8000 != 0 );
		Assert.isFalse( 0 != (1 & 0x8000) );
		Assert.isFalse( 0 != 1 & 0x8000 );

		Assert.equals( 5 * 10 % 3, 5);
		Assert.equals( 5 * (10 % 3), 5);
		Assert.equals( (5 * 10) % 3, 2);

		Assert.equals( 10 % 3 * 5, 5);
		Assert.equals( (10 % 3) * 5, 5);
		Assert.equals( 10 % (3 * 5), 10);

		Assert.equals( true ? 1 : 6 * 5, 1);
		Assert.equals( false ? 1 : 6 * 5, 30);
		Assert.equals( (true ? 1 : 6) * 5, 5);
		Assert.equals( (false ? 1 : 6) * 5, 30);
		
		Assert.equals( 1 + (5 == 6 ? 4 : 1), 2 );
		Assert.equals( 1 + 1 == 3 ? 1 : 5, 5 );
		
		Assert.equals( -3 == 3 ? 0 : 1, 1 );
		Assert.isTrue( !true ? true : true );
	
		var k = false;
		Assert.isFalse(k = true ? false : true);
		Assert.isFalse(k);
		Assert.isFalse((k = true) ? false : true);
		Assert.isTrue(k);
		
		Assert.isTrue( true || false && false );
		
		var x = 1;
		Assert.equals( -x++, -1);
		Assert.equals( -x--, -2);
		
		Assert.equals( ("bla" + "x").indexOf("x"), 3);
	}
	
	public function new();
}