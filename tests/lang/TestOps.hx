package lang;

import utest.Assert;

class TestOps 
{
	public function new(){}
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
		
		Assert.isTrue( 3 == 7 >> 1 );
		
		Assert.equals( 5 % 3 * 4, 8 );
		Assert.equals( (5 % 3) * 4, 8 );
		Assert.equals( 5 % (3 * 4), 5 );
		
		Assert.equals( 20 / 2 / 2, 5 );
		Assert.equals( (20 / 2) / 2, 5 );
		Assert.equals( 20 / (2 / 2), 20 );
	}
}