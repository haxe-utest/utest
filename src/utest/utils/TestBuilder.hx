package utest.utils;

import haxe.ds.Option;
import haxe.macro.Type.MetaAccess;
import utest.TestData.AccessoryName;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using Lambda;

private enum abstract IsAsync(Int) {
	var Yes = 1;
	var No = 0;
	var Unknown = -1;
}

class TestBuilder {
	static inline var TEST_PREFIX = 'test';
	static inline var SPEC_PREFIX = 'spec';
	static inline var PROCESSED_META = ':utestProcessed';
	static inline var TIMEOUT_META = ':timeout';
	static inline var DEPENDS_META = ':depends';
	static inline var IGNORE_META = ':ignore';
	static inline var IGNORED_META = 'Ignored';

	static inline var DEFAULT_TIMEOUT = 250;

	macro static public function build():Array<Field> {
		if(Context.defined('display') #if display || true #end) {
			return null;
		}

		var cls = Context.getLocalClass().get();
		if (cls.isInterface || cls.meta.has(PROCESSED_META)) return null;

		cls.meta.add(PROCESSED_META, [], cls.pos);

		var isOverriding = ancestorHasInitializeUtest(cls);
		var initExprs = initialExpressions(isOverriding);

		for(dependency in classDependencies(cls.meta)) {
			initExprs.push(macro init.dependencies.push($v{dependency}));
		}

		var fields = Context.getBuildFields();
		var tests = new Map<String,Field>();
		for (field in fields) {
			switch (field.kind) {
				case FFun(fn):
					var isStatic = field.access == null ? false : field.access.has(AStatic);
					if(!isStatic && isTestName(field.name)) {
						tests.set(field.name, field);
					} else if(isAccessoryMethod(field.name)) {
						processAccessory(cls, field, fn, initExprs);
					} else {
						checkPossibleTypo(field);
					}
				case _:
			}
		}
		for(test in orderTestsByDependencies(tests)) {
			switch test.field.kind {
				case FFun(fn): processTest(cls, test.field, fn, test.dependencies, initExprs);
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

	static function error(msg:String, pos:Position) {
		Context.error('UTest: $msg', pos);
	}

	static function initialExpressions(isOverriding:Bool):Array<Expr> {
		var initExprs = [];

		if(isOverriding) {
			initExprs.push(macro var init = super.__initializeUtest__());
		} else {
			initExprs.push(macro var init:utest.TestData.InitializeUtest = {tests:[], dependencies:[], accessories:{}});
		}

		return initExprs;
	}

	static function classDependencies(meta:MetaAccess):Array<String> {
		var deps = [];
		function stringify(e:Expr):Null<String> {
			return switch e.expr {
				case EConst(CIdent(s)): s;
				case EField(e, field):
					switch stringify(e) {
						case null: null;
						case s: '$s.$field';
					}
				case _: null;
			}
		}
		for(m in meta.extract(':depends')) {
			if(m.name == DEPENDS_META) {
				switch m.params {
					case null | []:
					case exprs:
						for(e in exprs) {
							switch stringify(e) {
								case null:
									error('Invalid expression for dependency. Fully qualified class path expected.', e.pos);
								case dependency:
									if(deps.indexOf(dependency) < 0) {
										deps.push(dependency);
									}
							}
						}
				}
			}
		}
		return deps;
	}

	static function orderTestsByDependencies(tests:Map<String,Field>):Array<{field:Field, dependencies:Array<String>}> {
		var result = [];
		var added = new Map();
		function addTest(field:Field, stack:Array<String>) {
			if(added.exists(field.name))
				return;
			if(stack.indexOf(field.name) >= 0) {
				error('Circular dependencies detected: ' + stack.join(' -> '), field.pos);
				return;
			}
			stack.push(field.name);
			var dependencies = getTestDependencies(field, tests);
			for(dependency in dependencies) {
				switch tests.get(dependency) {
					case null:
						error('Dependency $dependency not found.', field.pos);
					case depTest:
						addTest(depTest, stack);
				}
			}
			result.push({field:field, dependencies:dependencies});
			added.set(field.name, true);
		}
		for(field in tests) {
			addTest(field, []);
		}
		return result;
	}

	static function getTestDependencies(field:Field, tests:Map<String,Field>):Array<String> {
		var deps = [];
		switch field.meta {
			case null:
			case meta:
				for(m in meta) {
					if(m.name == DEPENDS_META) {
						switch m.params {
							case null | []:
							case exprs:
								for(e in exprs) {
									switch e {
										case macro $i{dependency}:
											if(!tests.exists(dependency)) {
												error('Dependency $dependency not found.', e.pos);
											}
											if(deps.indexOf(dependency) < 0) {
												deps.push(dependency);
											}
										case _:
											error('Invalid expression for dependency. Identifier expected.', e.pos);
									}
								}
						}
					}
				}
		}
		return deps;
	}

	static function processTest(cls:ClassType, field:Field, fn:Function, dependencies:Array<String>, initExprs:Array<Expr>) {
		var test = field.name;
		var ignore = switch getIgnore(cls, field) {
			case None: macro haxe.ds.Option.None;
			case Some(reason): macro haxe.ds.Option.Some($v{reason});
		}
		switch(fn.args.length) {
			//synchronous test
			case 0:
				initExprs.push(macro @:pos(field.pos) init.tests.push({
					name:$v{test},
					dependencies: $v{dependencies},
					execute:function() {
						this.$test();
						return @:privateAccess utest.Async.getResolved();
					},
					ignore:$ignore
				}));
			//asynchronous test
			case 1:
				initExprs.push(macro @:pos(field.pos) init.tests.push({
					name:$v{test},
					dependencies: $v{dependencies},
					execute:function() {
						var async = @:privateAccess new utest.Async(${getTimeoutExpr(cls, field)});
						this.$test(async);
						return async;
					},
					ignore:$ignore
				}));
			//wtf test
			case _:
				error('Wrong arguments count. The only supported argument is utest.Async for asynchronous tests.', field.pos);
		}
		if(field.name.indexOf(TEST_PREFIX) == 0 && fn.expr != null && Context.defined("UTEST_DETAILED_MESSAGES")) {
			fn.expr = prepareTest(fn.expr);
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
				error('Wrong arguments count. The only supported argument is utest.Async for asynchronous methods.', field.pos);
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

	static function prepareTest(expr:Expr) {
		return switch(expr.expr) {
			case ECall({expr: EField({expr: EConst(CIdent("Assert")) | EField(_, "Assert")}, assertion = "isTrue" | "isFalse")}, [condition]):
				switch(condition.expr) {
					case EBinop(op = OpEq | OpNotEq | OpGt | OpGte | OpLt | OpLte, left, right):
						parseSpecBinop(condition, op, left, right, assertion);
					case EUnop(op = OpNot, prefix, subj):
						parseSpecUnop(condition, op, prefix, subj, assertion);
					case ECall(func, args):
						parseTestCall(condition, func, args, assertion);
					default:
						expr;
				}
			case _:
				ExprTools.map(expr, prepareTest);
		}
	}
	
	static function parseTestCall(expr:Expr, func:Expr, args:Array<Expr>, ?assertion:String = "isTrue"):Expr {
		var funcStr = ExprTools.toString(func);
		var funcValue = macro $v{funcStr};
		var argsStr:String = [for(arg in args) ExprTools.toString(arg)].join(", ");

		var vars:Array<Var> = [];
		switch(func.expr) {
			case EField(thisValue, funcName) if(!isCapitalized(thisValue)):
				vars.push({name: "_utest_this", expr: thisValue});
				func = {expr: EField(macro _utest_this, funcName), pos: func.pos};
				funcValue = macro _utest_this + "." + $v{funcName};
			default:
		}

		var varValues:Array<Expr> = [];
		var argValues:Array<Expr> = [];
		for(i => arg in args) {
			if(isCapitalized(arg)) {
				varValues.push(arg);
				argValues.push(macro $v{ExprTools.toString(arg)});
			} else {
				var varName = "_utest_arg_" + i;
				vars.push({name: varName, expr: arg});
				varValues.push(macro $i{varName});
				argValues.push(macro Std.string($i{varName}));
			}
		}
		var varsExpr = {expr: EVars(vars), pos: expr.pos};

		var expected = assertion == "isFalse" ? " should be false" : "";
		return macro @:pos(expr.pos) {
			$varsExpr;
			var _utest_msg = "Failed: " + $v{funcStr} + "(" + $v{argsStr} + ")" + $v{expected} + ". "
						+ "Values: " + $funcValue + "(" + $a{argValues}.join(", ") + ")";
			utest.Assert.$assertion($func($a{varValues}), _utest_msg);
		}
	}

	static function isCapitalized(expr:Expr) {
		return switch(expr.expr) {
			case EConst(CIdent(ident)), EField(_, ident):
				~/^[A-Z]/.match(ident);
			default:
				false;
		}
	}

	static function prepareSpec(expr:Expr) {
		return switch(expr.expr) {
			case EBinop(op, left, right):
				parseSpecBinop(expr, op, left, right);
			case EUnop(op, prefix, subj):
				parseSpecUnop(expr, op, prefix, subj);
			case _:
				ExprTools.map(expr, prepareSpec);
		}
	}

	static function parseSpecBinop(expr:Expr, op:Binop, left:Expr, right:Expr, ?assertion:String = "isTrue"):Expr {
		switch op {
			case OpEq | OpNotEq | OpGt | OpGte | OpLt | OpLte:
				var leftStr = ExprTools.toString(left);
				var rightStr = ExprTools.toString(right);
				var opStr = strBinop(op);
				var binop = {
					expr:EBinop(op, macro @:pos(left.pos) _utest_left, macro @:pos(right.pos) _utest_right),
					pos:expr.pos
				}
				var expected = assertion == "isFalse" ? " should be false" : "";
				return macro @:pos(expr.pos) {
					var _utest_left = $left;
					var _utest_right = $right;
					var _utest_msg = "Failed: " + $v{leftStr} + " " + $v{opStr} + " " + $v{rightStr} + $v{expected} + ". "
								+ "Values: " + _utest_left + " " + $v{opStr} + " " + _utest_right;
					utest.Assert.$assertion($binop, _utest_msg);
				}
			case _:
				return ExprTools.map(expr, prepareSpec);
		}
	}

	static function parseSpecUnop(expr:Expr, op:Unop, prefix:Bool, subj:Expr, ?assertion:String = "isTrue"):Expr {
		switch op {
			case OpNot if(!prefix):
				var subjStr = ExprTools.toString(subj);
				var opStr = strUnop(op);
				var unop = {
					expr: EUnop(op, prefix, macro @:pos(subj.pos) _utest_subj),
					pos: expr.pos
				}
				var expected = assertion == "isFalse" ? " should be false" : "";
				return macro @:pos(expr.pos) {
					var _utest_subj = $subj;
					var _utest_msg = "Failed: " + $v{opStr} + $v{subjStr} + $v{expected} + ". "
									+ "Values: " + $v{opStr} + _utest_subj;
					utest.Assert.$assertion($unop, _utest_msg);
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
		var lowercasedName = field.name.toLowerCase();
		for(name in names) {
			if(lowercasedName == name.toLowerCase()) {
				Context.warning('Did you mean "$name"?', field.pos);
			}
		}
	}

	static function getTimeoutExpr(cls:ClassType, field:Field):Expr {
		function getValue(meta:MetadataEntry):Expr {
			if(meta.params == null || meta.params.length != 1) {
				error('@$TIMEOUT_META meta should have one argument. E.g. @$TIMEOUT_META($DEFAULT_TIMEOUT)', meta.pos);
				return macro $v{DEFAULT_TIMEOUT};
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

		return macro @:pos(field.pos) $v{DEFAULT_TIMEOUT};
	}

	static function getIgnore(cls:ClassType, field:Field):Option<Null<String>> {
		function getReason(meta:MetadataEntry):Option<Null<String>> {
			if(meta.name == IGNORED_META) {
				Context.warning('@$IGNORED_META is deprecated, use @$IGNORE_META instead', field.pos);
			}
			return Some(switch meta.params {
				case null | []:
					null;
				case [{expr:EConst(CString(reason, _))}]:
					reason;
				case _:
					error('@${meta.name} meta should have either no arguments or a single string argument', meta.pos);
					null;
			});
		}

		if(field.meta != null) {
			for(meta in field.meta) {
				if(meta.name == IGNORE_META || meta.name == IGNORED_META) {
					return getReason(meta);
				}
			}
		}

		if(cls.meta.has(IGNORE_META)) {
			return getReason(cls.meta.extract(IGNORE_META)[0]);
		} else if(cls.meta.has(IGNORED_META)) {
			return getReason(cls.meta.extract(IGNORED_META)[0]);
		}

		return None;
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
			case _: '...'; //OpSpread since Haxe 4.2.0
		}
	}
#end
}