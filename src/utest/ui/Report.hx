package utest.ui;

import utest.Runner;
import utest.ui.common.IReport;
import utest.ui.text.HtmlReport;
import utest.ui.text.PrintReport;
import utest.ui.common.HeaderDisplayMode;

#if php
import php.Web;
#elseif neko
import neko.Web;
#elseif cpp
import cpp.Web;
#end

class Report
{
	public static function create(runner : Runner, ?displaySuccessResults : SuccessResultsDisplayMode, ?headerDisplayMode : HeaderDisplayMode) : IReport<Dynamic>
	{
		var report : IReport<Dynamic>;
#if (php || neko || cpp)
		if (!Web.isModNeko)
			report = new PrintReport(runner);
		else
			report = new HtmlReport(runner, true);
#elseif js
		report = new HtmlReport(runner, true);
#elseif flash
		if(flash.external.ExternalInterface.available)
			report = new HtmlReport(runner, true);
		else
			report = new PrintReport(runner);
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