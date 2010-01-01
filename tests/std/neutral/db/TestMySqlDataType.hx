/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;

import utest.Assert;

class TestMySqlDataType
{
	var table : String;
	var db : IDb;
	
	public function new(db : IDb) {
		table = "UTEST_TEST";
		this.db = db;
	}
	
	function insert(values : Array<Dynamic>) {
		db.conn.request("INSERT INTO "+table+" VALUES(NULL, " + values.join(", ") + ");");
	}

	function select() {
		return db.conn.request("SELECT * FROM "+table+" ORDER BY id");
	}

	function count() {
		return db.conn.request("SELECT COUNT(*) FROM "+table).getIntResult(0);
	}
	
	function createTable(fields : Array<String>, types : Array<String>) {
		db.createTable(table, ["id"].concat(fields), ["INCREMENT"].concat(types));
	}

	public function setup() {
		db.setup();
	}
	
	public function teardown() {
		db.dropTable(table);
		db.teardown();
	}
	
	public function testNumericTypes() {
		createTable(
			   ["cbit", "ctinyint", "cbool", "csmallint", "cmediumint", "cint", "cbigint", "cfloat", "cdouble", "cdoubleprecision", "cdecimal"],
			   ["BIT",  "TINYINT",  "BOOL",  "SMALLINT",  "MEDIUMINT",  "INT",  "BIGINT",  "FLOAT",  "DOUBLE",  "DOUBLE PRECISION", "DECIMAL(10,2)"]);
		insert([1,      1,          true,    32767,       8388607,      1,      1,         0.1,      0.1,       0.1,                0.1]);
		
		Assert.equals(1, count());
		var o = select().next();
#if php
		Assert.is(o.cbit, Int);
		Assert.equals(1, o.cbit);
		Assert.is(o.cbool, Int);
		Assert.equals(1, o.cbool);
#else
		Assert.is(o.cbit, String);
		Assert.equals(String.fromCharCode(1), o.cbit);
		Assert.is(o.cbool, Bool);  // TInt
		Assert.equals(true, o.cbool);  // 1
#end
		Assert.is(o.ctinyint,   Int);
		
		Assert.is(o.csmallint,  Int);
		Assert.is(o.cmediumint, Int);
		Assert.is(o.cint,       Int);
		Assert.is(o.cbigint,    Float);
		Assert.is(o.cfloat,     Float);
		Assert.is(o.cdouble,    Float);
		Assert.is(o.cdoubleprecision, Float);
		Assert.is(o.cdecimal,   Float);
		
		Assert.equals(1,       o.ctinyint);
		Assert.equals(32767,   o.csmallint);
		Assert.equals(8388607, o.cmediumint);
		Assert.equals(1,       o.cint);
		Assert.equals(1,       o.cbigint);
		Assert.equals(0.1,     o.cfloat);
		Assert.equals(0.1,     o.cdouble);
		Assert.equals(0.1,     o.cdoubleprecision);
		Assert.equals(0.1,     o.cdecimal);
	}
	
	function q(s : String)
	{
		return "'" + s + "'";
	}
	
	public function testDateTimeTypes() {
		var year2 = "10";
		var year4 = "20" + year2;
		var sdate = year4 + "-12-01";
		var time  = "23:59:59";
		var tdate = sdate + " " + time;
		createTable(
			   ["cdate",  "cdatetime", "ctimestamp", "ctime", "cyear2",  "cyear4"],
			   ["DATE",   "DATETIME",  "TIMESTAMP",  "TIME",  "YEAR(2)", "YEAR(4)"]);
		insert([q(sdate), q(tdate),    q(tdate),     q(time), year2,     year4]);
		
		Assert.equals(1, count());
		var o = select().next();
		
		Assert.is(o.cdate,      Date);
		Assert.is(o.cdatetime,  Date);
		Assert.is(o.ctimestamp, String);
		Assert.is(o.ctime,      String);
		
		var time1 = Date.fromString(sdate).getTime();
		var time2 = Date.fromString(tdate).getTime();
		
		Assert.equals(time1, cast(o.cdate, Date).getTime());
		Assert.equals(time2, cast(o.cdatetime, Date).getTime());
		Assert.equals(tdate, o.ctimestamp);
		Assert.equals(time,  o.ctime);

#if php
		Assert.is(o.cyear2, Int);
		Assert.is(o.cyear4, Int);
		Assert.equals(Std.parseInt(year2), o.cyear2);
		Assert.equals(Std.parseInt(year4), o.cyear4);
#else
		Assert.is(o.cyear2, String);
		Assert.is(o.cyear4, String);
		Assert.equals(year2, o.cyear2);
		Assert.equals(year4, o.cyear4);
#end
	}
}