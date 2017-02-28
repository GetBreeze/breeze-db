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
	import breezedb.collections.Collection;

	import flash.globalization.DateTimeFormatter;

	/**
	 * Class providing API to run queries on associated database and table.
	 */
	public class BreezeQueryBuilder extends BreezeQueryRunner
	{
		private static var sDateFormatter:DateTimeFormatter = null;

		private var _tableName:String;

		private var _update:String = null;
		private var _join:Vector.<BreezeJoinStatement>;
		private var _select:Array = [];
		private var _insert:Array = [];
		private var _insertColumns:String = null;
		private var _where:Vector.<BreezeInnerQueryBuilder>;
		private var _orderBy:Array = [];
		private var _groupBy:Array = [];
		private var _having:Array = [[]];
		private var _distinct:Boolean = false;
		private var _offset:int = -1;
		private var _limit:int = -1;
		private var _chunkLimit:uint;
		private var _chunkQueryReference:BreezeQueryReference;
		private var _aggregate:String = null;

		private var _parametersIndex:uint = 0;
		
		public function BreezeQueryBuilder(db:IBreezeDatabase, tableName:String)
		{
			super(db);
			_tableName = tableName;
			_queryType = QUERY_SELECT;
			_queryParams = {};
			_join = new <BreezeJoinStatement>[];
			_where = new <BreezeInnerQueryBuilder>[];
			_where[0] = new BreezeInnerQueryBuilder(_queryParams, _parametersIndex);
		}


		public function first(callback:* = null):BreezeQueryRunner
		{
			limit(1);

			_callbackProxy = onFirstCompleted;

			executeIfNeeded(callback);

			return this;
		}
		
		
		public function count(callback:* = null):BreezeQueryRunner
		{
			_aggregate = "total";
			_callbackProxy = onAggregateCompleted;

			select("COUNT(*) as total");
			executeIfNeeded(callback);

			return this;
		}


		public function max(column:String, callback:* = null):BreezeQueryRunner
		{
			validateColumnName(column);

			_aggregate = "max";
			_callbackProxy = onAggregateCompleted;

			select("MAX(" + column + ") as max");
			executeIfNeeded(callback);

			return this;
		}


		public function min(column:String, callback:* = null):BreezeQueryRunner
		{
			validateColumnName(column);

			_aggregate = "min";
			_callbackProxy = onAggregateCompleted;

			select("MIN(" + column + ") as min");
			executeIfNeeded(callback);

			return this;
		}


		public function sum(column:String, callback:* = null):BreezeQueryRunner
		{
			validateColumnName(column);

			_aggregate = "sum";
			_callbackProxy = onAggregateCompleted;

			select("SUM(" + column + ") as sum");
			executeIfNeeded(callback);

			return this;
		}


		public function avg(column:String, callback:* = null):BreezeQueryRunner
		{
			validateColumnName(column);

			_aggregate = "avg";
			_callbackProxy = onAggregateCompleted;

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
			_chunkLimit = limit;
			_callbackProxy = onChunkCompleted;

			_offset = (_offset == -1) ? 0 : (_offset + limit);
			_limit = limit;

			executeIfNeeded(callback);

			return this;
		}


		public function where(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.parametersIndex = _parametersIndex;
			builder.where(param1, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		public function orWhere(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			if(builder.queryExists)
			{
				builder = new BreezeInnerQueryBuilder(_queryParams, _parametersIndex);
				_where[_where.length] = builder;
			}
			builder.where(param1, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		public function whereBetween(column:String, greaterThan:Number, lessThan:Number):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " BETWEEN " + inputToParameter(greaterThan) + " AND " + inputToParameter(lessThan));

			return this;
		}


		public function whereNotBetween(column:String, greaterThan:Number, lessThan:Number):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " NOT BETWEEN " + inputToParameter(greaterThan) + " AND " + inputToParameter(lessThan));

			return this;
		}


		public function whereNull(column:String):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " IS NULL");

			return this;
		}


		public function whereNotNull(column:String):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " IS NOT NULL");

			return this;
		}


		public function whereIn(column:String, values:Array):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " IN (" + arrayToParameters(values).join(",") + ")");

			return this;
		}


		public function whereNotIn(column:String, values:Array):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " NOT IN (" + arrayToParameters(values).join(",") + ")");

			return this;
		}


		public function whereDay(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereDay(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		public function whereMonth(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereMonth(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		public function whereYear(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereYear(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		public function whereDate(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereDate(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		public function whereColumn(param1:*, param2:String = null, param3:String = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereColumn(param1, param2, param3);

			return this;
		}


		public function orderBy(...args):BreezeQueryBuilder
		{
			if(args.length % 2 != 0)
			{
				throw new ArgumentError("Invalid orderBy parameters.");
			}

			var length:uint = args.length;
			for(var i:int = 0; i < length; i+=2)
			{
				_orderBy[_orderBy.length] = args[i] + " " + args[i + 1];
			}
			return this;
		}


		public function groupBy(...args):BreezeQueryBuilder
		{
			var length:uint = args.length;
			for(var i:int = 0; i < length; ++i)
			{
				_groupBy[_groupBy.length] = args[i];
			}
			return this;
		}


		public function having(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			// Raw having statement, e.g. having("count > 2")
			if(param1 is String && param2 === null && param3 === null)
			{
				havingRaw(param1);
			}
			// Simple equal statement, e.g. having("count", 15)
			else if(param1 is String && param3 === null)
			{
				having(param1, "=", param2);
			}
			// Simple statement with operator, e.g. having("count", "!=", 15)
			else if(param1 is String && param2 is String && param3 !== null)
			{
				havingRaw(param1 + " " + param2 + " " + inputToParameter(param3));
			}
			// Array of statements, e.g. having([["count", 15], ["team", "!=", "Alpha"])
			else if(param1 is Array && param2 === null && param3 === null)
			{
				for each(var statement:* in param1)
				{
					if(!(statement is Array))
					{
						throw new Error("Having must be an Array of Arrays.");
					}

					if(statement.length == 3)
					{
						having(statement[0], statement[1], statement[2]);
					}
					else if(statement.length == 2)
					{
						having(statement[0], "=", statement[1]);
					}
					else
					{
						throw new Error("Invalid having parameters.");
					}

				}
			}
			// Invalid input
			else
			{
				throw new ArgumentError("Invalid having parameters.");
			}

			return this;
		}


		public function orHaving(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			_having[_having.length] = [];
			having(param1, param2, param3);

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

				for each(var row:Object in value)
				{
					addInsertObjects(row);
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
			if(value == null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			_queryType = QUERY_INSERT;
			_callbackProxy = onInsertGetIdCompleted;

			setInsertColumns(value);
			addInsertObjects(value);
			
			executeIfNeeded(callback);

			return this;
		}


		public function update(value:Object, callback:* = null):BreezeQueryBuilder
		{
			if(value == null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			_queryType = QUERY_UPDATE;

			_update = "";
			addUpdateValues(value);

			executeIfNeeded(callback);

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
			incrementOrDecrement(column, param1, param2, callback, "+");

			return this;
		}


		public function decrement(column:String, param1:* = null, param2:* = null, callback:* = null):BreezeQueryBuilder
		{
			incrementOrDecrement(column, param1, param2, callback, "-");

			return this;
		}


		public function fetch(callback:* = null):BreezeQueryRunner
		{
			executeIfNeeded(callback);
			return this;
		}
		
		
		public function join(tableName:String, predicate:String):BreezeQueryBuilder
		{
			validateJoinParams(tableName, predicate);

			_join[_join.length] = new BreezeJoinStatement(BreezeJoinStatement.INNER_JOIN, tableName, predicate);

			return this;
		}


		public function leftJoin(tableName:String, predicate:String):BreezeQueryBuilder
		{
			validateJoinParams(tableName, predicate);

			_join[_join.length] = new BreezeJoinStatement(BreezeJoinStatement.LEFT_OUTER_JOIN, tableName, predicate);

			return this;
		}


		public function crossJoin(tableName:String):BreezeQueryBuilder
		{
			validateJoinParams(tableName, null, false);

			_join[_join.length] = new BreezeJoinStatement(BreezeJoinStatement.CROSS_JOIN, tableName);

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

				// JOIN
				if(_join.length > 0)
				{
					for each(var joinStatement:BreezeJoinStatement in _join)
					{
						addQueryPart(parts, joinStatement.type);
						addQueryPart(parts, joinStatement.tableName);
						if(joinStatement.type != BreezeJoinStatement.CROSS_JOIN)
						{
							addQueryPart(parts, "ON " + joinStatement.predicate);
						}
					}
				}
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
				// Multiple inserts must be split into single query each
				var tmpInsert:Array = [];
				for each(var insert:String in _insert)
				{
					tmpInsert[tmpInsert.length] = "INSERT INTO " + _tableName + " " + _insertColumns + " VALUES " + insert;
				}
				addQueryPart(parts, tmpInsert.join(";"));
			}
			// UPDATE
			else if(_queryType == QUERY_UPDATE)
			{
				addQueryPart(parts, "UPDATE " + _tableName + " SET " + _update);
			}

			// WHERE
			if(_where.length > 0 && _where[0].queryExists)
			{
				addQueryPart(parts, "WHERE");

				var tmpOrWhere:Array = [];
				for each(var builder:BreezeInnerQueryBuilder in _where)
				{
					tmpOrWhere[tmpOrWhere.length] = builder.queryString;
				}

				addQueryPart(parts, tmpOrWhere.join(" OR "));
			}

			// GROUP BY
			if(_groupBy.length > 0)
			{
				addQueryPart(parts, "GROUP BY");
				addQueryPart(parts, _groupBy.join(", "));
			}

			// HAVING
			if(_having.length > 0 && _having[0].length > 0)
			{
				addQueryPart(parts, "HAVING");

				var tmpOrHaving:Array = [];
				for each(var havingArray:Array in _having)
				{
					tmpOrHaving[tmpOrHaving.length] = "(" + havingArray.join(" AND ") + ")";
				}

				addQueryPart(parts, tmpOrHaving.join(" OR "));
			}

			// ORDER BY
			if(_orderBy.length > 0)
			{
				addQueryPart(parts, "ORDER BY");
				addQueryPart(parts, _orderBy.join(", "));
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
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereRaw(query);

			return this;
		}


		private function havingRaw(query:String):BreezeQueryBuilder
		{
			var lastHaving:Array = _having[_having.length - 1];
			lastHaving[lastHaving.length] = query;

			return this;
		}
		
		
		private function addInsertObjects(row:Object):void
		{
			var values:String = "(";
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

			values += ")";

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


		private function addUpdateValues(value:Object, separateFirst:Boolean = false):void
		{
			var i:int = 0;
			for(var key:String in value)
			{
				if(i++ > 0 || separateFirst)
				{
					_update += ", ";
				}
				_update += key + " = " + inputToParameter(value[key]);
			}
		}


		/**
		 * Internal implementation for <code>increment</code> and <code>decrement</code> methods.
		 */
		private function incrementOrDecrement(column:String, param1:*, param2:*, callback:*, operator:String):void
		{
			validateColumnName(column);

			_queryType = QUERY_UPDATE;

			if(callback === null)
			{
				if(param1 is Function || param1 === BreezeDb.DELAY)
				{
					callback = param1;
				}
				else if(param2 is Function || param2 === BreezeDb.DELAY)
				{
					callback = param2;
				}
			}

			// Increment amount
			var amount:Number = 1;
			if(param1 is Number)
			{
				amount = param1;
			}

			_update = column + " = " + column + " " + operator + " " + amount;

			if(!(param1 is Number) && param1 !== null && param1 !== callback)
			{
				addUpdateValues(param1, true);
			}

			if(!(param2 is Number) && param2 !== null && param2 !== callback)
			{
				addUpdateValues(param2, true);
			}

			executeIfNeeded(callback);
		}


		private function validateColumnName(columnName:String):void
		{
			if(columnName == null)
			{
				throw new ArgumentError("Column name cannot be null.");
			}

			if(columnName.indexOf(";") >= 0 || !(/\S/.test(columnName)))
			{
				throw new ArgumentError("Invalid column name: " + columnName);
			}
		}


		private function validateJoinParams(tableName:String, predicate:String, validatePredicate:Boolean = true):void
		{
			if(tableName == null)
			{
				throw new ArgumentError("Parameter tableName cannot be null.");
			}

			if(tableName.indexOf(";") >= 0 || !(/\S/.test(tableName)))
			{
				throw new ArgumentError("Invalid table name: " + tableName);
			}

			if(validatePredicate)
			{
				if(predicate == null)
				{
					throw new ArgumentError("Parameter predicate cannot be null.");
				}

				if(predicate.indexOf(";") >= 0 || !(/\S/.test(predicate)))
				{
					throw new ArgumentError("Invalid JOIN predicate: " + predicate);
				}
			}
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


		/**
		 *
		 * Proxy callbacks
		 *
		 * Callbacks used to further process a query response to provide more
		 * appropriate response format, e.g. 'first()' returns single item directly
		 * instead of one item Collection.
		 *
		 */


		private function onChunkCompleted(error:Error, results:Collection):void
		{
			// Track subsequent chunk queries so that the callback is not called when there are no more results
			var initialChunk:Boolean = false;

			// Save the reference to the initial chunk query so we can see whether it was cancelled or not
			if(_chunkQueryReference == null)
			{
				initialChunk = true;
				_chunkQueryReference = _queryReference;
			}

			var numResults:uint = results.length;
			var terminate:Boolean = numResults == 0 || _originalCallback === null;

			// Trigger the original callback if we need to
			// If there are no results, the callback will be triggered only for the initial chunk call
			if(!_chunkQueryReference.isCancelled && (numResults > 0 || initialChunk))
			{
				// Check if the original callback tells us to stop making further chunk queries
				var canTerminate:Boolean = finishProxiedQuery([error, results]) === false;
				terminate = terminate || canTerminate;
			}

			if(terminate || _chunkQueryReference.isCancelled)
			{
				_chunkQueryReference = null;
				return;
			}

			_queryReference = null;
			chunk(_chunkLimit, _originalCallback);
		}


		private function onFirstCompleted(error:Error, results:Collection):void
		{
			var firstItem:Object = (results.length > 0) ? results[0] : null;
			finishProxiedQuery([error, firstItem]);
		}


		private function onAggregateCompleted(error:Error, results:Collection):void
		{
			var row:Object = (results.length > 0) ? results[0] : null;
			var aggregateValue:Number = (row !== null && _aggregate in row) ? row[_aggregate] : 0;
			finishProxiedQuery([error, aggregateValue]);
		}


		private function onInsertGetIdCompleted(error:Error, result:BreezeSQLResult):void
		{
			finishProxiedQuery([error, result.lastInsertRowID]);
		}
	}
	
}
