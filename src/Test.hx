import utest.Runner;
import utest.ui.text.TraceReport;

class Test {
	public static function main() {
//		haxe.Firebug.redirectTraces();

		var runner = new Runner();
		runner.addCase(new tests.requests.RequestTest());
		var report = new TraceReport(runner);
		runner.run();
	}
}