package lang;

import utest.Assert;

import lang.util.PropertyClass;

class TestPropertyAccess {
	public function new() {}
	
	public function testReadonly() {
		var o = new PropertyClass();
		Assert.equals("readonly", o.readonly);
		o.setReadonly("test");
		Assert.equals("test", o.readonly);
	}
	
	public function testWriteonly() {
		var o = new PropertyClass();
		Assert.equals("writeonly", o.getWriteonly());
		o.writeonly = "test";
		Assert.equals("test", o.getWriteonly());
	}
	
	public function testExcessive() {
		var o = new PropertyClass();
		Assert.equals("excessive", o.excessive);
		o.excessive = "test";
		Assert.equals("test", o.excessive);
	}
	
	public function testNopoint() {
		var o = new PropertyClass();
		Assert.equals("nopoint", o.getNopoint());
		o.setNopoint("test");
		Assert.equals("test", o.getNopoint());
	}
	
	public function testGetterReadonly() {
		var o = new PropertyClass();
		Assert.equals("value", o.getterReadonly);
	}
	
	public function testSetterReadonly() {
		var o = new PropertyClass();
		o.setterReadonly = "test";
		Assert.equals("test", o.getterReadonly);
	}
	
	public function testSetter() {
		var o = new PropertyClass();
		Assert.equals("setter", o.getSetterValue());
		o.setter = "test";
		Assert.equals("test", o.getSetterValue());
	}
	
	public function testBoth() {
		var o = new PropertyClass();
		Assert.equals("value", o.both);
		o.both = "test";
		Assert.equals("test", o.both);
	}
	
	public static var f(default, setF) : String;
	
	public static function setF(v : String) {
		f = v+"!";
		return f;
	}
	
	public function testStaticSetter() {
		Assert.isNull(f);
		f = "test";
		Assert.equals("test!", f);
	}
	
	public static var f2(getF2, setF2) : String;
	
	private static var _f2 : String;
	
	public static function setF2(v : String) {
		_f2 = v+"!";
		return _f2;
	}
	
	public static function getF2() {
		return _f2 + "?";
	}
	
	public function testStaticGetter() {
		Assert.isNull(untyped _f2);
#if php
		Assert.equals("?", f2);
#else
		Assert.equals("null?", f2);
#end
		f2 = "test";
		Assert.equals("test!", untyped _f2);
		Assert.equals("test!?", f2);
	}
}