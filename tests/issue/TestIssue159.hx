/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue159
{
	public function new();
	
	public function testIssue()
	{
		var s = switch(true) {
			case true:
				if ( true ) {
					var f = false;
					while( f ) {}
				}
				1;
		}
			
		Assert.equals(1, s);
	}
}