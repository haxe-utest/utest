/**
 * ...
 * @author Franco Ponticelli
 */

package platform;
import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
#if php
		platform.php.TestAll.addTests(runner);
#end
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}