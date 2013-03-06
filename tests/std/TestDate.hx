package std;

import utest.Assert;

class TestDate {
	public function new(){}

	public function testFormat(){
		var d = new Date(2006,2,19,8,20,3);
		Assert.equals("2006-03-19 08:20:03",d.toString());
		Assert.equals("2006-03-19 08:20:03",Std.string(d));
		Assert.equals("2006-03-19 08:20:03",DateTools.format(d,"%Y-%m-%d %H:%M:%S"));
	}

	public function testDelta(){
		var d = new Date(2006,2,19,8,20,3);
		d = DateTools.delta(d,3600*24*1000);
		Assert.equals("2006-03-20 08:20:03",DateTools.format(d,"%Y-%m-%d %H:%M:%S"));
	}

	public function testFormat2(){
		#if sys
		var isWindows = Sys.systemName() == "Windows";
		#else
		var isWindows = false;
		#end

		var d1 = new Date(2006,2,19,18,20,3);
		var d2 = new Date(2006,2,19,8,20,3);

		var formats;
		var expected1;
		var expected2;

		if(isWindows) {
			formats   = ['%%','%d','%H','%I','%m','%M','%p','%S','%w','%y','%Y'];
			expected1 = ['%', '19','18','06','03','20','pm','03','0', '06','2006'];
			expected2 = ['%', '19','08','08','03','20','am','03','0', '06','2006'];
		} else {
			formats   = ['%%','%C','%d','%D',      '%e','%H','%I','%k','%l','%m','%M','%p','%r',         '%R',   '%S','%T',      '%u','%w','%y','%Y'];
			expected1 = ['%', '20','19','03/19/06','19','18','06','18',' 6','03','20','pm','06:20:03 pm','18:20','03','18:20:03','7', '0', '06','2006'];
			expected2 = ['%', '20','19','03/19/06','19','08','08',' 8',' 8','03','20','am','08:20:03 am','08:20','03','08:20:03','7', '0', '06','2006'];
		}

		for(i in 0...formats.length) {
			var v1 = DateTools.format(d1, formats[i]);
			var v2 = DateTools.format(d2, formats[i]);
			Assert.equals(expected1[i], v1.toLowerCase(), "expected '"+expected1[i]+"' but was '"+v1+"' with format '"+formats[i]+"'");
			Assert.equals(expected2[i], v2.toLowerCase(), "expected '"+expected2[i]+"' but was '"+v2+"' with format '"+formats[i]+"'");
		}
	}

	public function testGetters(){
		var d = new Date(2006,2,19,8,20,3);
		Assert.equals(2006,d.getFullYear());
		Assert.equals(2,d.getMonth());
		Assert.equals(19,d.getDate());
		Assert.equals(8,d.getHours());
		Assert.equals(20,d.getMinutes());
		Assert.equals(3,d.getSeconds());
		Assert.equals(0,d.getDay());
	}

	public function testDayOfMonth(){
		Assert.equals(30,DateTools.getMonthDays(Date.fromString("2006-06-01")));
		Assert.equals(31,DateTools.getMonthDays(Date.fromString("2006-07-01")));
		Assert.equals(29,DateTools.getMonthDays(Date.fromString("2000-02-01")));
		Assert.equals(29,DateTools.getMonthDays(Date.fromString("1996-02-01")));
		Assert.equals(28,DateTools.getMonthDays(Date.fromString("1997-02-01")));
	}
}
