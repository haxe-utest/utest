package std.neutral;

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

class TestSPOD3 {
	var cnx : Connection;
	public function new() {	}

	function createSqls() {
		return
		[
			"CREATE TABLE IF NOT EXISTS `people` (
			  `id` INT(10) unsigned NOT NULL auto_increment,
			  `name` VARCHAR(255) NOT NULL,
			  `role_id` INT(10),
			  PRIMARY KEY  (`id`)
			) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;",
			"CREATE TABLE IF NOT EXISTS `roles` (
			  `id` INT(10) unsigned NOT NULL auto_increment,
			  `name` VARCHAR(255) NOT NULL,
			  PRIMARY KEY  (`id`)
			) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;"
		];
	}

	function insertSqls() {
		return [
			"INSERT INTO roles  (id, name) values (1, 'myrole');",
			"INSERT INTO people (id, name, role_id) values (1, 'haXe', 1);"
		];
	}

	public function setup() {
		cnx = MysqlConnection.get();
		if(cnx == null)
			throw "DB Connection Failed";
		Manager.cnx = cnx;
		Manager.initialize();
		for(req in createSqls())
			Manager.cnx.request(req);
		for(req in insertSqls())
			Manager.cnx.request(req);
	}

	function dropSqls() {
		return [
			"DROP TABLE IF EXISTS `people`;",
			"DROP TABLE IF EXISTS `roles`;"
		];
	}

	public function teardown() {
		if(Manager.cnx != null) {
			for(req in dropSqls())
				Manager.cnx.request(req);
			Manager.cleanup();
			Manager.cnx.close();
		}
	}

	public function testGet() {
		var o = PeopleVO.manager.get(1);
		Assert.equals(1, o.id);
		Assert.equals("haXe", o.name);
		var r = o.role;
		Assert.equals(1, r.id);
		Assert.equals("myrole", r.name);
	}

	public function testUpdate() {
		var o = PeopleVO.manager.get(1);
		o.update();
		Assert.isTrue(true);
	}
}