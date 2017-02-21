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
	import breezedb.BreezeDb;
	import breezedb.IBreezeDatabase;

	import flash.globalization.DateTimeFormatter;

	/**
	 * Class providing API to run queries on associated database and table.
	 */
	public class BreezeQueryBuilder extends BreezeQueryRunner
	{
		private static var sDateFormatter:DateTimeFormatter = null;

		private var _tableName:String;

		private var _select:Array = [];
		private var _insert:Array = [];
		private var _insertColumns:String = null;
		private var _where:Array = [[]];
		private var _distinct:Boolean = false;
		private var _offset:int = -1;
		private var _limit:int = -1;

		private var _parametersIndex:int = 0;
		
		public function BreezeQueryBuilder(db:IBreezeDatabase, tableName:String)
		{
			super(db);
			_tableName = tableName;
			_queryType = QUERY_SELECT;
		}


		public function first(callback:* = null):BreezeQueryRunner
		{
			_selectFirstOnly = true;

			limit(1);

			executeIfNeeded(callback);

			return this;
		}
		
		
		public function count(callback:* = null):BreezeQueryRunner
		{
			_aggregate = "total";

			select("COUNT(*) as total");
			executeIfNeeded(callback);

			return this;
		}


		public function max(column:String, callback:* = null):BreezeQueryRunner
		{
			if(column == null)
			{
				throw new ArgumentError("Parameter column cannot be null.");
			}

			if(column.indexOf(";") >= 0)
			{
				throw new ArgumentError("Invalid column name.");
			}

			_aggregate = "max";

			select("MAX(" + column + ") as max");
			executeIfNeeded(callback);

			return this;
		}


		public function min(column:String, callback:* = null):BreezeQueryRunner
		{
			if(column == null)
			{
				throw new ArgumentError("Parameter column cannot be null.");
			}

			if(column.indexOf(";") >= 0)
			{
				throw new ArgumentError("Invalid column name.");
			}

			_aggregate = "min";

			select("MIN(" + column + ") as min");
			executeIfNeeded(callback);

			return this;
		}


		public function sum(column:String, callback:* = null):BreezeQueryRunner
		{
			if(column == null)
			{
				throw new ArgumentError("Parameter column cannot be null.");
			}

			if(column.indexOf(";") >= 0)
			{
				throw new ArgumentError("Invalid column name.");
			}

			_aggregate = "sum";

			select("SUM(" + column + ") as sum");
			executeIfNeeded(callback);

			return this;
		}


		public function avg(column:String, callback:* = null):BreezeQueryRunner
		{
			if(column == null)
			{
				throw new ArgumentError("Parameter column cannot be null.");
			}

			if(column.indexOf(";") >= 0)
			{
				throw new ArgumentError("Invalid column name.");
			}

			_aggregate = "avg";

			select("AVG(" + column + ") as avg");
			executeIfNeeded(callback);

			return this;
		}
		
		
		public function select(...args):BreezeQueryBuilder
		{
			for(var i:int = 0; i < args.length; i++)
			{
				_select[_select.length] = args[i];
			}

			return this;
		}


		public function distinct(column:String):BreezeQueryBuilder
		{
			_distinct = true;

			select(column);

			return this;
		}
		
		
		public function chunk(limit:uint, callback:* = null):BreezeQueryRunner
		{
			return this;
		}


		public function where(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			// Raw where statement, e.g. where("id > 2")
			if(param1 is String && param2 === null && param3 === null)
			{
				whereRaw(param1);
			}
			// Simple equal statement, e.g. where("id", 15)
			else if(param1 is String && param3 === null)
			{
				where(param1, "=", param2);
			}
			// Simple statement with operator, e.g. where("id", "!=", 15)
			else if(param1 is String && param2 is String && param3 !== null)
			{
				whereRaw(param1 + " " + param2 + " " + inputToParameter(param3));
			}
			// Array of statements, e.g. where([["id", 15], ["name", "!=", "Kevin"])
			else if(param1 is Array && param2 === null && param3 === null)
			{
				for each(var statement:* in param1)
				{
					if(!(statement is Array))
					{
						throw new Error("Where must be an Array of Arrays.");
					}

					if(statement.length == 3)
					{
						where(statement[0], statement[1], statement[2]);
					}
					else if(statement.length == 2)
					{
						where(statement[0], "=", statement[1]);
					}
					else
					{
						throw new Error("Invalid where parameters.");
					}

				}
			}
			// Invalid input
			else
			{
				throw new ArgumentError("Invalid where parameters.");
			}

			return this;
		}


		public function orWhere(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			_where[_where.length] = [];
			where(param1, param2, param3);

			return this;
		}


		public function whereBetween(column:String, greaterThan:Number, lessThan:Number):BreezeQueryBuilder
		{
			whereRaw(column + " BETWEEN " + inputToParameter(greaterThan) + " AND " + inputToParameter(lessThan));

			return this;
		}


		public function whereNotBetween(column:String, greaterThan:Number, lessThan:Number):BreezeQueryBuilder
		{
			whereRaw(column + " NOT BETWEEN " + inputToParameter(greaterThan) + " AND " + inputToParameter(lessThan));

			return this;
		}


		public function whereNull(column:String):BreezeQueryBuilder
		{
			whereRaw(column + " IS NULL");

			return this;
		}


		public function whereNotNull(column:String):BreezeQueryBuilder
		{
			whereRaw(column + " IS NOT NULL");

			return this;
		}


		public function whereIn(column:String, values:Array):BreezeQueryBuilder
		{
			whereRaw(column + " IN (" + arrayToParameters(values).join(",") + ")");

			return this;
		}


		public function whereNotIn(column:String, values:Array):BreezeQueryBuilder
		{
			whereRaw(column + " NOT IN (" + arrayToParameters(values).join(",") + ")");

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


		public function orderBy(...args):BreezeQueryBuilder
		{
			return this;
		}


		public function groupBy(...args):BreezeQueryBuilder
		{
			return this;
		}


		public function having(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			return this;
		}


		public function limit(value:int):BreezeQueryBuilder
		{
			_limit = value;
			return this;
		}


		public function offset(value:int):BreezeQueryBuilder
		{
			_offset = value;
			return this;
		}


		public function insert(value:*, callback:* = null):BreezeQueryBuilder
		{
			if(value == null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			_queryType = QUERY_INSERT;

			if(!(value is Array))
			{
				value = [value];
			}

			if(value is Array && value.length > 0)
			{
				if(_insertColumns == null)
				{
					setInsertColumns(value[0]);
				}

				var multiRowInsert:Boolean = value.length > 1;
				for each(var row:Object in value)
				{
					addInsertObjects(row, multiRowInsert);
				}
			}
			else
			{
				throw new ArgumentError("Insert value must be a key-value object or Array of key-value objects.");
			}

			executeIfNeeded(callback);

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
			_queryType = QUERY_DELETE;

			executeIfNeeded(callback);

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
			executeIfNeeded(callback);
			return this;
		}


		/**
		 * @inheritDoc
		 */
		override public function get queryString():String
		{
			_queryString = "";

			var parts:Vector.<String> = new <String>[];

			// SELECT
			if(_queryType == QUERY_SELECT)
			{
				addQueryPart(parts, "SELECT");

				// DISTINCT
				if(_distinct)
				{
					addQueryPart(parts, "DISTINCT");
				}

				if (_select.length == 0 || _select[0] == "*")
				{
					addQueryPart(parts, "*");
				}
				else
				{
					addQueryPart(parts, _select.join(", "));
				}

				// FROM
				addFromPart(parts);
			}
			// DELETE
			else if(_queryType == QUERY_DELETE)
			{
				addQueryPart(parts, "DELETE");

				// FROM
				addFromPart(parts);
			}
			// INSERT
			else if(_queryType == QUERY_INSERT)
			{
				addQueryPart(parts, "INSERT INTO " + _tableName);
				addQueryPart(parts, _insertColumns);

				if(_insert.length == 1)
				{
					addQueryPart(parts, "VALUES");
					addQueryPart(parts, _insert.join(", "));
				}
				// Multi-row INSERT is not supported in the SQLite version shipped with AIR
				else
				{
					addQueryPart(parts, "SELECT");
					addQueryPart(parts, _insert.join(" UNION ALL SELECT "));
				}
			}

			// WHERE
			if(_where.length > 0 && _where[0].length > 0)
			{
				addQueryPart(parts, "WHERE");

				var tmpOrWhere:Array = [];
				for each(var whereArray:Array in _where)
				{
					tmpOrWhere[tmpOrWhere.length] = "(" + whereArray.join(" AND ") + ")";
				}

				addQueryPart(parts, tmpOrWhere.join(" OR "))
			}

			// LIMIT
			if(_limit != -1)
			{
				addQueryPart(parts, "LIMIT " + _limit);
			}

			// OFFSET
			if(_offset != -1)
			{
				addQueryPart(parts, "OFFSET " + _offset);
			}

			_queryString = parts.join(" ");

			return super.queryString;
		}


		/**
		 *
		 *
		 * Private API
		 *
		 *
		 */


		private function whereRaw(query:String):BreezeQueryBuilder
		{
			var lastWhere:Array = _where[_where.length - 1];
			lastWhere[lastWhere.length] = query;

			return this;
		}
		
		
		private function addInsertObjects(row:Object, multiRowInsert:Boolean):void
		{
			var values:String = multiRowInsert ? "" : "(";
			var i:int = 0;
			for each(var value:Object in row)
			{
				if(i++ > 0)
				{
					values += ", ";
				}
				values += inputToParameter(value);
			}

			if(i == 0)
			{
				throw new ArgumentError("Cannot insert row with no columns specified.");
			}

			if(!multiRowInsert)
			{
				values += ")";
			}

			_insert[_insert.length] = values;
		}


		private function setInsertColumns(value:Object):void
		{
			_insertColumns = "(";
			var i:int = 0;
			for(var key:String in value)
			{
				if(i++ > 0)
				{
					_insertColumns += ", ";
				}
				_insertColumns += key;
			}
			_insertColumns += ")";
		}
		
		
		private function inputToParameter(value:*):String
		{
			var name:String = ":param_" + _parametersIndex++;
			if(value is Date)
			{
				value = getStringFromDate(value as Date);
			}
			if(_queryParams == null)
			{
				_queryParams = {};
			}
			_queryParams[name] = value;
			return name;
		}


		private function arrayToParameters(values:Array):Array
		{
			var result:Array = [];
			for each(var value:* in values)
			{
				result[result.length] = inputToParameter(value);
			}

			return result;
		}


		private function executeIfNeeded(callback:*):void
		{
			_queryString = queryString;

			if(callback !== BreezeDb.DELAY)
			{
				if(!(callback is Function))
				{
					throw new ArgumentError("Parameter callback must be a Function or BreezeDb.DELAY constant.");
				}

				exec(callback);
			}
		}


		private function addQueryPart(parts:Vector.<String>, part:String):void
		{
			parts[parts.length] = part;
		}


		private function addFromPart(parts:Vector.<String>):void
		{
			parts[parts.length] = "FROM " + _tableName;
		}


		private function getStringFromDate(date:Date):String
		{
			return dateFormatter.format(date);
		}


		private static function get dateFormatter():DateTimeFormatter
		{
			if(sDateFormatter == null)
			{
				sDateFormatter = new DateTimeFormatter("en-US");
				sDateFormatter.setDateTimePattern("yyyy-MM-dd HH:mm:ss");
			}
			return sDateFormatter;
		}
	}
	
}
