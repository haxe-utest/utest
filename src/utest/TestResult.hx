package utest;

import utest.Assertation;

class TestResult {
  public var pack          : String;
  public var cls           : String;
  public var method        : String;
  public var setup         : String;
  public var setupAsync    : String;
  public var teardown      : String;
  public var teardownAsync : String;
  public var assertations  : List<Assertation>;
  public var executionTime : Float;

  public function new(){}

  public static function ofHandler<T>(handler : TestHandler<T>):TestResult {
    var r = new TestResult();
    var path = Type.getClassName(Type.getClass(handler.fixture.target)).split('.');
    r.cls           = path.pop();
    r.pack          = path.join('.');
    r.method        = handler.fixture.method;
    r.assertations  = handler.results;
    r.executionTime = handler.executionTime;
    return r;
  }

  public static function ofFailedSetupClass(testCase:ITest, assertation:Assertation):TestResult {
    var r = new TestResult();
    var path = Type.getClassName(Type.getClass(testCase)).split('.');
    r.cls           = path.pop();
    r.pack          = path.join('.');
    r.method        = 'setup';
    r.assertations  = new List();
    r.assertations.add(assertation);
    return r;
  }

  public static function ofFailedTeardownClass(testCase:ITest, assertation:Assertation):TestResult {
    var r = new TestResult();
    var path = Type.getClassName(Type.getClass(testCase)).split('.');
    r.cls           = path.pop();
    r.pack          = path.join('.');
    r.method        = 'setup';
    r.assertations  = new List();
    r.assertations.add(assertation);
    return r;
  }

//   public function allOk():Bool{
//     for(l in assertations) {
//       switch (l){
//         case Success(_): break;
//         default: return false;
//       }
//     }
//     return true;
//   }
}
