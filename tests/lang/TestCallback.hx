package lang;

import utest.Assert;

class CallbackOther {
	var counter : Int;
	public function new() { counter = 25; }

	public function cboMember(v:Int) {
		counter += v;
		return counter;
	}

	public static function cboStatic(v:Int) {
		return v;
	}
}

class TestCallback {
	var counter : Int;
	public function new() {}

	public function testCallback() {
		counter = 0;
        var n = "haXe";
        var cc = callback(f, n);
		Assert.equals("haXe", cc());
		Assert.equals(1,counter);
        n = "Neko";
        Assert.equals("haXe", cc());
		Assert.equals(2,counter);
  }

	// for comparison
	public function testClosure() {
        var n = "haXe";
        var cc = function() { return n; };
		Assert.equals("haXe", cc());
        n = "Neko";
        Assert.equals("Neko", cc());
    }

	public function testCallbackOther() {
		var c = new CallbackOther();
		var cc = callback(c.cboMember);
		Assert.equals(27, cc(2));
	}

	public function testCallbackOther2() {
		var c = new CallbackOther();
		var cc = callback(c.cboMember,5);
		Assert.equals(30, cc());
	}

	public function testCallbackOtherStatic() {
		var cc = callback(CallbackOther.cboStatic,5);
		Assert.equals(5, cc());
	}

    public function f(name:String) {
		counter ++;
        return name;
    }
}