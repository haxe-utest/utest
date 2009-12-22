/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral;

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


class MysqlConnection
{
	public static function get()
	{
		return Mysql.connect(getParams());
	}
	
	public static function getParams() {
		return {
			host     : "localhost",
			port     : 3306,
			user     : "root",
			pass     : "mypass",
			socket   : null,
			database : "test"
		};
	}
}