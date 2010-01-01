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

class TestSPOD3 {
	var db : IDb;
	public function new(db : IDb) {
		this.db = db;
	}

	function createTable1() {
		db.createTable("Book",
			['id',        'title',   'shelf_id'],
			['INCREMENT', 'VARCHAR', 'INT NULL']);
	}
	
	function createTable2() {
		db.createTable("Shelf",
			['id',        'name'],
			['INCREMENT', 'VARCHAR']);
	}

	public function setup() {
		db.setup();
		Manager.cnx = db.conn;
		Manager.initialize();
		createTable1();
		createTable2();
	}

	static var entries = [
		"INSERT INTO Shelf (id, name) VALUES (1, 'programming');",
		"INSERT INTO Book (id, title, shelf_id) VALUES (1, 'Professional haXe and Neko', 1);",
		"INSERT INTO Book (id, title, shelf_id) VALUES (2, 'Moby Dick', null);",
		"INSERT INTO Book (id, title, shelf_id) VALUES (3, 'haXe for Dummies', 1);",
	];

	public function teardown() {
		db.dropTable('Book');
		db.dropTable('Shelf');
		Manager.cleanup();
		db.teardown();
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