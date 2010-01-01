/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;

import php.db.Connection;
import php.db.PDO;

class PDOConnection implements IDb
{
	public var conn : Connection;
	public var dbname : String;
	var sconn : IDb;
	public function new(dbname : String)
	{
		this.dbname = dbname;
	}
	
	public function createTable(table : String, fields : Array<String>, types : Array<String>)
	{
		sconn.createTable(table, fields, types);
	}
	
	public function dropTable(table : String)
	{
		sconn.dropTable(table);
	}
	
	function normalize(type : String)
	{
		switch(type)
		{
			default:
				return type;
		}
	}
	
	public function setup()
	{
		switch(dbname.toLowerCase())
		{
			case "mysql":
				conn = getMysql();
				sconn = new MysqlConnection();
			case "sqlite":
				conn = getSQLite();
				sconn = new SqliteConnection();
			case "sqlite2":
				conn = getSQLite2();
				sconn = new SqliteConnection();
		}
		sconn.conn = conn;
		sconn.setup();
	}
	
	public function teardown()
	{
		sconn.teardown();
	}
	
	public static function getMysql()
	{
		var params = MysqlConnection.getParams();
		var values = ['host=' + params.host];
		values.push('dbname=' + params.database);
		if(null != params.port)
			values.push('port='   + params.port);
		if(null != params.socket)
			values.push('socket=' + params.socket);
		return PDO.open("mysql:" + values.join(';'), params.user, params.pass);
	}
	
	public static function getSQLite()
	{
		return PDO.open("sqlite:" + SqliteConnection.getFile());
	}
	
	public static function getSQLite2()
	{
		return PDO.open("sqlite2:" + SqliteConnection.getFile());
	}
}