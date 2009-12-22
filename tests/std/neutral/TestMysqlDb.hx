package std.neutral;

import utest.Assert;

#if php
import php.db.Connection;
import php.db.Mysql;
#else
import neko.db.Connection;
import neko.db.Mysql;
#end

class TestMysqlDb extends TestBaseDb {
	public function new() {
		super();
		dbtype = "MySQL";
		table = #if php "php_" #else "neko_" #end+"Person";
	}

	override function getConnection() : Connection {
		return MysqlConnection.get();
	}
	override function createSql() {
		return "CREATE TABLE "+table+" (id INTEGER PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255));";
	}

	public function testOpenUnexistantDb() {
		var params = MysqlConnection.getParams();
		params.database = "doIexist???";
		Assert.raises(function() Mysql.connect(params), Dynamic);
	}
}