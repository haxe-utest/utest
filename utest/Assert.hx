package utest;

import utest.Assertation;
import haxe.PosInfos;

class Assert {
	public static var results : List<Assertation>;
	public static function isTrue(cond : Bool, msg = "true expected", ?pos : PosInfos) {
		if(cond)
			results.add(Success(pos));
		else
			results.add(Failure(msg, pos));
	}
}