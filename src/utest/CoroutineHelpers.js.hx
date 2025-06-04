package utest;

import haxe.Timer;
import haxe.coro.cancellation.CancellationToken;
import js.lib.Promise;
import haxe.Exception;
import haxe.coro.Coroutine;
import hxcoro.Coro.*;
import haxe.coro.context.Context;
import haxe.coro.schedulers.Scheduler;
import haxe.coro.IContinuation;

private class JsScheduler extends Scheduler {
	public function new() {
		super();
	}

	public function schedule(ms:Int, func:() -> Void) {
		haxe.Timer.delay(func, ms);
		return null; // what to return here?
	}

	public function now() {
		return Timer.stamp();
	}
}

private class PromiseContinuation<T> implements IContinuation<Any> {
	var doResolve:(result:T) -> Void;
	var doReject:(reason:Dynamic) -> Void;

	public var context(get, null):Context;

	public function new(context) {
		this.context = context;
	}

	public function get_context() {
		return context;
	}

	public function resume(result:Any, error:Exception) {
		if (error != null) {
			doReject(error);
		} else {
			doResolve(result);
		}
	}

	public function promise():Promise<T> {
		return new Promise((resolve, reject) -> {
			doResolve = resolve;
			doReject = reject;
		});
	}
}

class CoroutineHelpers {
	public static function promise<T>(f:Coroutine<() -> T>):Promise<T> {
		final scheduler = new JsScheduler();
		final context = Context.create(scheduler);
		final cont = new PromiseContinuation(context);

		final result = f(cont);
		return switch (result.state) {
			case Pending:
				cont.promise();
			case Returned:
				Promise.resolve(result.result);
			case Thrown:
				Promise.reject(result.error);
		}
	}
}
