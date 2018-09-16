package utest;

class TestAsync {
  public function new() {}

  public function testCreateAsync() {
    var assert = Assert.createAsync(function() Assert.pass(), 1000);
    haxe.Timer.delay(assert, 50);
  }
}