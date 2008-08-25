class Test {
	public static function main() {
#if php
		php.Lib.print("<pre>");
#elseif neko
		neko.Lib.print("<pre>");
#end

//		tests.Iteration1.main();
		tests.Iteration2.main();
	}
}