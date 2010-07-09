package std.neutral.db;

import utest.Assert;

#if php
import php.db.Connection;
#elseif neko
import neko.db.Connection;
#end

class TestDb {
	var table : String;
	var supportsStringOnly : Bool;
	var db : IDb;
	
	public function new(db : IDb) {
		table = "UTEST_TEST";
		supportsStringOnly = false;
		this.db = db;
	}
	
	function insertSql(name : String) {
		return "INSERT INTO "+table+" VALUES(NULL, '" + db.conn.escape(name) + "');";
	}

	function selectSql() {
		return "SELECT id, name FROM "+table+" ORDER BY name";
	}

	function selectCountSql() {
		return "SELECT COUNT(*) FROM "+table+"";
	}

	public function setup() {
		db.setup();
		db.createTable(table,
			["id",        "name"],
			["INCREMENT", "VARCHAR"]);
	}

	public function teardown() {
		db.dropTable(table);
		db.teardown();
	}

	public function testOpen() {
		Assert.equals(db.dbname.toLowerCase(), db.conn.dbName().toLowerCase());
	}

	public function testInsertSelect() {
		var comp = ["haxe", "neko"];

		var lastid = db.conn.lastInsertId();
		for(n in comp) {
			db.conn.request(insertSql(n));
			Assert.equals(lastid+1, db.conn.lastInsertId());
			lastid = db.conn.lastInsertId();
		}

		var rs = db.conn.request(selectCountSql());
		Assert.equals(2, rs.getIntResult(0));

		rs = db.conn.request(selectSql());
		Assert.equals(2, rs.length);

		var i = 0;
		while(rs.hasNext()) {
			var o = rs.next();
			Assert.isTrue(Std.int(o.id) > 0);
			Assert.equals(comp[i], o.name);
			i++;
		}
	}

	public function testGetResult() {
		var rows = ["haxe", "neko"];
		for(row in rows)
			db.conn.request(insertSql(row));
		var rs = db.conn.request(selectSql());
		var ob = rs.next();
		if(supportsStringOnly)
			Assert.equals("1", ob.id);
		else
			Assert.equals(1, ob.id);
		Assert.equals("haxe", ob.name);
		ob = rs.next();
		if(supportsStringOnly)
			Assert.equals("2", ob.id);
		else
			Assert.equals(2, ob.id);
		Assert.equals("neko", ob.name);
	}
	
	public function testTransaction() {
		var comp = ["haxe", "neko"];

		try {
			db.conn.startTransaction();
			for(n in comp)
				db.conn.request(insertSql(n));
			db.conn.commit();
		} catch (e : Dynamic) {
			db.conn.rollback();
		}
		var rs = db.conn.request(selectCountSql());
		Assert.equals(2, rs.getIntResult(0));
	}

	public function testRollback() {
		var comp = ["haxe", "neko"];

		try {
			db.conn.startTransaction();
			for(n in comp)
				db.conn.request(insertSql(n));
			throw "Problem";
			db.conn.commit();
		} catch(e : Dynamic) {
			db.conn.rollback();
		}
		var rs = db.conn.request(selectCountSql());
		Assert.equals(0, rs.getIntResult(0));
	}
}