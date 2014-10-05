package utest;

import utest.Assert;
import utest.Dispatcher;
import utest.Runner;

class TestDispatcher {
  public function new(){}

  public function testBase() {
    var dispatcher : Dispatcher<String> = new Dispatcher();
    Assert.isFalse(dispatcher.has());
    var h = dispatcher.add(function(x : String) {});
    Assert.isTrue(dispatcher.has());
    dispatcher.remove(h);
    Assert.isFalse(dispatcher.has());
  }

  var v : String;
  public function handler1(s : String) {
    v += s+"e1";
  }

  public function handler2(s : String) {
    v += s+"e2";
  }

  public function testHandlers() {
    var dispatcher : Dispatcher<String> = new Dispatcher<String>();
    v = "";
    dispatcher.dispatch("d1");
    Assert.equals("", v);

    v = "";
    dispatcher.add(handler1);
    dispatcher.dispatch("d2");
    Assert.equals("d2e1", v);

    v = "";
    dispatcher.add(handler2);
    dispatcher.dispatch("d3");
    Assert.equals("d3e1d3e2", v);

    v = "";
    dispatcher.add(handler1);
    dispatcher.dispatch("d4");
    Assert.equals("d4e1d4e2d4e1", v);

    v = "";
    dispatcher.remove(handler1);
    dispatcher.dispatch("d5");
    Assert.equals("d5e2d5e1", v);

    v = "";
    dispatcher.remove(handler1);
    dispatcher.dispatch("d6");
    Assert.equals("d6e2", v);

    v = "";
    dispatcher.remove(handler2);
    dispatcher.dispatch("d7");
    Assert.equals("", v);
  }

  public function stopper(s : String) {
    v += s+"s";
    Dispatcher.stop();
  }

  public function testStop() {
    var dispatcher = new Dispatcher();
    v = "";
    dispatcher.add(handler1);
    dispatcher.add(stopper);
    dispatcher.add(handler2);
    dispatcher.dispatch("d1");

    Assert.equals("d1e1d1s", v);
  }
}