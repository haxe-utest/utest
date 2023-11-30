package utest.ui.common;

class ReportTools
{
	public static function hasHeader<T:IReport<T>>(report : IReport<T>, stats : ResultStats)
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

	public static function skipResult<T:IReport<T>>(report : IReport<T>, stats : ResultStats, isOk)
	{
		if (!stats.isOk) return false;
		return switch(report.displaySuccessResults)
		{
			case NeverShowSuccessResults: true;
			case AlwaysShowSuccessResults: false;
			case ShowSuccessResultsWithNoErrors: !isOk;
		};
	}

	public static function hasOutput<T:IReport<T>>(report : IReport<T>, stats : ResultStats)
	{
		if (!stats.isOk) return true;
		return hasHeader(report, stats);
	}
}
