package lang;

import utest.Assert;

import lang.util.T;
import lang.util.T2;
import lang.util.ITest;

class TestTryCatch {
	public function new() {}

	public function testCatchInt() {
		Assert.equals("Int", throwCatch(1));
	}

	public function testCatchFloat() {
		Assert.equals("Float", throwCatch(0.1));
	}

	public function testCatchBool() {
		Assert.equals("Bool", throwCatch(true));
	}

	public function testCatchString() {
		Assert.equals("String", throwCatch("haXe"));
	}

	public function testCatchArray1() {
		Assert.equals("Array", throwCatch([]));
	}

	public function testCatchArray2() {
		Assert.equals("Array", throwCatch([1,2]));
	}
	public function testCatchSubClass() {
		Assert.equals("T2", throwCatch(new T2()));
	}

	public function testCatchClass() {
		Assert.equals("T", throwCatch(new T()));
	}

	public function testCatchSubClassInterface() {
		Assert.equals("ITest", throwCatchInterface(new T2()));
	}

	public function testCatchClassInterface() {
		Assert.equals("ITest", throwCatchInterface(new T()));
	}

	public function testCatchDynamic() {
		Assert.equals("Dynamic", throwCatch({}));
	}

	public function testCatchAll() {
		Assert.equals("Dynamic", throwCatchInterface(1));
	}

	public function testCatchWithOtherVarName() {
		try {
			throw "test";
			Assert.isTrue(false);
		} catch(myexception : String) {
			Assert.equals("test", myexception);
		}
	}

	public function testRethrow() {
		try {
			try {
				throw 0;
			} catch(s : String) {
				Assert.fail();
			}
			Assert.fail();
		} catch(e : Int) {
			Assert.isTrue(true);
		}
	}

#if php
	function testPhpNativeException1() {
		try {
			untyped __php__('throw new Exception("haxe", 7)');
		} catch(e : String) {
			// ignore or fail
			Assert.fail();
		} catch(e : php.Exception) {
			Assert.equals("haxe", e.getMessage());
			Assert.equals(7, e.getCode());
		}
	}

	function testPhpNativeException2() {
		try {
			untyped __php__('throw new Exception("haxe", 7)');
		} catch(e : Dynamic) {
			Assert.equals("haxe", e.getMessage());
			Assert.equals(7, e.getCode());
		}
	}
#end

	function throwCatch(ex : Dynamic) {
		try {
			throw ex;
		} catch(e : Int) {
			return "Int";
		} catch(e : Float) {
			return "Float";
		} catch(e : Bool) {
			return "Bool";
		} catch(e : String) {
			return "String";
		} catch(e : Array<Dynamic>) {
			return "Array";
		} catch(e : T2) {
			return "T2";
		} catch(e : T) {
			return "T";
		} catch(e : ITest) { // never reached
			return "ITest";
		} catch(e : Dynamic) {
			return "Dynamic";
		}
		return null;
	}

	function throwCatchInterface(ex : Dynamic) {
		try {
			throw ex;
		} catch(e : ITest) {
			return "ITest";
		} catch(e : Dynamic) {
			return "Dynamic";
		}
		return null;
	}

	// this test is expected to fail when targeting PHP
	function testNestedTryCatch(){
		try{
			try{
				throw "an exception";
			}catch(e1:Dynamic){
				try{
					throw "dummy";
				}catch(e2:Dynamic){
				// due to the PHP implementation the native Exception $»e (e1) is overriden by $»e (e2)
				// so the assertion below is expected to fail when targeting PHP
				}
				php.Lib.rethrow(e1);
			}
		}catch(e:Dynamic){
			Assert.equals("an exception", e);
		}

        }
}