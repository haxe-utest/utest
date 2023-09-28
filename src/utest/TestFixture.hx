package utest;

import haxe.rtti.Meta;
import utest.IgnoredFixture;

class TestFixture {
  public var target(default, null)        : ITest;
  public var method(default, null)        : String;
  public var setup(default, null)         : String;
  public var setupAsync(default, null)    : String;
  public var teardown(default, null)      : String;
  public var teardownAsync(default, null) : String;
  public var ignoringInfo(default, null)       : IgnoredFixture;

  @:allow(utest)
  var test:Null<TestData>;
  @:allow(utest)
  var setupMethod:()->Async;
  @:allow(utest)
  var teardownMethod:()->Async;

  static public function ofData(target:ITest, test:TestData, accessories:TestData.Accessories):TestFixture {
    var fixture = new TestFixture(target, test.name);
    fixture.test = test;
    fixture.setupMethod = utest.utils.AccessoriesUtils.getSetup(accessories);
    fixture.teardownMethod = utest.utils.AccessoriesUtils.getTeardown(accessories);
    return fixture;
  }

  function new(target : ITest, method : String, ?setup : String, ?teardown : String, ?setupAsync : String, ?teardownAsync : String) {
    this.target        = target;
    this.method        = method;
    this.setup         = setup;
    this.setupAsync    = setupAsync;
    this.teardown      = teardown;
    this.teardownAsync = teardownAsync;
    this.ignoringInfo = getIgnored();
  }

  function checkMethod(name : String, arg : String) {
    var field = Reflect.field(target, name);
    if(field == null)              throw arg + " function " + name + " is not a field of target";
    if(!Reflect.isFunction(field)) throw arg + " function " + name + " is not a function";
  }

  function getIgnored():IgnoredFixture {
    var metasForTestMetas = Reflect.getProperty(Meta.getFields(Type.getClass(target)), method);

    if (metasForTestMetas == null || !Reflect.hasField(metasForTestMetas, "Ignored")) {
      return IgnoredFixture.NotIgnored();
    }

    var ignoredArgs:Array<Any> = cast Reflect.getProperty(metasForTestMetas, "Ignored");
    if (ignoredArgs == null || ignoredArgs.length == 0 || ignoredArgs[0] == null) {
      return IgnoredFixture.Ignored();
    }

    var ignoredReason:String = Std.string(ignoredArgs[0]);
    return IgnoredFixture.Ignored(ignoredReason);
  }
}
