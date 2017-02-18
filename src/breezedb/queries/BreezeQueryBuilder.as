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
	 * Class providing API to run queries on associated database and table.
	 */
	public class BreezeQueryBuilder extends BreezeQueryRunner
	{
		private var _tableName:String;
		
		public function BreezeQueryBuilder(db:IBreezeDatabase, tableName:String)
		{
			super(db);
			_tableName = tableName;
		}


		public function first(callback:* = null):BreezeQueryRunner
		{
			return this;
		}
		
		
		public function count(callback:* = null):BreezeQueryRunner
		{
			return this;
		}


		public function max(column:String, callback:* = null):BreezeQueryRunner
		{
			return this;
		}


		public function min(column:String, callback:* = null):BreezeQueryRunner
		{
			return this;
		}


		public function sum(column:String, callback:* = null):BreezeQueryRunner
		{
			return this;
		}


		public function avg(column:String, callback:* = null):BreezeQueryRunner
		{
			return this;
		}
		
		
		public function select(...args):BreezeQueryBuilder
		{
			return this;
		}


		public function distinct(column:String):BreezeQueryBuilder
		{
			return this;
		}
		
		
		public function chunk(limit:uint, callback:* = null):BreezeQueryRunner
		{
			return this;
		}


		public function where(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function orWhere(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function whereBetween(name:String, value1:Number, value2:Number):BreezeQueryBuilder
		{
			return this;
		}


		public function whereNotBetween(name:String, value1:Number, value2:Number):BreezeQueryBuilder
		{
			return this;
		}


		public function whereNull(name:String):BreezeQueryBuilder
		{
			return this;
		}


		public function whereNotNull(name:String):BreezeQueryBuilder
		{
			return this;
		}


		public function whereIn(name:String, values:Array):BreezeQueryBuilder
		{
			return this;
		}


		public function whereNotIn(name:String, values:Array):BreezeQueryBuilder
		{
			return this;
		}


		public function whereDay(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function whereMonth(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function whereYear(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function whereDate(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function whereColumn(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function whereRaw(query:String):BreezeQueryBuilder
		{
			return this;
		}


		public function orderBy(...args):BreezeQueryBuilder
		{
			return this;
		}


		public function groupBy(...args):BreezeQueryBuilder
		{
			return this;
		}


		public function limit(value:int):BreezeQueryBuilder
		{
			return this;
		}


		public function offset(value:int):BreezeQueryBuilder
		{
			return this;
		}


		public function insert(value:*, callback:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function insertGetId(value:Object, callback:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function update(value:Object, callback:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function remove(callback:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function increment(column:String, param1:* = null, param2:* = null, callback:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function decrement(column:String, param1:* = null, param2:* = null, callback:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function fetch(callback:* = null):BreezeQueryRunner
		{
			return this;
		}
		
	}
	
}
