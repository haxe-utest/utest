package utest.utils;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

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

		var initExprs = [];
		var fields = Context.getBuildFields();
		for (field in fields) {
			if(!isTestName(field.name)) {
				continue;
			}
			switch (field.kind) {
				case FFun(fn):
					var test = field.name;
					switch(fn.args.length) {
						//synchronous test
						case 0:
							initExprs.push(macro @:pos(field.pos) executors.push({name:$v{test}, execute:this.$test}));
						//asynchronous test
						case 1:
							initExprs.push(macro @:pos(field.pos) {
								var async = new utest.Async();
								@:privateAccess async.timer.stop();
								executors.push({
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
				case _:
			}
		}
		initExprs.push(macro return executors);

		var isOverriding = ancestorHasInitializeUtest(cls);
		if(isOverriding) {
			initExprs.unshift(macro var executors = super.__initializeUtest__());
		} else {
			initExprs.unshift(macro var executors = new Array<utest.TestData>());
		}

		var initialize = (macro class Dummy {
			@:noCompletion function __initializeUtest__() $b{initExprs}
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

	static function isTestName(name:String):Bool {
		return name.indexOf(TEST_PREFIX) == 0 || name.indexOf(SPEC_PREFIX) == 0;
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