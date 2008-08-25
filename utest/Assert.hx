package utest;

import utest.Assertation;
import haxe.PosInfos;

class Assert {
	public static var results : List<Assertation>;
	public static function isTrue(cond : Bool, msg = "true expected", ?pos : PosInfos) {
		if(results == null) throw "Assert.results is not currently bound to any assert context";
		if(cond)
			results.add(Success(pos));
		else
			results.add(Failure(msg, pos));
	}

	public static dynamic function createAsync(f : Void->Void, ?timeout : Int) {
		return function(){};
	}
	public static dynamic function createEvent<EventArg>(f : EventArg->Void, ?timeout : Int) {
		return function(e){};
	}
}