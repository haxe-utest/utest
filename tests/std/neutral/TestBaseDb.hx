package std.neutral;

import utest.Assert;

#if php
import php.db.Connection;
#else
import neko.db.Connection;
#end

class TestBaseDb {
	var dbtype : String;
	var table : String;
	public function new() { }

	function getConnection() : Connection {
		return throw "Abstract method";
	}

	function createSql() {
		return "CREATE TABLE "+table+" (id INTEGER PRIMARY KEY, name VARCHAR(255));";
	}

	function dropSql() {
		return "DROP TABLE "+table+";";
	}

	function insertSql(name : String) {
		return "INSERT INTO "+table+" VALUES(NULL, '" + db.escape(name) + "');";
	}

	function selectSql() {
		return "SELECT * FROM "+table+"";
	}

	function selectCountSql() {
		return "SELECT COUNT(*) FROM "+table+"";
	}

	var db : Connection;
	public function setup() {
		db = getConnection();
		if(db == null)
			throw "DB Connection Failed";
		db.request(createSql());
	}

	public function teardown() {
		if(db != null) {
			db.request(dropSql());
			db.close();
		}
	}

	public function testOpen() {
		Assert.equals(dbtype, db.dbName());
	}

	public function testInsertSelect() {
		var comp = ["haXe", "Neko"];

		var lastid = db.lastInsertId();
		for(n in comp) {
			db.request(insertSql(n));
			Assert.equals(lastid+1, db.lastInsertId());
			lastid = db.lastInsertId();
		}

		var rs = db.request(selectCountSql());
		Assert.equals(2, rs.getIntResult(0));

		rs = db.request(selectSql());
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
		var rows = ["haXe", "Neko"];
		for(row in rows)
			db.request(insertSql(row));
		var rs = db.request(selectSql());
		Assert.equals(1, rs.getIntResult(0));
		Assert.equals("haXe", rs.getResult(1));
		rs.next();
		Assert.equals(2, rs.getIntResult(0));
		Assert.equals("Neko", rs.getResult(1));
	}
	
	public function testTransaction() {
		var comp = ["haXe", "Neko"];

		try {
			db.startTransaction();
			for(n in comp)
				db.request(insertSql(n));
			db.commit();
		} catch(e : Dynamic) {
			db.rollback();
		}
		var rs = db.request(selectCountSql());
		Assert.equals(2, rs.getIntResult(0));
	}

	public function testRollback() {
		var comp = ["haXe", "Neko"];

		try {
			db.startTransaction();
			for(n in comp)
				db.request(insertSql(n));
			throw "Problem";
			db.commit();
		} catch(e : Dynamic) {
			db.rollback();
		}
		var rs = db.request(selectCountSql());
		Assert.equals(0, rs.getIntResult(0));
	}
}