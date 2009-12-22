package lang.util;

class B extends A {
  public function new() {super(); }
  override public function msg(){ return super.msg() + "test"; }
}