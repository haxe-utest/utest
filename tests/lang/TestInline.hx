/**
 * ...
 * @author Franco Ponticelli
 */

package lang;

import utest.Assert;

class TestInline
{
	public function new();

	static inline function foo(x) return x + 5

	public function testInline() {
		// check that operations are correctly generated
		var x = 3; // prevent optimization
		Assert.equals(16, 2 * foo(x));
	}
}