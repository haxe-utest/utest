/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue37
{
	public function new();

	public function testIssue()
	{
		var output = Lambda.foreach(['a', 'b'], function(val : String) {
			var nextPos = cast(Math.min(10, 20), Int);
			return true;
		});
		Assert.isTrue(output);

		var replace = 'abcde';
		var output2 = Lambda.fold(['e'], function(val : String, output3 : String) {
			var nextPos = cast(Math.min(10, 20), Int);
			return output3;
		}, replace);

		Assert.equals("abcde", output2);
	}
}