package utest;

class TestSpec extends Test {
	function specTest() {
		Std.random(1) == 0;
		Std.random(1) != 1;
		Std.random(1) + 1 > 0;
		Std.random(1) + 1 >= 1;
		Std.random(1) + 1 <= 1;
		Std.random(1) + 1 < 2;
		!(Std.random(1) == 1);
		if(Std.random(1) == 0) {
			Std.random(1) == 0;
		}
	}
}