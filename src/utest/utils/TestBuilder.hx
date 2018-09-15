package utest.utils;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;

class TestBuilder {
	static inline var TEST_PREFIX = 'test';
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
			if(field.name.indexOf(TEST_PREFIX) != 0) {
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
}