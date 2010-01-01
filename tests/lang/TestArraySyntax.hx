package lang;

import utest.Assert;

class TestArraySyntax {
	public static inline var data = ["0", "1", "2"];
	
	public function new() {}

	public function testAssignToField() {
        var o:Dynamic = { };
        o.test = getArrayA();
		Assert.same(['a'], o.test);
	}

	static function getArrayA() {
		return ['a'];
	}

	var a : Array<Int>;
	var af : Array<Float>;
	var as : Array<String>;
	function getArray() {
		return a;
	}
	
	function getArrayF() {
		return af;
	}

	function getSArray() {
		return as;
	}

	public function testInlineArray()
	{
		Assert.equals("0", data[0]);
	}

	public function testDerefenceIncrDecr() {
		a = [1,2];
		getArray()[0]++;
		Assert.equals(2, a[0]);
		getArray()[1]--;
		Assert.equals(1, a[1]);
	}

	public function testDereferenceOpAssign() {
		a = [1, 2, 3, 5, 1, 0, 1, 1, 1, 1];
		
		getArray()[0]+=5;
		Assert.equals(6, a[0]);
		getArray()[1]-=5;
		Assert.equals(-3, a[1]);
		getArray()[2]*=5;
		Assert.equals(15, a[2]);
		getArray()[3]%=5;
		Assert.equals(0, a[3]);
		getArray()[4]&=1;
		Assert.equals(1, a[4]);
		getArray()[5]|=1;
		Assert.equals(1, a[5]);
		getArray()[6]^=1;
		Assert.equals(0, a[6]);
		getArray()[7]<<=1;
		Assert.equals(2, a[7]);
		getArray()[8]>>=1;
		Assert.equals(0, a[8]);
		getArray()[9]>>>=1;
		Assert.equals(0, a[9]);
		
		af = [4.0];
		getArrayF()[0]/=4;
		Assert.equals(1, af[0]);
	}

	public function testDereferenceAddStringAssign() {
		as = ["ha"];
		getSArray()[0]+='Xe';
		Assert.equals('haXe', as[0]);
	}

	public function testDereferenceAssign() {
		a = [0];
		getArray()[0] = 1;
		Assert.equals(1, a[0]);
		a = [];
		getArray()[2] = 1;
		Assert.equals(3, a.length);
#if flash9
		Assert.equals(0, a[0]);
#else
		Assert.isNull(a[0]);
#end
		Assert.equals(1, a[2]);
	}

	public function testDerefenceAddAssign() {
		a = [1,2];
		getArray()[0]+=5;
		Assert.equals(6, a[0]);
		getArray()[1]-=5;
		Assert.equals(-3, a[1]);
	}

	public function testIncrement() {
		var a = [1, 2];
		var x = 0;
#if !neko
		Assert.equals(2, a[0]+=1);
		Assert.equals(3, a[x+=1]+=1);
#end
		a = [1, 2];
		x = 0;
		Assert.equals(1, a[0]++);
		Assert.equals(2, a[x++]++);
	}

	public function testCreateEmpty() {
		var o = [];
		Assert.notNull(o);
	}

	public function testCreateFilled() {
		var o = [ "haXe" , "Neko" ];
		Assert.equals(2, o.length);
	}

	public function testAccessElement() {
		var o = [ "haXe" , "Neko" ];
		Assert.equals("haXe", o[0]);
		Assert.equals("Neko", o[1]);
	}

	public function testReplaceElement() {
		var o = [ "haXe" , "Neko" ];
		Assert.equals("haXe", o[0]);
		o[0] = "swfmill";
		Assert.equals("swfmill", o[0]);
		Assert.equals("Neko", o[1]);
	}

	public function testInstanceAccess() {
		var o = [new lang.util.A()];
		Assert.equals("test", o[0].msg());
	}

	public function testFunctionReturnArrayOfObjects() {
		var o = new TestArraySyntax();
		Assert.equals("test", o.returnArrayOfObjects()[0].msg());
	}

	public function testReference1() {
		var a = [];
		Assert.equals(0, a.length);
		addElement(a);
		Assert.equals(1, a.length);
		addElementStatic(a);
		Assert.equals(2, a.length);
		addElementDynamic(a);
		Assert.equals(3, a.length);
		addElementStaticDynamic(a);
		Assert.equals(4, a.length);
	}

	public function testReference2() {
		var a = [0];
		var b = a;
		b.push(0);
		Assert.equals(a.length, b.length);
	}

	public function testReference3() {
		ia = [];
		sa = ia;
		var b = returnArray();
		ia.push(0);
		Assert.equals(ia.length, b.length);
		b = returnArrayStatic();
		ia.push(0);
		Assert.equals(ia.length, b.length);
		b = returnArrayDynamic();
		ia.push(0);
		Assert.equals(ia.length, b.length);
		b = returnArrayStaticDynamic();
		ia.push(0);
		Assert.equals(ia.length, b.length);
	}

	public function testReference4() {
		var a : Array<Int>;
		a = [];
		Assert.equals(0, a.length);
		addElement(a);
		Assert.equals(1, a.length);
	}

	public function testEmptyArrayCast() {
		for(i in cast([], Array<Dynamic>)) {
			Assert.fail("should never happen");
		}
		Assert.isTrue(true);
	}

	public function testArrayCast() {
		var done = false;
		for(i in cast(["1", 1], Array<Dynamic>)) {
			done = true;
			Assert.equals("1", ''+i);
		}
		Assert.isTrue(done, "Not entered in for loop");
	}

	public function testAccessOutOfRange() {
		var a = [];
		var x = a[0];
#if flash9
		Assert.equals(0, x);
#else
		Assert.isNull(x);
#end
		x = 2;
		var y = a[1];
#if flash9
		Assert.equals(0, y);
#else
		Assert.isNull(y);
#end
		Assert.equals(2, x);
	}

	var ia : Array<Int>;
	static var sa: Array<Int>;

	function returnArray() : Array<Int> {
		return ia;
	}

	function addElement(a : Array<Int>) {
		a.push(0);
	}

	function returnArrayOfObjects() {
		return [new lang.util.A()];
	}

	static function returnArrayStatic() : Array<Int> {
		return sa;
	}

	static function addElementStatic(a : Array<Int>) {
		a.push(0);
	}

	static function returnArrayOfObjectsStatic() {
		return [new lang.util.A()];
	}

	dynamic function returnArrayDynamic() : Array<Int> {
		return ia;
	}

	dynamic function addElementDynamic(a : Array<Int>) {
		a.push(0);
	}

	dynamic function returnArrayOfObjectsDynamic() {
		return [new lang.util.A()];
	}

	static dynamic function returnArrayStaticDynamic() : Array<Int> {
		return sa;
	}

	static dynamic function addElementStaticDynamic(a : Array<Int>) {
		a.push(0);
	}

	static dynamic function returnArrayOfObjectsStaticDynamic() {
		return [new lang.util.A()];
	}
}