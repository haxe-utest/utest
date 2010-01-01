package std.neutral.db;

import utest.Assert;

#if php
import php.db.Connection;
import php.db.Mysql;
import php.db.Manager;
import php.db.Object;
#else
import neko.db.Connection;
import neko.db.Mysql;
import neko.db.Manager;
import neko.db.Object;
#end

class TestSPOD {
	var db : IDb;
	public function new(db : IDb) {
		this.db = db;
	}

	function createTable() {
		db.createTable("User",
			['id',        'name',    'age',          'parentId'],
			['INCREMENT', 'VARCHAR', 'INT NOT NULL', 'INT NULL']);
	}

	public function setup() {
		db.setup();
		Manager.cnx = db.conn;
		if(Manager.cnx == null)
			throw "DB Connection Failed";
		Manager.initialize();
		createTable();
	}

	public function teardown() {
		db.dropTable("User");
		if(Manager.cnx != null) {
			Manager.cleanup();
		}
		db.teardown();
	}

	private function createSampleUser() {
		var user = new User();
		user.id   = 1;
		user.name = "haXe";
		user.age  = 3;
		return user;
	}

	public function testUse() {
		Assert.equals(0, User.manager.count());
		var user = createSampleUser();
		user.insert();
		Assert.equals(1, User.manager.count());
		user = User.manager.get(1);
		Assert.equals(1, user.id);
		Assert.equals("haXe", user.name);
		Assert.equals(3, user.age);
		user.age++;
		user.update();
		user = User.manager.get(1);
		Assert.equals(4, user.age);
		user.delete();
		Assert.equals(0, User.manager.count());
	}

	public function testCache() {
		var user = createSampleUser();
		user.insert();
		user = User.manager.get(1);
		Assert.equals(1, user.id);
		db.dropTable("User");
		user = User.manager.get(1);
		Assert.equals(1, user.id);
	}

	public function testRelations() {
		var user = createSampleUser();
		user.insert();

		var other = new User();
		other.name = "Neko";
		other.age = 30;
		other.insert();
		other.parent = user;
		other.update();
		Assert.equals("haXe", other.parent.name);
	}
}

class User extends Object {
    public var id : Int;
    public var name : String;
    public var age : Int;
	private var parentId : Int;

    public var parent(dynamic,dynamic) : User;

	static function RELATIONS() {
		return [{ key : "parentId", prop : "parent", manager : User.manager }];
	}

    public static var manager = new Manager<User>(User);
}