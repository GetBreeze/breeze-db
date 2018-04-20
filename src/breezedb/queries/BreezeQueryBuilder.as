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

	import flash.errors.IllegalOperationError;

	import flash.globalization.DateTimeFormatter;

	/**
	 * Class providing API to run queries on associated database and table.
	 */
	public class BreezeQueryBuilder extends BreezeQueryRunner
	{
		private static var sDateFormatter:DateTimeFormatter = null;

		private var _tableName:String;

		private var _update:String = null;
		private var _union:Vector.<BreezeUnionStatement>;
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
		private var _insertOrIgnore:Boolean = false;

		// Static makes the index unique across all query builders (useful when making UNION queries)
		private static var _parametersIndex:uint = 0;


		/**
		 * Creates a new builder instance and associates it with existing database
		 * and table within that database. It is more convenient to access new instance using
		 * <code>BreezeDb.db.table("table-name")</code> or <code>DB.table("table-name")</code> API.
		 *
		 * @param db The database to associate the builder with.
		 * @param tableName The name of the table on which the queries will be executed.
		 *
		 * @see breezedb.IBreezeDatabase#table()
		 */
		public function BreezeQueryBuilder(db:IBreezeDatabase, tableName:String)
		{
			super(db);
			_tableName = tableName;
			_queryType = QUERY_SELECT;
			_queryParams = {};
			_union = new <BreezeUnionStatement>[];
			_join = new <BreezeJoinStatement>[];
			_where = new <BreezeInnerQueryBuilder>[];
			_where[0] = new BreezeInnerQueryBuilder(_queryParams, _parametersIndex);
		}


		/**
		 * Retrieves the first record in the table.
		 *
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, first:Object):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function first(callback:* = null):BreezeQueryBuilder
		{
			limit(1);

			setCallbackProxy(onFirstCompleted);

			executeIfNeeded(callback);

			return this;
		}
		

		/**
		 * Retrieves the total number of records in the table.
		 *
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, count:int):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function count(callback:* = null):BreezeQueryBuilder
		{
			_aggregate = "total";
			setCallbackProxy(onAggregateCompleted);

			select("COUNT(*) as total");
			executeIfNeeded(callback);

			return this;
		}


		/**
		 * Retrieves the maximum value in the given column.
		 *
		 * @param column The name of the column where the maximum value should be found.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, max:Number):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function max(column:String, callback:* = null):BreezeQueryBuilder
		{
			validateColumnName(column);

			_aggregate = "max";
			setCallbackProxy(onAggregateCompleted);

			select("MAX(" + column + ") as max");
			executeIfNeeded(callback);

			return this;
		}


		/**
		 * Retrieves the minimum value in the given column.
		 *
		 * @param column The name of the column where the minimum value should be found.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, min:Number):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function min(column:String, callback:* = null):BreezeQueryBuilder
		{
			validateColumnName(column);

			_aggregate = "min";
			setCallbackProxy(onAggregateCompleted);

			select("MIN(" + column + ") as min");
			executeIfNeeded(callback);

			return this;
		}


		/**
		 * Retrieves the sum of all values in the given column.
		 *
		 * @param column The name of the column that should be summed up.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, sum:Number):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function sum(column:String, callback:* = null):BreezeQueryBuilder
		{
			validateColumnName(column);

			_aggregate = "sum";
			setCallbackProxy(onAggregateCompleted);

			select("SUM(" + column + ") as sum");
			executeIfNeeded(callback);

			return this;
		}


		/**
		 * Retrieves the average of all values in the given column.
		 *
		 * @param column The name of the column that should be averaged.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, average:Number):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function avg(column:String, callback:* = null):BreezeQueryBuilder
		{
			validateColumnName(column);

			_aggregate = "avg";
			setCallbackProxy(onAggregateCompleted);

			select("AVG(" + column + ") as avg");
			executeIfNeeded(callback);

			return this;
		}
		

		/**
		 * Specifies columns that should be returned when performing <code>SELECT</code> query.
		 *
		 * @param args One or multiple column names (<code>String</code>).
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 */
		public function select(...args):BreezeQueryBuilder
		{
			for(var i:int = 0; i < args.length; i++)
			{
				_select[_select.length] = args[i];
			}

			return this;
		}


		/**
		 * Creates a <code>SELECT DISTINCT</code> query for the given column.
		 *
		 * @param column The name of the column where only distinct values should be returned.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 */
		public function distinct(column:String):BreezeQueryBuilder
		{
			_distinct = true;

			select(column);

			return this;
		}
		

		/**
		 * Retrieves limited number of records at a time, as specified using the <code>limit</code> parameter.
		 *
		 * <p>
		 * The callback may be called multiple times, until all records are processed. You may manually stop further
		 * processing by returning <code>false</code> in the <code>callback</code> method.
		 * </p>
		 *
		 * @param limit The maximum number of records to retrieve at one time.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered each time a new chunk is retrieved.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, results:Collection):&#42;
		 *    {
		 *        // If processed enough, return false
		 *        return false;
		 *    }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function chunk(limit:uint, callback:* = null):BreezeQueryBuilder
		{
			_chunkLimit = limit;
			setCallbackProxy(onChunkCompleted);

			_offset = (_offset == -1) ? 0 : (_offset + limit);
			_limit = limit;

			executeIfNeeded(callback);

			return this;
		}


		/**
		 * Adds a <code>WHERE</code> clause to the query. Conditions added with this method are joined using
		 * the <code>AND</code> operator.
		 *
		 * @param param1 This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>String</code>, i.e. name of the column that will be evaluated in the condition.</li>
		 *    <li>A <code>Function</code> that accepts <code>BreezeInnerQueryBuilder</code>, allowing you
		 *    to build nested <code>WHERE</code> clauses. If such <code>Function</code> is provided, the
		 *    remaining parameters must be <code>null</code>.</li>
		 * </ul>
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #orWhere()
		 */
		public function where(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.parametersIndex = _parametersIndex;
			builder.where(param1, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		/**
		 * Adds a <code>WHERE</code> clause to the query. Conditions added with this method are joined using
		 * the <code>OR</code> operator.
		 *
		 * @param param1 This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>String</code>, i.e. name of the column that will be evaluated in the condition.</li>
		 *    <li>A <code>Function</code> that accepts <code>BreezeInnerQueryBuilder</code>, allowing you
		 *    to build nested <code>WHERE</code> clauses. If such <code>Function</code> is provided, the
		 *    remaining parameters must be <code>null</code>.</li>
		 * </ul>
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #where()
		 */
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


		/**
		 * Adds a <code>WHERE BETWEEN</code> clause to the query, selecting the records whose column
		 * value is between the two values (including).
		 *
		 * @param column The name of the column to evaluate.
		 * @param greaterThan The minimum value.
		 * @param lessThan The maximum value.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereNotBetween()
		 */
		public function whereBetween(column:String, greaterThan:Number, lessThan:Number):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " BETWEEN " + inputToParameter(greaterThan) + " AND " + inputToParameter(lessThan));

			return this;
		}


		/**
		 * Adds a <code>WHERE NOT BETWEEN</code> clause to the query, selecting the records whose column
		 * value lies outside of the two values.
		 *
		 * @param column The name of the column to evaluate.
		 * @param greaterThan The minimum value.
		 * @param lessThan The maximum value.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereBetween()
		 */
		public function whereNotBetween(column:String, greaterThan:Number, lessThan:Number):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " NOT BETWEEN " + inputToParameter(greaterThan) + " AND " + inputToParameter(lessThan));

			return this;
		}


		/**
		 * Adds a <code>WHERE IS NULL</code> clause to the query, selecting the records whose column
		 * value is <code>NULL</code>.
		 *
		 * @param column The name of the column to evaluate.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereNotNull()
		 */
		public function whereNull(column:String):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " IS NULL");

			return this;
		}


		/**
		 * Adds a <code>WHERE IS NOT NULL</code> clause to the query, selecting the records whose column
		 * value is <strong>not</strong> <code>NULL</code>.
		 *
		 * @param column The name of the column to evaluate.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereNull()
		 */
		public function whereNotNull(column:String):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " IS NOT NULL");

			return this;
		}


		/**
		 * Adds a <code>WHERE IN</code> clause to the query, selecting the records whose column
		 * value is contained within the given <code>Array</code>.
		 *
		 * @param column The name of the column to evaluate.
		 * @param values The list of values to use for evaluation.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereNotIn()
		 */
		public function whereIn(column:String, values:Array):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " IN (" + arrayToParameters(values).join(",") + ")");

			return this;
		}


		/**
		 * Adds a <code>WHERE NOT IN</code> clause to the query, selecting the records whose column
		 * value is <strong>not</strong> contained within the given <code>Array</code>.
		 *
		 * @param column The name of the column to evaluate.
		 * @param values The list of values to use for evaluation.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereIn()
		 */
		public function whereNotIn(column:String, values:Array):BreezeQueryBuilder
		{
			validateColumnName(column);

			whereRaw(column + " NOT IN (" + arrayToParameters(values).join(",") + ")");

			return this;
		}


		/**
		 * Adds a <code>WHERE</code> clause that compares a day of the month to a column value.
		 *
		 * @param dateColumn The name of the date column.
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument. It can be either an integer between 1 and 31 or <code>Date</code> object.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereMonth()
		 * @see #whereYear()
		 * @see #whereDate()
		 */
		public function whereDay(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereDay(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		/**
		 * Adds a <code>WHERE</code> clause that compares a month of the year to a column value.
		 *
		 * @param dateColumn The name of the date column.
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument. It can be either an integer between 1 and 12 or <code>Date</code> object.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereDay()
		 * @see #whereYear()
		 * @see #whereDate()
		 */
		public function whereMonth(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereMonth(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		/**
		 * Adds a <code>WHERE</code> clause that compares a column value to a specific year.
		 *
		 * @param dateColumn The name of the date column.
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument. It can be either an integer or <code>String</code> in <code>YYYY</code>
		 *               format or <code>Date</code> object.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereMonth()
		 * @see #whereDay()
		 * @see #whereDate()
		 */
		public function whereYear(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereYear(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		/**
		 * Adds a <code>WHERE</code> clause that compares a <code>DATE</code> column with
		 * date value in <code>YYYY-MM-DD</code> format.
		 *
		 * @param dateColumn The name of the date column.
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument. It can be either a <code>String</code> in <code>YYYY-MM-DD</code> format
		 *               or <code>Date</code> object.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #whereMonth()
		 * @see #whereYear()
		 * @see #whereDay()
		 */
		public function whereDate(dateColumn:String, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereDate(dateColumn, param2, param3);
			_parametersIndex = builder.parametersIndex;

			return this;
		}


		/**
		 * Adds a <code>WHERE</code> clause that compares two columns.
		 *
		 * @param param1 The name of the first column.
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the name of the second column
		 *               (typically provided as the third argument).
		 * @param param3 The name of the second column, or <code>null</code> if it is provided as the second argument.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 */
		public function whereColumn(param1:*, param2:String = null, param3:String = null):BreezeQueryBuilder
		{
			var builder:BreezeInnerQueryBuilder = _where[_where.length - 1];
			builder.whereColumn(param1, param2, param3);

			return this;
		}


		/**
		 * Adds an <code>ORDER BY</code> clause that allows you to sort the query results by one
		 * or multiple columns.
		 *
		 * @param args List of pairs consisting of the column name and sort order
		 *             (<code>ASC</code> or <code>DESC</code>):
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.orderBy("title", "ASC", "views", "DESC").fetch(...);
		 * </listing>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 */
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


		/**
		 * Adds a <code>GROUP BY</code> clause that allows you to group the results.
		 *
		 * @param args List of columns to group the results by.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #having()
		 */
		public function groupBy(...args):BreezeQueryBuilder
		{
			var length:uint = args.length;
			for(var i:int = 0; i < length; ++i)
			{
				_groupBy[_groupBy.length] = args[i];
			}
			return this;
		}


		/**
		 * Adds a <code>HAVING</code> clause that allows you to filter groups created by <code>GROUP BY</code> clause.
		 * Conditions added with this method are joined using the <code>AND</code> operator.
		 *
		 * @param param1 The name of the grouped column that will be evaluated in the condition.
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #groupBy()
		 * @see #orHaving()
		 */
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


		/**
		 * Adds a <code>HAVING</code> clause that allows you to filter groups created by <code>GROUP BY</code> clause.
		 * Conditions added with this method are joined using the <code>OR</code> operator.
		 *
		 * @param param1 The name of the grouped column that will be evaluated in the condition.
		 * @param param2 The conditional operator, e.g. <code>=</code>, <code>&gt;</code> etc. If the equal
		 *               operator is to be used, this parameter can specify the value to evaluate against the column
		 *               (typically provided as the third argument).
		 * @param param3 The value to evaluate against the column, or <code>null</code> if it is provided as the
		 *               second argument.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #groupBy()
		 * @see #having()
		 */
		public function orHaving(param1:*, param2:* = null, param3:* = null):BreezeQueryBuilder
		{
			_having[_having.length] = [];
			having(param1, param2, param3);

			return this;
		}


		/**
		 * Limits the number of query results to the given value.
		 *
		 * @param value Maximum number of results to retrieve using a <code>SELECT</code> query.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 */
		public function limit(value:int):BreezeQueryBuilder
		{
			_limit = value;
			return this;
		}


		/**
		 * Skips the given number of results.
		 *
		 * @param value Number of results to skip.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 */
		public function offset(value:int):BreezeQueryBuilder
		{
			_offset = value;
			return this;
		}


		/**
		 * Creates an <code>INSERT</code> query for one or more values.
		 *
		 * @param value Either a single value (key-value <code>Object</code>) or multiple values (<code>Array</code>
		 *              of key-value objects). The keys represent column names.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function insert(value:*, callback:* = null):BreezeQueryBuilder
		{
			if(value == null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			return insertInternal(value, callback, false);
		}


		/**
		 * Creates an <code>INSERT OR IGNORE</code> query for one or more values.
		 * Error is not returned when an attempt is made to insert a duplicate primary key
		 * or unique value, it is ignored instead.
		 *
		 * @param value Either a single value (key-value <code>Object</code>) or multiple values (<code>Array</code>
		 *              of key-value objects). The keys represent column names.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function insertOrIgnore(value:*, callback:* = null):BreezeQueryBuilder
		{
			if(value == null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			return insertInternal(value, callback, true);
		}


		/**
		 * Creates an <code>INSERT</code> query for a single value and attempts to retrieve its ID.
		 *
		 * @param value A key-value <code>Object</code>. The keys represent column names.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, newId:int):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function insertGetId(value:Object, callback:* = null):BreezeQueryBuilder
		{
			if(value == null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			_queryType = QUERY_INSERT;
			setCallbackProxy(onInsertGetIdCompleted);

			setInsertColumns(value);
			addInsertObjects(value);
			
			executeIfNeeded(callback);

			return this;
		}


		/**
		 * Creates an <code>UPDATE</code> query. Records selected by the query will be updated with values
		 * passed in using the <code>value</code> parameter. Combine this method with the available
		 * <code>where</code> methods to update specific records.
		 *
		 * @param value A key-value <code>Object</code> that holds the new values. The keys represent column names.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, affectedRows:int):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 *
		 * @see #where()
		 * @see #orWhere()
		 */
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


		/**
		 * Creates a <code>DELETE</code> query, effectively removing all selected records. Combine this method
		 * with the available <code>where</code> methods to remove specific records.
		 *
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, rowsDeleted:int):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 *
		 * @see #where()
		 * @see #orWhere()
		 */
		public function remove(callback:* = null):BreezeQueryBuilder
		{
			_queryType = QUERY_DELETE;

			executeIfNeeded(callback);

			return this;
		}


		/**
		 * A helper method for an <code>UPDATE</code> query that increments a numeric column by certain amount.
		 *
		 * @param column The name of the column to increment.
		 * @param param1 This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Number</code> that specifies the amount by which the <code>column</code>
		 *    will be incremented. If not specified, it will default to 1.
		 *    </li>
		 *    <li>If the above option is not used, the parameter can be a key-value <code>Object</code> that
		 *    specifies new column values that will be updated along the increment operation.
		 *    </li>
		 *    <li>If the above option is not used, the parameter can be a <code>Function</code> that is triggered
		 *    once the query is completed. It should have the signature as shown for the <code>callback</code> parameter.
		 *    </li>
		 *    <li>Otherwise it can be the <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed.
		 *    It can be executed later by calling the <code>exec</code> method on the returned instance
		 *    of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 * @param param2 This parameter can be one of the following:
		 * <ul>
		 *    <li>A key-value <code>Object</code> that
		 *    specifies new column values that will be updated along the increment operation.
		 *    </li>
		 *    <li>If the above option is not used, the parameter can be a <code>Function</code> that is triggered
		 *    once the query is completed. It should have the signature as shown for the <code>callback</code> parameter.
		 *    </li>
		 *    <li>Otherwise it can be the <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed.
		 *    It can be executed later by calling the <code>exec</code> method on the returned instance
		 *    of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 *
		 * @see #decrement()
		 */
		public function increment(column:String, param1:* = null, param2:* = null, callback:* = null):BreezeQueryBuilder
		{
			incrementOrDecrement(column, param1, param2, callback, "+");

			return this;
		}


		/**
		 * A helper method for an <code>UPDATE</code> query that decrements a numeric column by certain amount.
		 *
		 * @param column The name of the column to decrement.
		 * @param param1 This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Number</code> that specifies the amount by which the <code>column</code>
		 *    will be decremented. If not specified, it will default to 1.
		 *    </li>
		 *    <li>If the above option is not used, the parameter can be a key-value <code>Object</code> that
		 *    specifies new column values that will be updated along the decrement operation.
		 *    </li>
		 *    <li>If the above option is not used, the parameter can be a <code>Function</code> that is triggered
		 *    once the query is completed. It should have the signature as shown for the <code>callback</code> parameter.
		 *    </li>
		 *    <li>Otherwise it can be the <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed.
		 *    It can be executed later by calling the <code>exec</code> method on the returned instance
		 *    of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 * @param param2 This parameter can be one of the following:
		 * <ul>
		 *    <li>A key-value <code>Object</code> that
		 *    specifies new column values that will be updated along the decrement operation.
		 *    </li>
		 *    <li>If the above option is not used, the parameter can be a <code>Function</code> that is triggered
		 *    once the query is completed. It should have the signature as shown for the <code>callback</code> parameter.
		 *    </li>
		 *    <li>Otherwise it can be the <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed.
		 *    It can be executed later by calling the <code>exec</code> method on the returned instance
		 *    of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 *
		 * @see #increment()
		 */
		public function decrement(column:String, param1:* = null, param2:* = null, callback:* = null):BreezeQueryBuilder
		{
			incrementOrDecrement(column, param1, param2, callback, "-");

			return this;
		}


		/**
		 * Executes the created <code>SELECT</code> query.
		 *
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code> that is triggered once the query is completed.
		 *    It should have the following signature:
		 *    <listing version="3.0">
		 *    function callback(error:Error, results:Collection):void
		 *    { }
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the executed query
		 * 		   or execute the query at later time if it was delayed.
		 */
		public function fetch(callback:* = null):BreezeQueryBuilder
		{
			executeIfNeeded(callback);
			return this;
		}
		

		/**
		 * Adds an <code>INNER JOIN</code> clause to the query.
		 *
		 * @param tableName The name of the table to join.
		 * @param predicate The column constraints for the join.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #leftJoin()
		 * @see #crossJoin()
		 */
		public function join(tableName:String, predicate:String):BreezeQueryBuilder
		{
			validateJoinParams(tableName, predicate);

			_join[_join.length] = new BreezeJoinStatement(BreezeJoinStatement.INNER_JOIN, tableName, predicate);

			return this;
		}


		/**
		 * Adds a <code>LEFT OUTER JOIN</code> clause to the query.
		 *
		 * @param tableName The name of the table to join.
		 * @param predicate The column constraints for the join.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #join()
		 * @see #crossJoin()
		 */
		public function leftJoin(tableName:String, predicate:String):BreezeQueryBuilder
		{
			validateJoinParams(tableName, predicate);

			_join[_join.length] = new BreezeJoinStatement(BreezeJoinStatement.LEFT_OUTER_JOIN, tableName, predicate);

			return this;
		}


		/**
		 * Adds a <code>CROSS JOIN</code> clause to the query.
		 *
		 * @param tableName The name of the table to join.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #join()
		 * @see #crossJoin()
		 */
		public function crossJoin(tableName:String):BreezeQueryBuilder
		{
			validateJoinParams(tableName, null, false);

			_join[_join.length] = new BreezeJoinStatement(BreezeJoinStatement.CROSS_JOIN, tableName);

			return this;
		}
		

		/**
		 * Adds an <code>UNION</code> clause, combining the results of this and the given query. Duplicate rows
		 * are removed from the final result. <strong>Both queries must be associated with the same database.</strong>
		 *
		 * @param query The query to be added after the <code>UNION</code> clause.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #unionAll()
		 */
		public function union(query:BreezeQueryBuilder):BreezeQueryBuilder
		{
			return unionInternal(query);
		}


		/**
		 * Adds an <code>UNION ALL</code> clause, combining the results of this and the given query. Duplicate rows
		 * are kept in the final result. <strong>Both queries must be associated with the same database.</strong>
		 *
		 * @param query The query to be added after the <code>UNION ALL</code> clause.
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain a reference to the created query
		 * 		   or chain more query methods.
		 *
		 * @see #union()
		 */
		public function unionAll(query:BreezeQueryBuilder):BreezeQueryBuilder
		{
			return unionInternal(query, true);
		}


		/**
		 * @inheritDoc
		 */
		override public function exec(callback:Function = null):BreezeQueryReference
		{
			if(_queryString == null)
			{
				_queryString = queryString;
			}
			return super.exec(callback);
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
				var statement:String = "INSERT";
				if(_insertOrIgnore)
				{
					statement += " OR IGNORE";
				}
				statement += " INTO ";

				// Multiple inserts must be split into single query each
				var tmpInsert:Array = [];
				for each(var insert:String in _insert)
				{
					tmpInsert[tmpInsert.length] = statement + _tableName + " " + _insertColumns + " VALUES " + insert;
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

			// UNION
			if(_union.length > 0)
			{
				for each(var union:BreezeUnionStatement in _union)
				{
					addQueryPart(parts, "UNION");
					if(union.all)
					{
						addQueryPart(parts, "ALL");
					}
					addQueryPart(parts, union.query.queryString);

					// Add the other query parameters to this query
					var newParams:Object = union.query._queryParams;
					for(var paramKey:String in newParams)
					{
						// Cannot overwrite existing parameter
						if(paramKey in _queryParams)
						{
							throw new Error("Duplicate parameter name encountered in union query.");
						}
						_queryParams[paramKey] = newParams[paramKey];
					}
				}
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
				if(callback != null && !(callback is Function))
				{
					throw new ArgumentError("When specified, callback must be either a Function or BreezeDb.DELAY constant.");
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


		private function setCallbackProxy(callback:Function):void
		{
			if(_callbackProxy == null)
			{
				_callbackProxy = callback;
			}
		}


		/**
		 * Internal implementation for 'increment' and 'decrement' methods.
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


		/**
		 * Internal implementation for 'union' and 'unionAll' methods.
		 */
		private function unionInternal(query:BreezeQueryBuilder, unionAll:Boolean = false):BreezeQueryBuilder
		{
			if(query == null)
			{
				throw new ArgumentError("Parameter query cannot be null.");
			}

			if(query._db != _db)
			{
				throw new ArgumentError("The given query uses different database connection.");
			}

			for each(var existingUnion:BreezeUnionStatement in _union)
			{
				if(existingUnion.query == query)
				{
					throw new IllegalOperationError("The given query is already part of union.")
				}
			}

			_union[_union.length] = new BreezeUnionStatement(query, unionAll);

			return this;
		}


		/**
		 * Internal implementation for 'insert' and 'insertOrIgnore' methods.
		 */
		private function insertInternal(value:*, callback:* = null, insertOrIgnore:Boolean = false):BreezeQueryBuilder
		{
			_queryType = QUERY_INSERT;
			_insertOrIgnore = insertOrIgnore;

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


		/**
		 * @private
		 */
		protected function onChunkCompleted(error:Error, results:Collection):void
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
				_callbackProxy = null;
				return;
			}

			_queryReference = null;
			chunk(_chunkLimit, _originalCallback);
		}


		/**
		 * @private
		 */
		protected function onFirstCompleted(error:Error, results:Collection):void
		{
			_callbackProxy = null;
			var firstItem:Object = (results.length > 0) ? results[0] : null;
			finishProxiedQuery([error, firstItem]);
		}


		private function onAggregateCompleted(error:Error, results:Collection):void
		{
			_callbackProxy = null;
			var row:Object = (results.length > 0) ? results[0] : null;
			var aggregateValue:Number = (row !== null && _aggregate in row) ? row[_aggregate] : 0;
			finishProxiedQuery([error, aggregateValue]);
		}


		private function onInsertGetIdCompleted(error:Error, result:BreezeSQLResult):void
		{
			_callbackProxy = null;
			finishProxiedQuery([error, result.lastInsertRowID]);
		}
	}
	
}
