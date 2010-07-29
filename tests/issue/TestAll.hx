package issue;

import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
#if php
		runner.addCase(new TestIssue34());
		runner.addCase(new TestIssue143());
#end
		runner.addCase(new TestIssue36());
		runner.addCase(new TestIssue37());
		runner.addCase(new TestIssue46());
		runner.addCase(new TestIssue61());
		runner.addCase(new TestIssue123());
		runner.addCase(new TestIssue126());
		runner.addCase(new TestIssue124());
		runner.addCase(new TestIssue132());
		runner.addCase(new TestIssue142());
		runner.addCase(new TestIssue156());
		runner.addCase(new TestIssue159());
		runner.addCase(new TestIssue160());
		runner.addCase(new TestIssueML20100609());
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}