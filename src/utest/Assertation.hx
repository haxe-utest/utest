package utest;

import haxe.CallStack;
import haxe.PosInfos;

/**
 * Enumerates the states available as a result of
 * invoking one of the static methods of @see {@link utest.Assert}.
 */
enum Assertation {
  /**
   * Assertion is succesful
   * @param pos Code position where the Assert call has been executed
   */
  Success(pos:PosInfos);

  /**
   * Assertion is a falure. This does not denote an error in the assertion
   * code but that the testing condition has failed for some reason.
   * Ei.: Assert.isTrue(1 == 0);
   * @param msg An error message containing the reasons for the failure.
   * @param pos Code position where the Assert call has been executed
   */
  Failure(msg:String, pos:PosInfos);

  /**
   * An error has occurred during the execution of the test that prevents
   * futher assertion to be tested.
   * @param e The captured error/exception
   */
  Error(e:Dynamic, stack:Array<StackItem>);

  /**
   * An error has occurred during the Setup phase of the test. It prevents
   * the test to be run.
   * @param e The captured error/exception
   */
  SetupError(e:Dynamic, stack:Array<StackItem>);

  /**
   * An error has occurred during the Teardown phase of the test.
   * @param e The captured error/exception
   */
  TeardownError(e:Dynamic, stack:Array<StackItem>);

  /**
   * The asynchronous phase of a test has gone into timeout.
   * @param missedAsyncs The number of asynchronous calls that was expected
   * to be performed before the timeout.
   */
  TimeoutError(missedAsyncs:Int, stack:Array<StackItem>);

  /**
   * An error has occurred during an asynchronous test.
   * @param e The captured error/exception
   */
  AsyncError(e:Dynamic, stack:Array<StackItem>);

  /**
   * A warning state. This can be declared explicitely by an Assert call
   * or can denote a test method that contains no assertions at all.
   * @param msg The reason behind the warning
   */
  Warning(msg:String);

  /**
   * Test is ignored.
   * @param reason Reason of test ignoring.
   */
  Ignore(reason:String);
}