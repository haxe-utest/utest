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
	
	public function testIssue2()
	{
		var a =
			switch (true) {
				case true:
					while (true) {
						switch( true) {
							case true: break;
							default: 0;
						}
					}
					1;
			}
		Assert.equals(1, a);
	}

	public function testIssue3()
	{
		var s = switch(true) {
					case true:
						var i;
						switch(0) {
							case 0 : i = 1;
							default: i = 0;
						}
						7;
		}
		Assert.equals(7, s);
	}
	
#if hscript
	public function testHScript()
	{
		var script = "i = 7; var f = function() { return i - 4; }; test = f(); ";
		var parser = new hscript.Parser();
		var expr = parser.parse(new haxe.io.StringInput(script));
		var interp = new hscript.Interp();
		interp.execute(expr);
		Assert.equals(7, interp.variables.get("i"));
		Assert.equals(3, interp.variables.get("test"));
	}
#end

}