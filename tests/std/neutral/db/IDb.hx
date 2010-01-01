/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;
#if php
import php.db.Connection;
#elseif neko
import neko.db.Connection;
#elseif cpp
import cpp.db.Connection;
#end

interface IDb
{
	public var dbname : String;
	public var conn : Connection;
	public function createTable(table : String, fields : Array<String>, types : Array<String>) : Void;
	public function dropTable(table : String) : Void;
	public function setup() : Void;
	public function teardown() : Void;
}