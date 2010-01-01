package std.neutral.db;

#if php
import php.db.Connection;
import php.db.Mysql;
import php.db.Manager;
#else
import neko.db.Connection;
import neko.db.Mysql;
import neko.db.Manager;
#end

import utest.Assert;
import std.neutral.utils.PeopleVO;

class TestSPOD2 {
	var db : IDb;
	var supportsStringOnly : Bool;
	public function new(db : IDb) {
		this.db = db;
		supportsStringOnly = false;
	}

	function createTables() {
		db.createTable("people",
			['id',        'name',    'role_id'],
			['INCREMENT', 'VARCHAR', 'INT']);
		db.createTable("roles",
			['id',        'name'],
			['INCREMENT', 'VARCHAR']);
	}

	function insertSqls() {
		return [
			"INSERT INTO roles  (id, name) values (1, 'myrole');",
			"INSERT INTO people (id, name, role_id) values (1, 'haXe', 1);"
		];
	}

	public function setup() {
		db.setup();
		Manager.cnx = db.conn;
		Manager.initialize();
		createTables();
		for(sql in insertSqls())
			Manager.cnx.request(sql);
	}

	function dropTables() {
		db.dropTable('people');
		db.dropTable('roles');
	}

	public function teardown() {
		dropTables();
		Manager.cleanup();
		db.teardown();
	}

	public function testGet() {
		var o = PeopleVO.manager.get(1);
		if (supportsStringOnly)
			Assert.equals("1", o.id);
		else
			Assert.equals(1, o.id);
		Assert.equals("haXe", o.name);
		var r = o.role;
		if (supportsStringOnly)
			Assert.equals("1", r.id);
		else
			Assert.equals(1, r.id);
		Assert.equals("myrole", r.name);
	}

	public function testUpdate() {
		var o = PeopleVO.manager.get(1);
		o.update();
		Assert.isTrue(true);
	}
}