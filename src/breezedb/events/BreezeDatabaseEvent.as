/*
 * MIT License
 *
 * Copyright (c) 2017 Digital Strawberry LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

package breezedb.events
{
	import flash.events.Event;

	/**
	 * Event dispatched after one of the database operations is executed.
	 */
	public class BreezeDatabaseEvent extends Event
	{

		/**
		 * A transaction has begun successfully.
		 */
		public static const BEGIN_SUCCESS:String = "BreezeDatabaseEvent::beginSuccess";

		/**
		 * Failed to begin a transaction.
		 */
		public static const BEGIN_ERROR:String = "BreezeDatabaseEvent::beginError";

		/**
		 * A transaction was committed successfully.
		 */
		public static const COMMIT_SUCCESS:String = "BreezeDatabaseEvent::commitSuccess";

		/**
		 * Failed to commit a transaction.
		 */
		public static const COMMIT_ERROR:String = "BreezeDatabaseEvent::commitError";

		/**
		 * A transaction was rolled back successfully.
		 */
		public static const ROLL_BACK_SUCCESS:String = "BreezeDatabaseEvent::rollBackSuccess";

		/**
		 * Failed to roll back a transaction.
		 */
		public static const ROLL_BACK_ERROR:String = "BreezeDatabaseEvent::rollBackError";

		/**
		 * A database has been set up successfully.
		 */
		public static const SETUP_SUCCESS:String = "BreezeDatabaseEvent::setupSuccess";

		/**
		 * Failed to set up a database.
		 */
		public static const SETUP_ERROR:String = "BreezeDatabaseEvent::setupError";

		/**
		 * A database was closed successfully.
		 */
		public static const CLOSE_SUCCESS:String = "BreezeDatabaseEvent::closeSuccess";

		/**
		 * Failed to close a database.
		 */
		public static const CLOSE_ERROR:String = "BreezeDatabaseEvent::closeError";


		private var _error:Error;
		

		/**
		 * @private
		 */
		public function BreezeDatabaseEvent(type:String, error:Error = null)
		{
			super(type, false, false);

			_error = error;
		}
		

		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new BreezeDatabaseEvent(type, _error);
		}


		/**
		 * Error that occurred while executing the corresponding operation, or <code>null</code> if there is no error.
		 */
		public function get error():Error
		{
			return _error;
		}
	}
	
}
