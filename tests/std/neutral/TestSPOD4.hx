package std.neutral;

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

class TestSPOD4 {
	public function new() { }

	function createSql1() {
		return "CREATE TABLE Book (
    id INT NOT NULL auto_increment,
    title VARCHAR(32) NOT NULL,
    shelf_id INT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB";
	}

	function createSql2() {
		return "CREATE TABLE Shelf (
    id INT NOT NULL auto_increment,
    name VARCHAR(32) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB";
	}

	public function setup() {
		Manager.cnx = MysqlConnection.get();
		if(Manager.cnx == null)
			throw "DB Connection Failed";
		Manager.initialize();
		Manager.cnx.request(createSql1());
		Manager.cnx.request(createSql2());
	}

	static var entries = [
		"INSERT INTO Shelf (id, name) VALUES (1, 'programming');",
		"INSERT INTO Book (id, title, shelf_id) VALUES (1, 'Professional haXe and Neko', 1);",
		"INSERT INTO Book (id, title, shelf_id) VALUES (2, 'Moby Dick', null);",
		"INSERT INTO Book (id, title, shelf_id) VALUES (3, 'haXe for Dummies', 1);",
	];

	function dropSql1() {
		return "DROP TABLE IF EXISTS Book;";
	}

	function dropSql2() {
		return "DROP TABLE IF EXISTS Shelf;";
	}

	public function teardown() {
		if(Manager.cnx != null) {
			Manager.cnx.request(dropSql1());
			Manager.cnx.request(dropSql2());
			Manager.cleanup();
			Manager.cnx.close();
		}
	}

	public function testUse() {
		for(entry in entries)
			Manager.cnx.request(entry);
		var book = Book.manager.loadIdOne();

		Assert.equals("Professional haXe and Neko", book.title);
		Assert.equals("programming", book.shelf.name);

		var shelf = book.shelf;

		var books = shelf.getBooks();

		Assert.equals(2, books.length);

		book.title +=  "!";
		shelf.name += "!";

		book.update();
		shelf.update();

		untyped BookManager.object_cache = new Hash();
		untyped ShelfManager.object_cache = new Hash();

		var book = Book.manager.loadIdOne();

		Assert.equals("Professional haXe and Neko!", book.title);
		Assert.equals("programming!", book.shelf.name);
	}
}

class Book extends Object {
    public var id : Int;
    public var title : String;
	private var shelf_id : Int;

    public var shelf(dynamic,dynamic) : Shelf;

	static function RELATIONS() {
		return [{ key : "shelf_id", prop : "shelf", manager : Shelf.manager }];
	}

    public static var manager = new BookManager();
}

class Shelf  extends Object {
    public var id : Int;
    public var name: String;
    public static var manager = new ShelfManager();

	public function getBooks() {
		return manager.loadBooks(this.id);
	}
}

class BookManager extends Manager<Book> {
	public function new() {
		super(Book);
	}

	public function loadIdOne() {
		return get(1);
	}
}

class ShelfManager extends Manager<Shelf> {
	public function new() {
		super(Shelf);
	}

	public function loadBooks(shelf_id : Int) {
		return Book.manager.search({
			shelf_id : shelf_id
		});
	}
}