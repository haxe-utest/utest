package utest;

import haxe.rtti.Meta;
import utest.IgnoredFixture;

using utest.utils.AccessoriesUtils;

class TestFixture {
  public var target(default, null) : ITest;
  public var method(default, null) : String;
  public var ignoringInfo(default, null) : IgnoredFixture;

  @:allow(utest)
  final test:TestData;
  @:allow(utest)
  final setupMethod:()->Async;
  @:allow(utest)
  final teardownMethod:()->Async;

  public function new(target:ITest, test:TestData, accessories:TestData.Accessories) {
    this.target = target;
    this.test = test;
    this.setupMethod = accessories.getSetup();
    this.teardownMethod = accessories.getTeardown();

    method = test.name;

    ignoringInfo = switch test.ignore {
      case None: IgnoredFixture.NotIgnored();
      case Some(reason): IgnoredFixture.Ignored(reason);
    }
  }
}
