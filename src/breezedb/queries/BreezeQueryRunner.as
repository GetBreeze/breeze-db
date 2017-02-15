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

package breezedb.queries
{
	import breezedb.IBreezeDatabase;

	/**
	 * Base class for classes that create and run SQL queries.
	 */
	public class BreezeQueryRunner
	{
		protected var _db:IBreezeDatabase;

		protected var _queryString:String;
		protected var _queryReference:BreezeQueryReference;

		public function BreezeQueryRunner(db:IBreezeDatabase)
		{
			_db = db;
		}
		

		/**
		 * Executes the query, if it was delayed initially.
		 *
		 * @param callback Function that is triggered when the query is completed. The function's signature
		 *        depends on the original query being executed. Refer to the documentation of the method
		 *        used to create the query.
		 * @return Reference to the executed query.
		 */
		public function exec(callback:Function = null):BreezeQueryReference
		{
			if(_queryReference != null)
			{
				return _queryReference;
			}

			_queryReference = new BreezeRawQuery(_db).query(_queryString, callback);
			return _queryReference;
		}


		/**
		 *
		 *
		 * Getters / Setters
		 *
		 *
		 */


		/**
		 * The SQL query to be executed.
		 */
		public function get queryString():String
		{
			return _queryString;
		}


		/**
		 * Reference to the query that is being executed. It is <code>null</code> if the query execution is delayed.
		 */
		public function get queryReference():BreezeQueryReference
		{
			return _queryReference;
		}
		
	}
	
}
