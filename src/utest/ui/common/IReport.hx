package utest.ui.common;

import utest.ui.common.HeaderDisplayMode;

interface IReport<T : IReport<Dynamic>>
{
	public var displaySuccessResults : SuccessResultsDisplayMode;
	public var displayHeader : HeaderDisplayMode;
	public function setHandler(handler : T -> Void) : Void;
}