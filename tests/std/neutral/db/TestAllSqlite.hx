/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;

import utest.Runner;
import utest.ui.Report;

class TestAllSqlite
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new TestDbSqlite());
		runner.addCase(new TestSPODSqlite());
		runner.addCase(new TestSPOD2Sqlite());
		runner.addCase(new TestSPOD3Sqlite());
#if !php // Sqlite driver returns only text values
		runner.addCase(new TestSqliteSqliteDataType());
#end
#if php
		runner.addCase(new TestDbPDOSqlite());
		runner.addCase(new TestSPODPDOSqlite());
		runner.addCase(new TestSPOD2PDOSqlite());
		runner.addCase(new TestSPOD3PDOSqlite());
		runner.addCase(new TestPDOSqliteSqliteDataType());
#end
	}
	
	public static function main()
	{
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}
}

class TestDbSqlite extends TestDb
{
	public function new() {
		super(new SqliteConnection());
#if php
		supportsStringOnly = true;
#end
	}
}

class TestSPODSqlite extends TestSPOD
{
	public function new() { super(new SqliteConnection()); }
}

class TestSPOD2Sqlite extends TestSPOD2
{
	public function new() {
		super(new SqliteConnection());
#if php
		supportsStringOnly = true;
#end
	}
}

class TestSPOD3Sqlite extends TestSPOD3
{
	public function new() { super(new SqliteConnection()); }
}

class TestSqliteSqliteDataType extends TestSqliteDataType
{
	public function new() { super(new SqliteConnection()); }
}

#if php
class TestDbPDOSqlite extends TestDb
{
	public function new() {
		super(new PDOConnection("sqlite"));
	}
}

class TestSPODPDOSqlite extends TestSPOD
{
	public function new() { super(new PDOConnection("sqlite")); }
}

class TestSPOD2PDOSqlite extends TestSPOD2
{
	public function new() { super(new PDOConnection("sqlite")); }
}

class TestSPOD3PDOSqlite extends TestSPOD3
{
	public function new() { super(new PDOConnection("sqlite")); }
}

class TestPDOSqliteSqliteDataType extends TestSqliteDataType
{
	public function new() { super(new PDOConnection("sqlite")); }
}
#end