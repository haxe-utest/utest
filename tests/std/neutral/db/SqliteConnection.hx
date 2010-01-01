/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;

#if php
import php.Sys;
import php.Web;
import php.db.Connection;
import php.db.Sqlite;
#elseif neko
import neko.Sys;
import neko.Web;
import neko.db.Connection;
import neko.db.Sqlite;
#elseif cpp
import cpp.Sys;
import cpp.Web;
import cpp.db.Connection;
import cpp.db.Sqlite;
#end

class SqliteConnection implements IDb
{
	static function base()
	{
		var dir = Sys.getCwd();
		if ("/" == dir || "\\" == dir)
			dir = Web.getCwd();
		var last = dir.substr( -1);
		if ("/" == last || "\\" == last)
			dir = dir.substr(0, -1);
		return dir;
	}
	
	public static function getFile() {
		return base() + "/" + #if php "test.php.db" #elseif neko "test.neko.db"  #elseif cpp "test.cpp.db" #end;
	}
	
	public var conn : Connection;
	public var dbname : String;
	public function new()
	{
		dbname = "sqlite";
	}
	
	public function createTable(table : String, fields : Array<String>, types : Array<String>)
	{
		var f = [];
		for (i in 0...fields.length)
			f.push(fields[i] + " " + normalize(types[i]));
		var sql = "CREATE TABLE " + table + " ("
				+ f.join(", ")
				+ ");";
		conn.request(sql);
	}
	
	public function dropTable(table : String)
	{
		var sql = "DROP TABLE " + table + ";";
		try {
			conn.request(sql);
		} catch(e : Dynamic){}
	}
	
	function normalize(type : String)
	{
		switch(type)
		{
			case "INCREMENT":
				return "INTEGER PRIMARY KEY";
			case "VARCHAR":
				return "VARCHAR(255)";
			default:
				return type;
		}
	}
	
	public function setup()
	{
		if (null == conn)
			conn = Sqlite.open(getFile());
	}
	
	public function teardown()
	{
		try {
			conn.close();
		} catch(e : Dynamic) { trace(e); }
		conn = null;
		std.neutral.TestFileSystem.aggressiveDelete(SqliteConnection.getFile());
	}
}