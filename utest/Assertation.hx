package utest;

import haxe.PosInfos;

enum Assertation {
	Success(pos : PosInfos);
	Failure(msg : String, pos : PosInfos);
	Error(e : Dynamic);
	SetupError(e : Dynamic);
	TimeoutError(missedAsyncs : Int);
	AsyncError(e : Dynamic);
	Warning(msg : String);
}