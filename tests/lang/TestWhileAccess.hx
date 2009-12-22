package lang;

import utest.Assert;

class TestWhileAccess {
	public function new() {}

	public function testWhile() {
		var x = 0;
		while(x < 3) {
			x++;
		}
		Assert.equals(3, x);
	}

	public function testBreak() {
		var x = 0;
		while(x < 3) {
			x++;
			break;
		}
		Assert.equals(1, x);
	}

	public function testContinue() {
		var x = 0;
		while(x < 3) {
			x++;
			continue;
			Assert.fail();
		}
		Assert.equals(3, x);
	}

	public function testBreakInSwitch() {
		while(true) {
			switch(0) {
				case 0:
				break;
				Assert.fail();
			}
			Assert.fail();
		}
		Assert.isTrue(true);
	}

	public function testBreakDoubleInSwitchInWhile() {
		while(true) {
			switch(0) {
				case 0:
				while(true) {
					switch(0) {
						case 0:
							break;
							Assert.fail();
					}
					Assert.fail();
				}
				Assert.isTrue(true);
				break;
				Assert.fail();
			}
		}
		Assert.isTrue(true);
	}
}