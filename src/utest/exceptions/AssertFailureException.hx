package utest.exceptions;

/**
	Thrown on a failed assert if `UTEST_FAILURE_THROW` is defined.
	
	UTest can throw an unhandled exception instead of adding a failure to the report.

	Enable this behavior with `-D UTEST_FAILURE_THROW`, or by adding `UTEST_FAILURE_THROW` to the environment variables at compile time.

	In this case any exception or failure in test or setup methods will lead to a crash.
	Instead of a test report you will see an unhandled exception message with the exception
	stack trace (depending on a target platform).
**/
class AssertFailureException extends UTestException {
}