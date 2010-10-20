/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue193
{
	public function new();
	
	public function testUncurry()
	{
		var f = function(v1 : Int) return function(v2 : Int) return v1 + v2;
		Assert.equals(3, uncurry(f)(1, 2));
	}
	
	static function uncurry<P1, P2, R>(f : P1 -> (P2 -> R)) : P1 -> P2 -> R {
		return function(p1 : P1, p2 : P2) {
			return f(p1)(p2);
		}
	}
}