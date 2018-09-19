package utest;

import haxe.rtti.Meta;
import utest.IgnoredFixture;

class TestFixture {
  public var target(default, null)        : {};
  public var method(default, null)        : String;
  public var setup(default, null)         : String;
  public var setupAsync(default, null)    : String;
  public var teardown(default, null)      : String;
  public var teardownAsync(default, null) : String;
  public var ignoringInfo(default, null)       : IgnoredFixture;

  @:allow(utest)
  var isITest:Bool = false;
  #if (haxe_ver >= "3.4.0")
  @:allow(utest)
  var test:Null<TestData>;
  @:allow(utest)
  var setupMethod:Void->Async;
  @:allow(utest)
  var teardownMethod:Void->Async;

  static public function ofData(target:ITest, test:TestData, accessories:TestData.Accessories):TestFixture {
    var fixture = new TestFixture(target, test.name);
    fixture.isITest = true;
    fixture.test = test;
    fixture.setupMethod = utest.utils.AccessoriesUtils.getSetup(accessories);
    fixture.teardownMethod = utest.utils.AccessoriesUtils.getTeardown(accessories);
    return fixture;
  }
  #end

  public function new(target : {}, method : String, ?setup : String, ?teardown : String, ?setupAsync : String, ?teardownAsync : String) {
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
    var metas:Dynamic<Dynamic<Array<Dynamic>>> = Meta.getFields(Type.getClass(target));
    var metasForTestMetas = Reflect.getProperty(metas, method);

    if (metasForTestMetas == null || !Reflect.hasField(metasForTestMetas, "Ignored")) {
      return IgnoredFixture.NotIgnored();
    }

    var ignoredArgs:Array<Dynamic> = cast Reflect.getProperty(metasForTestMetas, "Ignored");
    if (ignoredArgs == null || ignoredArgs.length == 0 || ignoredArgs[0] == null) {
      return IgnoredFixture.Ignored();
    }

    var ignoredReason:String = Std.string(ignoredArgs[0]);
    return IgnoredFixture.Ignored(ignoredReason);
  }
}
