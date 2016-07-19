package utest;

import utest.Assertation;

class TestResult {
  public var pack          : String;
  public var cls           : String;
  public var method        : String;
  public var setup         : String;
  public var setupAsync    : String;
  public var teardown      : String;
  public var teardownAsync : String;
  public var assertations  : List<Assertation>;

  public function new(){}

  public static function ofHandler(handler : TestHandler<Dynamic>) {
    var r = new TestResult();
    var path = Type.getClassName(Type.getClass(handler.fixture.target)).split('.');
    r.cls           = path.pop();
    r.pack          = path.join('.');
    r.method        = handler.fixture.method;
    r.setup         = handler.fixture.setup;
    r.setupAsync    = handler.fixture.setupAsync;
    r.teardown      = handler.fixture.teardown;
    r.teardownAsync = handler.fixture.teardownAsync;
    r.assertations  = handler.results;
    return r;
  }

  public function allOk():Bool{
    for(l in assertations) {
      switch (l){
        case Success(_): break;
        default: return false;
      }
    }
    return true;
  }
}
