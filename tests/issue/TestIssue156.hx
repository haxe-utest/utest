/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue156
{
	public var x : Int;
	public function new()
	{
		x = 7;
	}
#if php
	public function testFieldOnString()
	{
		var s = "haXehaXe";

		var f = Reflect.field(s, 'charAt');
		Assert.equals("X", f(2));
		
		var f = Reflect.field(s, 'charCodeAt');
		Assert.equals(88, f(2));
		
		var f = Reflect.field(s, 'indexOf');
		Assert.equals(2, f('X'));
		
		var f = Reflect.field(s, 'lastIndexOf');
		Assert.equals(6, f('X'));
		
		var f = Reflect.field(s, 'split');
		Assert.same(["ha","eha","e"], f('X'));
		
		var f = Reflect.field(s, 'substr');
		Assert.equals("Xeh", f(2, 3));
		
		var f = Reflect.field(s, 'toUpperCase');
		Assert.equals("HAXEHAXE", f());
		
		var f = Reflect.field(s, 'toLowerCase');
		Assert.equals("haxehaxe", f());
		
		var f = Reflect.field(s, 'toString');
		Assert.equals("haXehaXe", f());
	}
#end

	public function inlineFunction()
	{
		var f = function() return 1;
		var f2 = function(a) return 1 + a;
		var z = 0;
		var f3 = function() z++;
		
		Assert.equals(1, f());
		Assert.equals(2, f2(1));
		f3();
		Assert.equals(1, z);
	}

	public function testIssue1() {
		var a = true;
		var s = switch (a) {
			case true:
				var b = true;
				switch (b) {
					case true:
						true;
					default:
						true;
				}
			default:
				true;
		}
		Assert.isTrue(s);
	}

	public function testIssue2() {
		var a = true;
		var s = switch (a) {
			case true:
				var b = true;
				switch (b) {
					case true:
						var d = true;
						switch (d) {
							case true:
								true;
							default:
								true;
						}
					default:
						true;
				}
			default:
				true;
		}
		Assert.isTrue(s);
	}
	
	public function testIssue3()
	{
		var y = 3;
		var s = switch(1)
		{
			case 0: this.x;
			case 1: y;
			default:
		};
		Assert.equals(3, s);
	}
	
	public function testIssue4()
	{
		Assert.equals(3, staticMethod());
	}
	
	public static function staticMethod()
	{
		var y = 3;
		var s = switch(1)
		{
			case 0: 7;
			case 1: y;
			default:
		};
		return s;
	}
}