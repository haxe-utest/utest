package utest.ui;

import utest.Runner;
import utest.ui.common.IReport;
import utest.ui.common.HeaderDisplayMode;

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

class Report {
  public static function create(runner : Runner, ?displaySuccessResults : SuccessResultsDisplayMode, ?headerDisplayMode : HeaderDisplayMode) : IReport<Dynamic> {
    var report : IReport<Dynamic>;
#if travis
    report = new utest.ui.text.PrintReport(runner);
#elseif (php || neko)
    if (!Web.isModNeko)
      report = new utest.ui.text.PrintReport(runner);
    else
      report = new utest.ui.text.HtmlReport(runner, true);
#elseif nodejs
    report = new utest.ui.text.PrintReport(runner);
#elseif js
    if(untyped __js__("typeof window != 'undefined'")) {
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
