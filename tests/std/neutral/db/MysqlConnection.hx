/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;

#if php
import php.Sys;
import php.db.Connection;
import php.db.Mysql;
#elseif neko
import neko.Sys;
import neko.db.Connection;
import neko.db.Mysql;
#elseif cpp
import cpp.Sys;
import cpp.db.Connection;
import cpp.db.Mysql;
#end


class MysqlConnection implements IDb
{
	public var conn : Connection;
	public var dbname : String;
	public function new()
	{
		dbname = "mysql";
	}
	
	public function createTable(table : String, fields : Array<String>, types : Array<String>)
	{
		var f = [];
		for (i in 0...fields.length)
			f.push(fields[i] + " " + normalize(types[i]));
			
		var sql = "CREATE TABLE " + table + " ("
				+ f.join(", ")
				+ ") ENGINE = 'InnoDB';";
		conn.request(sql);
	}
	
	public function dropTable(table : String)
	{
		var sql = "DROP TABLE IF EXISTS " + table + ";";
		try {
			conn.request(sql);
		} catch (e : Dynamic) { trace(e); }
	}
	
	function normalize(type : String)
	{
		switch(type)
		{
			case "INCREMENT":
				return "INTEGER PRIMARY KEY AUTO_INCREMENT";
			case "VARCHAR":
				return "VARCHAR(255)";
			default:
				return type;
		}
	}
	
	public function setup()
	{
		if (null == conn)
			conn = Mysql.connect(getParams());
	}
	
	public function teardown()
	{
		try {
			conn.close();
		} catch(e : Dynamic) { trace(e); }
		conn = null;
	}
	
	static public function getParams() {
		return {
			host     : "127.0.0.1",
			port     : 3306,
			user     : "root",
			pass     : "mypass",
			socket   : null,
			database : "test"
		};
	}
}