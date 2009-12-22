package lang;

import utest.Assert;
import lang.util.BasicEnum;
import lang.util.Quantity;
import lang.util.TypeEnum;

class TestEnumAccess {
	public function new() {}

  public function testBasicField() {
		var e = EOne;
		Assert.equals(EOne, e);
		e = ETwo;
		Assert.equals(ETwo, e);
		e = EThree;
		Assert.equals(EThree, e);
    }

	public function testIntType() {
		var e = TInt(5);
		var re = recoverValue(e);
		Assert.equals(5, re);
		var f = TFloat(5.0);
		var rf = recoverValue(f);
		Assert.equals(5.0, rf);
		Assert.equals(re, rf);
	}

	public function testStringType() {
		var s = TString("Hello");
		Assert.equals("Hello", recoverValue(s));
	}

	public function testWrapped() {
		var s = TType(TString("Hello"));
		Assert.equals("Hello", recoverValue(s));
	}

	public function testQuantities() {
	   Assert.equals("Unknown", quantityToString(Unknown));
	   Assert.equals("None",    quantityToString(None));
	   Assert.equals("One1",    quantityToString(One(1)));
	   Assert.equals("Two12",   quantityToString(Two(1,2)));
	}
	
	public function testDefault() {
		Assert.equals("None", noneOrSome(None));
		Assert.equals("Some", noneOrSome(Unknown));
		Assert.equals("Some", noneOrSome(One(1)));
		Assert.equals("Some", noneOrSome(Two(1,2)));
		Assert.equals("None", noneOrSome(lang.util.Quantity.None));
		Assert.equals("Some", noneOrSome(lang.util.Quantity.Two(1,2)));
	}
	
	public function testSwitchBlock() {
		Assert.equals("None", switch(None) {
			case None: "None";
			default:   "Some";
		});
		
		Assert.equals("Some", switch(Two(1,2)) {
			case None: "None";
			default:   "Some";
		});
	}

	static function recoverValue(e:TypeEnum) {
		var r : Dynamic;
		switch(e) {
			case TInt(v):    r = v;
			case TFloat(v):  r = v;
			case TString(v): r = v;
			case TBool(v):   r = v;
			case TType(te):  r = recoverValue(te);
		}
		return r;
	}

	static function quantityToString(e : Quantity<Int>) {
		switch(e) {
			case Unknown:     return "Unknown";
			case None:        return "None";
			case One(v):      return "One" + v;
			case Two(v1, v2): return "Two" + v1 + v2;
		}
	}
	
	static function noneOrSome(e : Quantity<Int>) {
		switch(e) {
			case None: return "None";
			default:   return "Some";
		}
	}
}
