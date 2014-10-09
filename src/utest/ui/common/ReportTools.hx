package utest.ui.common;

import utest.ui.common.HeaderDisplayMode;

class ReportTools
{
	public static function hasHeader(report : IReport<Dynamic>, stats : ResultStats)
	{
		switch(report.displayHeader)
		{
			case NeverShowHeader:
				return false;
			case ShowHeaderWithResults:
				if (!stats.isOk)
					return true;
				switch(report.displaySuccessResults)
				{
					case NeverShowSuccessResults:
						return false;
					case AlwaysShowSuccessResults, ShowSuccessResultsWithNoErrors:
						return true;
				}
			case AlwaysShowHeader:
				return true;
		};
	}

	public static function skipResult(report : IReport<Dynamic>, stats : ResultStats, isOk)
	{
		if (!stats.isOk) return false;
		return switch(report.displaySuccessResults)
		{
			case NeverShowSuccessResults: true;
			case AlwaysShowSuccessResults: false;
			case ShowSuccessResultsWithNoErrors: !isOk;
		};
	}

	public static function hasOutput(report : IReport<Dynamic>, stats : ResultStats)
	{
		if (!stats.isOk) return true;
		return hasHeader(report, stats);
	}
}