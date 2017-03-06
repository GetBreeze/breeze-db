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
	import breezedb.queries.BreezeSQLResult;

	import flash.events.Event;

	/**
	 * Event dispatched when a SQL query execution is finished, either successfully or with an error.
	 */
	public class BreezeQueryEvent extends Event
	{
		/**
		 * A query was executed successfully.
		 */
		public static const SUCCESS:String = "BreezeQueryEvent::success";

		/**
		 * Failed to execute a query.
		 */
		public static const ERROR:String = "BreezeQueryEvent::error";

		private var _error:Error;
		private var _result:BreezeSQLResult;
		private var _query:String;


		/**
		 * @private
		 */
		public function BreezeQueryEvent(type:String, error:Error, result:BreezeSQLResult, query:String)
		{
			super(type, false, false);
			_error = error;
			_result = result;
			_query = query;
		}
		

		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new BreezeQueryEvent(type, _error, _result, _query);
		}


		/**
		 * Error that occurred while executing the query, or <code>null</code> if there is no error.
		 */
		public function get error():Error
		{
			return _error;
		}


		/**
		 * SQL result of the query. It is <code>null</code> for queries regarding table / column schema.
		 */
		public function get result():BreezeSQLResult
		{
			return _result;
		}


		/**
		 * The raw SQL query that was executed.
		 */
		public function get query():String
		{
			return _query;
		}
	}
	
}
