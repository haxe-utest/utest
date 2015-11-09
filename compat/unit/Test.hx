package unit;

import utest.Assert;

class Test {
  public function new(){}

  function eq<T>(v : T, v2 : T, ?pos) {
    Assert.equals(v2, v, null, pos);
  }

  function t(v, ?pos) {
    eq(v,true,pos);
  }

  function f(v, ?pos) {
    eq(v,false,pos);
  }

  function assert(?pos) {
    Assert.warn("Assert");
  }

  function exc(f : Void -> Void, ?pos) {
    try {
      f();
      Assert.fail("No exception occured",pos);
    } catch(e : Dynamic) {
      Assert.isTrue(true, pos);
    }
  }

  function unspec(f : Void -> Void, ?pos) {
    try {
      f();
    } catch(e : Dynamic) {
    }
  }

  function allow<T>(v : T, values : Array<T>, ?pos) {
    Assert.allows(values, v, null, pos);
  }

  function infos(m : String) {
    log(m);
  }

  // TODO: Implement
  function async<Args,T>(f : Args -> (T -> Void) -> Void, args : Args, v : T, ?pos : haxe.PosInfos) {
    throw "not implemented";
    /*
    if(asyncWaits.length >= AMAX) {
      asyncCache.push(callback(async,f,args,v,pos));
      return;
    }
    asyncWaits.push(pos);
    f(args,function(v2) {
      count++;
      if(!asyncWaits.remove(pos)) {
        report("Double async result",pos);
        return;
      }
      if(v != v2)
        report(v2+" should be "+v,pos);
      checkDone();
    });
    */
  }

  // TODO: Implement
  function asyncExc<Args>(seterror : (Dynamic -> Void) -> Void, f : Args -> (Dynamic -> Void) -> Void, args : Args, ?pos : haxe.PosInfos) {
    throw "not implemented";
    /*
    if(asyncWaits.length >= AMAX) {
      asyncCache.push(callback(asyncExc,seterror,f,args,pos));
      return;
    }
    asyncWaits.push(pos);
    seterror(function(e) {
      count++;
      if(asyncWaits.remove(pos))
        checkDone();
      else
        report("Multiple async events",pos);
    });
    f(args,function(v) {
      count++;
      if(asyncWaits.remove(pos)) {
        report("No exception occured",pos);
        checkDone();
      } else
        report("Multiple async events",pos);
    });
    */
  }

  function log(msg, ?pos : haxe.PosInfos) {
    haxe.Log.trace(msg,pos);
  }
}
