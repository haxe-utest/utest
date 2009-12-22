package native.php.utils;

extern class ExternClass {
	function new() : Void;
	var x : String;

	static function __init__() : Void {
		untyped __php__("class ExternClass { public $x = 'haxe'; }\nclass ExternClassNoInit { public $x = 'php'; }");
	}
}