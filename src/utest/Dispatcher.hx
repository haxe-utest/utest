package utest;

private enum EventException {
  StopPropagation;
}

class Dispatcher<T> {

  private var handlers : Array<T -> Void>;

  public function new()
    handlers = new Array();

  public function add(h : T -> Void) : T -> Void {
    handlers.push(h);
    return h;
  }

  public function remove(h : T -> Void) : T -> Void {
    for(i in 0...handlers.length)
      if(Reflect.compareMethods(handlers[i], h))
        return handlers.splice(i, 1)[0];
    return null;
  }

  public function clear()
    handlers = new Array();

  public function dispatch(e) {
    try {
      // prevents problems with self removing events
      var list = handlers.copy();
      for( l in list )
        l(e);
      return true;
    } catch( exc : EventException ) {
      return false;
    }
  }

  public function has()
    return handlers.length > 0;

  public static function stop()
    throw StopPropagation;
}

class Notifier {

  private var handlers : Array<Void -> Void>;

  public function new()
    handlers = new Array();

  public function add(h : Void -> Void) : Void -> Void {
    handlers.push(h);
    return h;
  }

  public function remove(h : Void -> Void) : Void -> Void {
    for(i in 0...handlers.length)
      if(Reflect.compareMethods(handlers[i], h))
        return handlers.splice(i, 1)[0];
    return null;
  }

  public function clear()
    handlers = new Array();

  public function dispatch() {
    try {
      // prevents problems with self removing events
      var list = handlers.copy();
      for( l in list )
        l();
      return true;
    } catch( exc : EventException ) {
      return false;
    }
  }

  public function has()
    return handlers.length > 0;

  public static function stop()
    throw StopPropagation;
}