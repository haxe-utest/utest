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
import std.neutral.utils.TestVO;


class TestSPOD2 {
	var cnx : Connection;
	public function new() {	}

	function createSql() {
		return "CREATE TABLE IF NOT EXISTS `test` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `test_date` timestamp NOT NULL,
  `test_string` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;";
	}

	function insertSql() {
		return "INSERT INTO test (test_date,test_string) values (curdate(),curdate());";
	}

	public function setup() {
		cnx = MysqlConnection.get();
		if(cnx == null)
			throw "DB Connection Failed";
		Manager.cnx = cnx;
		Manager.initialize();
		Manager.cnx.request(createSql());
		Manager.cnx.request(insertSql());
	}

	function dropSql() {
		return "DROP TABLE IF EXISTS `test`;";
	}

	public function teardown() {
		if(Manager.cnx != null) {
			Manager.cnx.request(dropSql());
			Manager.cleanup();
			Manager.cnx.close();
		}
	}

	public function testSearch() {
		var l : List<TestVO> = TestVO.manager.search({ id : 1});
		Assert.equals(1, l.length);
		var o = l.first();
		Assert.isTrue(Std.is(o, TestVO));
		Assert.equals(DateTools.format(Date.now(), '%Y-%m-%d'), o.test_string);
		Assert.equals(DateTools.format(Date.now(), '%Y-%m-%d')+' 00:00:00', o.test_date);
	}

	public function testGet() {
		var o = TestVO.manager.get(1);
		Assert.isTrue(Std.is(o, TestVO));
		Assert.equals(DateTools.format(Date.now(), '%Y-%m-%d'), o.test_string);
		Assert.equals(DateTools.format(Date.now(), '%Y-%m-%d')+' 00:00:00', o.test_date);
	}

	public function testUpdate() {
		var o = TestVO.manager.get(1);
		o.update();
		Assert.isTrue(true);
	}
}