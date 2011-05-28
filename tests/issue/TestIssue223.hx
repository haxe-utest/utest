/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue223
{
	public function new(){}
	
	public function testIssue()
	{
		var steps = 0;
		var toggle = 'on';
		while (true)
		{
			switch(toggle)
			{
				case 'on':
					Assert.equals(0, steps++);
					toggle = 'off';
					// should skip the rest of the while loop,
					// but instead it skips the rest of the switch
					continue;
				case 'off':
					Assert.equals(1, steps++);
					break;
			}
			// never get here
			steps++;
			Assert.fail("should never reach this point");
		}
		Assert.equals(2, steps++);
	}
}