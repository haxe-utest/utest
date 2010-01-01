/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;

import utest.Assert;

class TestSqliteDataType
{
	var table : String;
	var db : IDb;
	
	public function new(db : IDb) {
		table = "UTEST_TEST";
		this.db = db;
	}
	
	function insert(cint : Int, creal : Float, ctext : String, cblob : String) {
		db.conn.request("INSERT INTO "+table+" VALUES(NULL, NULL, " + cint + ", " + creal + ", " + db.conn.quote(ctext) + ", " + db.conn.quote(cblob) + ");");
	}

	function select() {
		return db.conn.request("SELECT * FROM "+table+" ORDER BY id");
	}

	function count() {
		return db.conn.request("SELECT COUNT(*) FROM "+table).getIntResult(0);
	}

	public function setup() {
		db.setup();
		db.createTable(table,
			["id",        "cnull",     "cint",    "creal", "ctext", "cblob"],
			["INCREMENT", "TEXT NULL", "INTEGER", "REAL",  "TEXT",  "BLOB"]);
	}
	
	public function teardown() {
		db.dropTable(table);
		db.teardown();
	}
	
	public function testTypes() {
		insert(1, 0.1, "text", "BLOB");
		Assert.equals(1, count());
		var o = select().next();
		Assert.isNull(o.cnull);
		Assert.is(o.cint,  Int);
		Assert.is(o.creal, Float);
		Assert.is(o.ctext, String);
		Assert.is(o.cblob, String);
		
		Assert.equals(1,      o.cint);
		Assert.equals(0.1,    o.creal);
		Assert.equals("text", o.ctext);
		Assert.equals("BLOB", o.cblob);
	}
}