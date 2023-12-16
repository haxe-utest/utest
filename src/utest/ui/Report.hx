package utest.ui;

import utest.Runner;
import utest.ui.common.IReport;
import utest.ui.common.HeaderDisplayMode;

class Report {
  public static function create(runner : Runner, ?displaySuccessResults : SuccessResultsDisplayMode, ?headerDisplayMode : HeaderDisplayMode) : IReport<Dynamic> {
    var report:IReport<Dynamic>;
#if teamcity
    report = new utest.ui.text.TeamcityReport(runner);
#elseif travis
    report = new utest.ui.text.PrintReport(runner);
#elseif php
    if (php.Lib.isCli())
      report = new utest.ui.text.PrintReport(runner);
    else
      report = new utest.ui.text.HtmlReport(runner, true);
#elseif nodejs
    report = new utest.ui.text.PrintReport(runner);
#elseif js
    if(js.Syntax.code("typeof window != 'undefined'")) {
      report = new utest.ui.text.HtmlReport(runner, true);
    } else
      report = new utest.ui.text.PrintReport(runner);
#elseif flash
    if(flash.external.ExternalInterface.available)
      report = new utest.ui.text.HtmlReport(runner, true);
    else
      report = new utest.ui.text.PrintReport(runner);
#else
    report = new utest.ui.text.PrintReport(runner);
#end
    if (null == displaySuccessResults)
      report.displaySuccessResults = #if (travis || hidesuccess) NeverShowSuccessResults #else ShowSuccessResultsWithNoErrors #end;
    else
      report.displaySuccessResults = displaySuccessResults;

    if (null == headerDisplayMode)
      report.displayHeader = #if (travis || showheader) AlwaysShowHeader #else ShowHeaderWithResults #end;
    else
      report.displayHeader = headerDisplayMode;

    return report;
  }
}
