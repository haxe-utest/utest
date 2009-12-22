package std.neutral;

import utest.Assert;

#if php
import php.db.Connection;
import php.db.Sqlite;
import php.Sys;
import php.FileSystem;
#else
import neko.db.Connection;
import neko.db.Sqlite;
import neko.Sys;
import neko.FileSystem;
#end

class TestSQLiteDb extends TestBaseDb {
	public function new() {
		super();
		dbtype = "SQLite";
	}

	override function getConnection() : Connection {
		return SqliteConnection.get();
	}

	override public function teardown() {
		super.teardown();
		var file = SqliteConnection.getFile();
		if(FileSystem.exists(file))
			FileSystem.deleteFile(file);
	}
}