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
		/**
		 * @private
		 */
		protected static const MULTI_QUERY_RAW:int = 0;

		/**
		 * @private
		 */
		protected static const MULTI_QUERY_FAIL_ON_ERROR:int = 1;

		/**
		 * @private
		 */
		protected static const MULTI_QUERY_TRANSACTION:int = 2;

		/**
		 * @private
		 */
		protected static const QUERY_RAW:int = 0;

		/**
		 * @private
		 */
		protected static const QUERY_SELECT:int = 1;

		/**
		 * @private
		 */
		protected static const QUERY_DELETE:int = 2;

		/**
		 * @private
		 */
		protected static const QUERY_INSERT:int = 3;

		/**
		 * @private
		 */
		protected static const QUERY_UPDATE:int = 4;

		/**
		 * @private
		 */
		protected var _db:IBreezeDatabase;

		/**
		 * @private
		 */
		protected var _queryString:String;

		/**
		 * @private
		 */
		protected var _queryType:int;

		/**
		 * @private
		 */
		protected var _queryParams:*;

		/**
		 * @private
		 */
		protected var _queryReference:BreezeQueryReference;

		/**
		 * @private
		 */
		protected var _multiQueryMethod:int;

		/**
		 * @private
		 * Only the first item in the SELECT result is returned to the callback.
		 */
		protected var _selectFirstOnly:Boolean = false;


		/**
		 * @private
		 */
		public function BreezeQueryRunner(db:IBreezeDatabase)
		{
			if(db == null)
			{
				throw new ArgumentError("Parameter db cannot be null.");
			}

			_db = db;
			_queryParams = null;
			_queryType = QUERY_RAW;
			_multiQueryMethod = MULTI_QUERY_TRANSACTION;
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

			// Check if there are multiple statements
			var queries:Array = _queryString.split(";");

			// Remove empty queries
			for(var i:int = 0; i < queries.length; )
			{
				var queryString:String = queries[i];
				if(!(/\S/.test(queryString)))
				{
					queries.removeAt(i);
					continue;
				}
				++i;
			}

			_queryString = queries.join(";");
			_queryString += ";";

			// Run multi query if there are multiple statements
			var query:BreezeRawQuery = new BreezeRawQuery(_db);
			if(queries.length > 1)
			{
				switch(_multiQueryMethod)
				{
					case MULTI_QUERY_RAW:
						_queryReference = query.multiQuery(queries, _queryParams, callback);
						break;
					case MULTI_QUERY_FAIL_ON_ERROR:
						_queryReference = query.multiQueryFailOnError(queries, _queryParams, callback);
						break;
					case MULTI_QUERY_TRANSACTION:
						_queryReference = query.multiQueryTransaction(queries, _queryParams, callback);
						break;
				}
				return _queryReference;
			}

			switch(_queryType)
			{
				case QUERY_RAW:
					_queryReference = query.query(_queryString, _queryParams, callback);
					break;
				case QUERY_SELECT:
					query.selectFirstOnly = _selectFirstOnly;
					_queryReference = query.select(_queryString, _queryParams, callback);
					break;
				case QUERY_DELETE:
					_queryReference = query.remove(_queryString, _queryParams, callback);
					break;
				case QUERY_INSERT:
					_queryReference = query.insert(_queryString, _queryParams, callback);
					break;
				case QUERY_UPDATE:
					_queryReference = query.update(_queryString, _queryParams, callback);
					break;
			}
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
