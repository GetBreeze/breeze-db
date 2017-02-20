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
	import breezedb.collections.Collection;

	import flash.data.SQLResult;

	/**
	 * Class providing access to data returned in response to the execution of a SQL statement.
	 */
	public class BreezeSQLResult
	{
		private var _data:Collection;
		private var _result:SQLResult;


		/**
		 * @private
		 */
		public function BreezeSQLResult(result:SQLResult)
		{
			_result = result;
		}


		/**
		 * Indicates whether all the resulting data from a statement execution has been returned.
		 */
		public function get complete():Boolean
		{
			return (_result != null) ? _result.complete : false;
		}


		/**
		 * Indicates how many rows were affected by the operation. Only changes that are directly specified by
		 * an <code>INSERT</code>, <code>UPDATE</code>, or <code>DELETE</code> statement are counted.
		 */
		public function get rowsAffected():Number
		{
			return (_result != null) ? _result.rowsAffected : -1;
		}


		/**
		 * The last generated row identifier generated by a SQL <code>INSERT</code> statement.
		 */
		public function get lastInsertRowID():Number
		{
			return (_result != null) ? _result.lastInsertRowID : -1;
		}


		/**
		 * The data returned as a result of the statement execution, specifically when a SQL <code>SELECT</code>
		 * statement is executed.
		 *
		 * <p>When a statement returns one or more rows this property is an array containing objects that
		 * represent the rows of result data. Each object in the array has property names that correspond
		 * to the result data set's column names.</p>
		 *
		 * <p>The returned <code>Collection</code> is never <code>null</code>.</p>
		 */
		public function get data():Collection
		{
			if(_data != null)
			{
				return _data;
			}
			
			if(_result != null && _result.data != null && _result.data.length > 0)
			{
				_data = Collection.fromArray(_result.data);
				return _data;
			}

			_data = new Collection();
			return _data;
		}
	}
	
}
