/**
 * ...
 * @author Franco Ponticelli
 */

package std;

import utest.Assert;

class TestLambda
{
	public function new(){}
	
	public function testEmptyParam()
	{
		Assert.raises(function() Lambda.array(null), Dynamic);
	}
}