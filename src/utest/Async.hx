package utest;

import haxe.PosInfos;
import haxe.Timer;

class Async {
	static var resolvedInstance:Async;

	public var resolved(default,null):Bool = false;
	public var timedOut(default,null):Bool = false;

	var callbacks:Array<Void->Void> = [];
	var startTime:Float;
	var timer:Timer;

	/**
	 * Returns an instance of `Async` which is already resolved.
	 * Any actions handling this instance will be executed synchronously.
	 */
	static public function getResolved():Async {
		if(resolvedInstance == null) {
			resolvedInstance = new Async();
			resolvedInstance.done();
		}
		return resolvedInstance;
	}

	public function new(timeoutMs:Int = 250) {
		startTime = Timer.stamp();
		start(timeoutMs);
	}

	inline function start(timeoutMs:Int) {
		if(timer != null) timer.stop();
		timer = Timer.delay(setTimedOutState, timeoutMs);
	}

	public function done() {
		if(resolved) {
			if(timedOut) {
				throw 'Cannot resolve timed out Async.';
			} else {
				throw 'Async is already resolved.';
			}
		}
		resolved = true;
		for (cb in callbacks) cb();
	}

	public function setTimeout(timeoutMs:Int) {
		var passed = Math.round(1000 * (Timer.stamp() - startTime));
		timer.stop();
		timer = Timer.delay(setTimedOutState, timeoutMs - passed);
	}

	public function then(cb:Void->Void) {
		if(resolved) {
			cb();
		} else {
			callbacks.push(cb);
		}
	}

	function setTimedOutState() {
		if(resolved) return;
		timedOut = true;
		done();
	}
}