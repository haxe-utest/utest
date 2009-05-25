package utest;

import utest.Assertation;

/**
* @todo add documentation
*/
class TestResult {
	public var pack          : String;
	public var cls           : String;
	public var method        : String;
	public var setup         : String;
	public var teardown      : String;
	public var assertations  : List<Assertation>;

	public function new();

	public static function ofHandler(handler : TestHandler<Dynamic>) {
		var r = new TestResult();
		var path = Type.getClassName(Type.getClass(handler.fixture.target)).split('.');
		r.cls           = path.pop();
		r.pack          = path.join('.');
		r.method        = handler.fixture.method;
		r.setup         = handler.fixture.setup;
		r.teardown      = handler.fixture.teardown;
		r.assertations  = handler.results;
		return r;
	}
}