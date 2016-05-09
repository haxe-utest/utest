package utest;

class TestFixture {
  public var target(default, null)        : {};
  public var method(default, null)        : String;
  public var setup(default, null)         : String;
  public var setupAsync(default, null)    : String;
  public var teardown(default, null)      : String;
  public var teardownAsync(default, null) : String;
  public function new(target : {}, method : String, ?setup : String, ?teardown : String, ?setupAsync : String, ?teardownAsync : String) {
    this.target        = target;
    this.method        = method;
    this.setup         = setup;
    this.setupAsync    = setupAsync;
    this.teardown      = teardown;
    this.teardownAsync = teardownAsync;
  }

  function checkMethod(name : String, arg : String) {
    var field = Reflect.field(target, name);
    if(field == null)              throw arg + " function " + name + " is not a field of target";
    if(!Reflect.isFunction(field)) throw arg + " function " + name + " is not a function";
  }
}
