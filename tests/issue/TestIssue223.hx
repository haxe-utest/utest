/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue223
{
	public function new();
	
	public function testIssue()
	{
		var toggle = 'on';
		while (true)
		{
			switch(toggle)
			{
				case 'on':
					toggle = 'off';
					// should skip the rest of the while loop,
					// but instead it skips the rest of the switch
					continue;
				case 'off':
					break;
			}
			Assert.fail("should never reach this point");
		}
	}
}