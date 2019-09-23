package utest.utils;

import utest.TestData.AccessoryName;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using Lambda;

@:enum
private abstract IsAsync(Int) {
	var Yes = 1;
	var No = 0;
	var Unknown = -1;
}

class TestBuilder {
	static inline var TEST_PREFIX = 'test';
	static inline var SPEC_PREFIX = 'spec';
	static inline var PROCESSED_META = ':utestProcessed';
	static inline var TIMEOUT_META = ':timeout';


	macro static public function build():Array<Field> {
		if(Context.defined('display') #if display || true #end) {
			return null;
		}

		var cls = Context.getLocalClass().get();
		if (cls.isInterface || cls.meta.has(PROCESSED_META)) return null;

		cls.meta.add(PROCESSED_META, [], cls.pos);

		var isOverriding = ancestorHasInitializeUtest(cls);
		var initExprs = initialExpressions(isOverriding);
		var fields = Context.getBuildFields();
		for (field in fields) {
			switch (field.kind) {
				case FFun(fn):
					var isStatic = field.access == null ? false : field.access.has(AStatic);
					if(!isStatic && isTestName(field.name)) {
						processTest(cls, field, fn, initExprs);
					} else if(isAccessoryMethod(field.name)) {
						processAccessory(cls, field, fn, initExprs);
					} else {
						checkPossibleTypo(field);
					}
				case _:
			}
		}
		initExprs.push(macro return init);

		var initialize = (macro class Dummy {
			@:noCompletion @:keep public function __initializeUtest__():utest.TestData.InitializeUtest
				$b{initExprs}
		}).fields[0];
		if(isOverriding) {
			initialize.access.push(AOverride);
		}

		fields.push(initialize);
		return fields;
	}
#if macro
	static function initialExpressions(isOverriding:Bool):Array<Expr> {
		var initExprs = [];

		if(isOverriding) {
			initExprs.push(macro var init = super.__initializeUtest__());
		} else {
			initExprs.push(macro var init:utest.TestData.InitializeUtest = {tests:[], accessories:{}});
		}

		return initExprs;
	}

	static function processTest(cls:ClassType, field:Field, fn:Function, initExprs:Array<Expr>) {
		var test = field.name;
		switch(fn.args.length) {
			//synchronous test
			case 0:
				initExprs.push(macro @:pos(field.pos) init.tests.push({
					name:$v{test},
					execute:function() {
						this.$test();
						return @:privateAccess utest.Async.getResolved();
					}
				}));
			//asynchronous test
			case 1:
				initExprs.push(macro @:pos(field.pos) init.tests.push({
					name:$v{test},
					execute:function() {
						var async = @:privateAccess new utest.Async(${getTimeoutExpr(cls, field)});
						this.$test(async);
						return async;
					}
				}));
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
	static function processAccessory(cls:ClassType, field:Field, fn:Function, initExprs:Array<Expr>) {
		var name = field.name;
		switch(fn.args.length) {
			//synchronous method
			case 0:
				initExprs.push(macro @:pos(field.pos) init.accessories.$name = function() {
					this.$name();
					return @:privateAccess utest.Async.getResolved();
				});
			//asynchronous method
			case 1:
				initExprs.push(macro @:pos(field.pos) init.accessories.$name = function() {
					var async = @:privateAccess new utest.Async(${getTimeoutExpr(cls, field)});
					this.$name(async);
					return async;
				});
			//wtf test
			case _:
				Context.error('Wrong arguments count. The only supported argument is utest.Async for asynchronous methods.', field.pos);
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
					switch(expr.expr) {
						case EBinop(op, left, right):
							newExprs.push(parseSpecBinop(expr, op, left, right));
						case EUnop(op, prefix, subj):
							newExprs.push(parseSpecUnop(expr, op, prefix, subj));
						case _:
							newExprs.push(ExprTools.map(expr, prepareSpec));
					}
				}
				{expr:EBlock(newExprs), pos:expr.pos};
			case _:
				ExprTools.map(expr, prepareSpec);
		}
	}

	static function parseSpecBinop(expr:Expr, op:Binop, left:Expr, right:Expr):Expr {
		switch op {
			case OpEq | OpNotEq | OpGt | OpGte | OpLt | OpLte:
				var leftStr = ExprTools.toString(left);
				var rightStr = ExprTools.toString(right);
				var opStr = strBinop(op);
				var binop = {
					expr:EBinop(op, macro @:pos(left.pos) _utest_left, macro @:pos(right.pos) _utest_right),
					pos:expr.pos
				}
				return macro @:pos(expr.pos) {
					var _utest_left = $left;
					var _utest_right = $right;
					var _utest_msg = "Failed: " + $v{leftStr} + " " + $v{opStr} + " " + $v{rightStr} + ". "
								+ "Values: " + _utest_left + " " + $v{opStr} + " " + _utest_right;
					utest.Assert.isTrue($binop, _utest_msg);
				}
			case _:
				return ExprTools.map(expr, prepareSpec);
		}
	}

	static function parseSpecUnop(expr:Expr, op:Unop, prefix:Bool, subj:Expr):Expr {
		switch op {
			case OpNot if(!prefix):
				var subjStr = ExprTools.toString(subj);
				var opStr = strUnop(op);
				var unop = {
					expr: EUnop(op, prefix, macro @:pos(subj.pos) _utest_subj),
					pos: expr.pos
				}
				return macro @:pos(expr.pos) {
					var _utest_subj = $subj;
					var _utest_msg = "Failed: " + $v{opStr} + $v{subjStr} + ". "
									+ "Values: " + $v{opStr} + _utest_subj;
					utest.Assert.isTrue($unop, _utest_msg);
				}
			case _:
				return ExprTools.map(expr, prepareSpec);
		}
	}

	static var names = [
		AccessoryName.SETUP_CLASS_NAME,
		AccessoryName.SETUP_NAME,
		AccessoryName.TEARDOWN_CLASS_NAME,
		AccessoryName.TEARDOWN_NAME
	];
	static function checkPossibleTypo(field:Field) {
		var pos = Context.currentPos();
		var lowercasedName = field.name.toLowerCase();
		for(name in names) {
			if(lowercasedName == name.toLowerCase()) {
				Context.warning('Did you mean "$name"?', pos);
			}
		}
	}

	static function getTimeoutExpr(cls:ClassType, field:Field):Expr {
		function getValue(meta:MetadataEntry):Expr {
			if(meta.params == null || meta.params.length != 1) {
				Context.error('@:timeout meta should have one argument. E.g. @:timeout(250)', meta.pos);
				return macro 250;
			} else {
				return meta.params[0];
			}
		}

		if(field.meta != null) {
			for(meta in field.meta) {
				if(meta.name == TIMEOUT_META) {
					return getValue(meta);
				}
			}
		}

		if(cls.meta.has(TIMEOUT_META)) {
			return getValue(cls.meta.extract(TIMEOUT_META)[0]);
		}

		return macro @:pos(field.pos) 250;
	}

	static function strBinop(op:Binop) {
		return switch op {
			case OpAdd: '+';
			case OpMult: '*';
			case OpDiv: '/';
			case OpSub: '-';
			case OpAssign: '=';
			case OpEq: '==';
			case OpNotEq: '!=';
			case OpGt: '>';
			case OpGte: '>=';
			case OpLt: '<';
			case OpLte: '<=';
			case OpAnd: '&';
			case OpOr: '|';
			case OpXor: '^';
			case OpBoolAnd: '&&';
			case OpBoolOr: '||';
			case OpShl: '<<';
			case OpShr: '>>';
			case OpUShr: '>>>';
			case OpMod: '%';
			case OpInterval: '...';
			case OpArrow: '=>';
			case OpAssignOp(op): strBinop(op) + '=';
			case _: 'in';
		}
	}

	static function strUnop(op:Unop) {
		return switch op {
			case OpIncrement: '++';
			case OpDecrement: '--';
			case OpNot: '!';
			case OpNeg: '-';
			case OpNegBits: '~';
		}
	}
#end
}