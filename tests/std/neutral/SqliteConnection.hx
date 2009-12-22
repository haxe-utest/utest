/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral;

#if php
import php.Sys;
import php.db.Connection;
import php.db.Sqlite;
#elseif neko
import neko.Sys;
import neko.db.Connection;
import neko.db.Sqlite;
#elseif cpp
import cpp.Sys;
import cpp.db.Connection;
import cpp.db.Sqlite;
#end

class SqliteConnection
{
	public static function get() : Connection {
		return Sqlite.open(getFile());
	}
	
	public static function getFile() {
		return Sys.getCwd() + #if php "test.php.db" #elseif neko "test.neko.db"  #elseif cpp "test.cpp.db" #end;
	}
}