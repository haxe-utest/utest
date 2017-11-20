package utest;

abstract IgnoredFixture(String) to String {
  public static function NotIgnored():IgnoredFixture {
    return new IgnoredFixture(null);
  }

  public static function Ignored(reason:String = null):IgnoredFixture {
    return new IgnoredFixture(reason != null ? reason : "");
  }

  public var isIgnored(get, never):Bool;
  public var ignoreReason(get, never):String;

  public inline function new(reason:String) {
    this = reason;
  }

  private inline function get_isIgnored():Bool {
    return this != null;
  }

  private inline function get_ignoreReason():String {
    return this;
  }
}