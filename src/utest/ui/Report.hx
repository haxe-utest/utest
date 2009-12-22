package utest.ui;

import utest.Runner;
import utest.ui.common.IReport;
import utest.ui.text.HtmlReport;
import utest.ui.text.PrintReport;
import utest.ui.common.HeaderDisplayMode;

class Report
{
	public static function create(runner : Runner, ?displaySuccessResults : SuccessResultsDisplayMode, ?headerDisplayMode : HeaderDisplayMode) : IReport
	{
		var report : IReport;
#if php
		if (php.Lib.isCli())
			report = new PrintReport(runner);
		else
			report = new HtmlReport(runner, php.Lib.print, true, true);
#elseif neko
		if (!neko.Web.isModNeko)
			report = new PrintReport(runner);
		else
			report = new HtmlReport(runner, neko.Lib.print, true, true);
#else
		report = new PrintReport(runner);
#end
		if (null == displaySuccessResults)
			report.displaySuccessResults = ShowSuccessResultsWithNoErrors;
		else
			report.displaySuccessResults = displaySuccessResults;
			
		if (null == headerDisplayMode)
			report.displayHeader = ShowHeaderWithResults;
		else
			report.displayHeader = headerDisplayMode;
			
		return report;
	}
}