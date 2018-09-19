package utest.utils;

import utest.TestData.AccessoryName;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

@:enum
private abstract IsAsync(Int) {
	var Yes = 1;
	var No = 0;
	var Unknown = -1;
}

class TestBuilder {
	static inline var TEST_PREFIX = 'test';
	static inline var SPEC_PREFIX = 'spec';
	static inline var META_PROCESSED = ':utestProcessed';

	macro static public function build():Array<Field> {
		if(Context.defined('display') #if display || true #end) {
			return null;
		}

		var cls = Context.getLocalClass().get();
		if (cls.isInterface || cls.meta.has(META_PROCESSED)) return null;

		cls.meta.add(META_PROCESSED, [], cls.pos);

		var isOverriding = ancestorHasInitializeUtest(cls);
		var initExprs = initialExpressions(isOverriding);
		var fields = Context.getBuildFields();
		for (field in fields) {
			switch (field.kind) {
				case FFun(fn):
					if(isTestName(field.name)) {
						processTest(field, fn, initExprs);
					} else if(isAccessoryMethod(field.name)) {
						processAccessory(field, fn, initExprs);
					}
				case _:
			}
		}
		initExprs.push(macro return init);

		var initialize = (macro class Dummy {
			@:noCompletion function __initializeUtest__():utest.TestData.InitializeUtest
				$b{initExprs}
		}).fields[0];
		if(isOverriding) {
			if(initialize.access == null) {
				initialize.access = [];
			}
			initialize.access.push(AOverride);
		}

		fields.push(initialize);
		return fields;
	}

	static function initialExpressions(isOverriding:Bool):Array<Expr> {
		var initExprs = [];

		if(isOverriding) {
			initExprs.push(macro var init = super.__initializeUtest__());
		} else {
			initExprs.push(macro var init:utest.TestData.InitializeUtest = {tests:[], accessories:{}});
		}

		return initExprs;
	}

	static function processTest(field:Field, fn:Function, initExprs:Array<Expr>) {
		var test = field.name;
		switch(fn.args.length) {
			//synchronous test
			case 0:
				initExprs.push(macro @:pos(field.pos) init.tests.push({name:$v{test}, execute:this.$test}));
			//asynchronous test
			case 1:
				initExprs.push(macro @:pos(field.pos) {
					var async = new utest.Async();
					@:privateAccess async.timer.stop();
					init.tests.push({
						name:$v{test},
						async:async,
						execute:function() {
							@:privateAccess async.start(250);
							this.$test(async);
						}
					});
				});
			//wtf test
			case _:
				Context.error('Wrong arguments count. The only supported argument is utest.Async for asynchronous tests.', field.pos);
		}
		//specification test
		if(field.name.indexOf(SPEC_PREFIX) == 0 && fn.expr != null) {
			fn.expr = prepareSpec(fn.expr);
		}
	}

	/**
	 * setup, setupClass, teardown, teardownClass
	 */
	static function processAccessory(field:Field, fn:Function, initExprs:Array<Expr>) {
		var name = field.name;
		var isAsync = switch(fn.ret) {
			case null: isAsyncFunctionBody(fn.expr);
			case macro:Void: false;
			case _: isAsyncFunctionBody(fn.expr);
		}
		var cfgFieldName = isAsync ? 'asyncMethod' : 'method';
		initExprs.push(macro @:pos(field.pos) init.accessories.$name = {$cfgFieldName:$i{name}});
	}

	static function isAsyncFunctionBody(expr:Expr):Bool {
		var isAsync = Unknown;
		function traverse(expr:Expr) {
			if(isAsync != Unknown) return;
			switch(expr.expr) {
				case EReturn(null):
					isAsync = No;
				case EReturn(_):
					isAsync = Yes;
				case EFunction(_, _):
				case _:
					ExprTools.iter(expr, traverse);
			}
		}
		traverse(expr);
		return switch(isAsync) {
			case No | Unknown: false;
			case Yes: true;
		}
	}

	static function isTestName(name:String):Bool {
		return name.indexOf(TEST_PREFIX) == 0 || name.indexOf(SPEC_PREFIX) == 0;
	}

	static function isAccessoryMethod(name:String):Bool {
		return switch(name) {
			case AccessoryName.SETUP_NAME: true;
			case AccessoryName.SETUP_CLASS_NAME: true;
			case AccessoryName.TEARDOWN_NAME: true;
			case AccessoryName.TEARDOWN_CLASS_NAME: true;
			case _: false;
		}
	}

	static function ancestorHasInitializeUtest(cls:ClassType):Bool {
		if(cls.superClass == null) {
			return false;
		}
		var superClass = cls.superClass.t.get();
		for(field in superClass.fields.get()) {
			if(field.name == '__initializeUtest__') {
				return true;
			}
		}
		return ancestorHasInitializeUtest(superClass);
	}

	static function prepareSpec(expr:Expr) {
		return switch(expr.expr) {
			case EBlock(exprs):
				var newExprs = [];
				for(expr in exprs) {
					if(isSpecOp(expr)) {
						newExprs.push(macro @:pos(expr.pos) utest.Assert.isTrue($expr));
					} else {
						newExprs.push(ExprTools.map(expr, prepareSpec));
					}
				}
				{expr:EBlock(newExprs), pos:expr.pos};
			case _:
				ExprTools.map(expr, prepareSpec);
		}
	}

	static function isSpecOp(expr:Expr):Bool {
		return switch(expr.expr) {
			case EBinop(op,	_, _):
				switch(op) {
					case OpEq | OpNotEq | OpGt | OpGte | OpLt | OpLte: true;
					case _: false;
				}
			case EUnop(op, false, _):
				switch (op) {
					case OpNot: true;
					case _: false;
				}
			case _:
				false;
		}
	}
}