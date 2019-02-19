package utest;

#if (haxe_ver < "3.4.0")
	#error 'Haxe 3.4.0 or later is required for utest.Async'
#end

import haxe.PosInfos;
import haxe.Timer;

@:allow(utest)
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
	static function getResolved():Async {
		if(resolvedInstance == null) {
			resolvedInstance = new Async();
			resolvedInstance.done();
		}
		return resolvedInstance;
	}

	function new(timeoutMs:Int = 250) {
		startTime = Timer.stamp();
		timer = Timer.delay(setTimedOutState, timeoutMs);
	}

	public function done(?pos:PosInfos) {
		if(resolved) {
			if(timedOut) {
				throw 'Cannot done() at ${pos.fileName}:${pos.lineNumber} because async is timed out.';
			} else {
				throw 'Cannot done() at ${pos.fileName}:${pos.lineNumber} because async is done already.';
			}
		}
		resolved = true;
		for (cb in callbacks) cb();
	}

	/**
	 * Change timeout for this async.
	 */
	public function setTimeout(timeoutMs:Int, ?pos:PosInfos) {
		if(resolved) {
			throw 'Cannot setTimeout($timeoutMs) at ${pos.fileName}:${pos.lineNumber} because async is done.';
		}
		if(timedOut) {
			throw 'Cannot setTimeout($timeoutMs) at ${pos.fileName}:${pos.lineNumber} because async is timed out.';
		}

		timer.stop();

		var delay = timeoutMs - Math.round(1000 * (Timer.stamp() - startTime));
		timer = Timer.delay(setTimedOutState, delay);
	}

	function then(cb:Void->Void) {
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