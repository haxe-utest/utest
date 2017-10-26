package utest;

class TestAsync {
  public function new() {}

  public function testCreateAsync() {
    var assert = Assert.createAsync(function() Assert.pass(), 100);
    haxe.Timer.delay(assert, 50);
  }
}