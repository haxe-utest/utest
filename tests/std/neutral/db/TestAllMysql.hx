/**
 * ...
 * @author Franco Ponticelli
 */

package std.neutral.db;

import utest.Runner;
import utest.ui.Report;

class TestAllMysql
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new TestDbMysql());
		runner.addCase(new TestSPODMysql());
		runner.addCase(new TestSPOD2Mysql());
		runner.addCase(new TestSPOD3Mysql());
		runner.addCase(new TestMySqlMySqlDataType());
#if php
		runner.addCase(new TestDbPdoMysql());
		runner.addCase(new TestSPODPdoMysql());
		runner.addCase(new TestSPOD2PdoMysql());
		runner.addCase(new TestSPOD3PdoMysql());
		runner.addCase(new TestPDOMySqlDataType());
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

class TestDbMysql extends TestDb
{
	public function new() { super(new MysqlConnection()); }
}

class TestSPODMysql extends TestSPOD
{
	public function new() { super(new MysqlConnection()); }
}

class TestSPOD2Mysql extends TestSPOD2
{
	public function new() { super(new MysqlConnection()); }
}

class TestSPOD3Mysql extends TestSPOD3
{
	public function new() { super(new MysqlConnection()); }
}

class TestMySqlMySqlDataType extends TestMySqlDataType
{
	public function new() { super(new MysqlConnection()); }
}

#if php
class TestDbPdoMysql extends TestDb
{
	public function new() { super(new PDOConnection("mysql")); }
}

class TestSPODPdoMysql extends TestSPOD
{
	public function new() { super(new PDOConnection("mysql")); }
}

class TestSPOD2PdoMysql extends TestSPOD2
{
	public function new() { super(new PDOConnection("mysql")); }
}

class TestSPOD3PdoMysql extends TestSPOD3
{
	public function new() { super(new PDOConnection("mysql")); }
}

class TestPDOMySqlDataType extends TestMySqlDataType
{
	public function new() { super(new PDOConnection("mysql")); }
}


#end