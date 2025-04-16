package utest;

import js.lib.Promise;
import haxe.Exception;
import haxe.coro.Primitive;
import haxe.coro.Coroutine;
import haxe.coro.Coroutine.delay;
import haxe.coro.Coroutine.yield;
import haxe.coro.CoroutineContext;
import haxe.coro.IScheduler;
import haxe.coro.IContinuation;

private class JsScheduler implements IScheduler {
	public function new() {}

	public function schedule(func:() -> Void) {
		haxe.Timer.delay(func, 0);
	}

	public function scheduleIn(func:() -> Void, ms:Int) {
		haxe.Timer.delay(func, ms);
	}
}

private class PromiseContinuation<T> implements IContinuation<Any> {
	var doResolve : (result:T)->Void;
	var doReject : (reason:Dynamic)->Void;

	public final _hx_context:CoroutineContext;

	public function new(scheduler:IScheduler) {
		_hx_context = new CoroutineContext(scheduler);
	}

	public function resume(result:Any, error:Exception) {
		if (error != null) {
			doReject(error);
		} else {
			doResolve(result);
		}
	}

	public function promise():Promise<T> {
		return
			new Promise((resolve, reject) -> {
				doResolve = resolve;
				doReject  = reject;
			});
	}
}

class CoroutineHelpers {
    public static function promise<T>(f:Coroutine<() -> T>):Promise<T> {
        final cont = new PromiseContinuation(new JsScheduler());

        return try {
            final result = f(cont);
            if (result is Primitive) {
                cont.promise();
            } else {
                Promise.resolve(result);
            }
        }
        catch (exn:Exception) {
            Promise.reject(exn);
        }
    }
}