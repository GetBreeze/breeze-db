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
	import breezedb.events.BreezeQueryEvent;
	import breezedb.utils.Callback;
	import breezedb.utils.GarbagePrevention;

	import flash.data.SQLColumnSchema;

	import flash.data.SQLSchemaResult;

	import flash.data.SQLStatement;
	import flash.data.SQLTableSchema;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;

	/**
	 * @private
	 */
	public class BreezeRawQuery extends EventDispatcher implements IRawQuery
	{
		private static const RAW:int = 0;
		private static const SELECT:int = 1;
		private static const INSERT:int = 2;
		private static const UPDATE:int = 3;
		private static const DELETE:int = 4;

		private var _queryType:int;
		private var _isCancelled:Boolean;
		private var _isCompleted:Boolean;

		// The table / column we are looking for when querying schema
		private var _tableName:String;
		private var _columnName:String;

		private var _db:IBreezeDatabase;
		private var _callback:Function;

		public function BreezeRawQuery(db:IBreezeDatabase)
		{
			_db = db;
			_queryType = RAW;
		}


		/**
		 *
		 *
		 * Public API
		 *
		 *
		 */


		/**
		 * @inheritDoc
		 */
		public function query(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			if(!_db.isSetup)
			{
				throw new IllegalOperationError("Database must be set up before making a query.");
			}

			if(rawQuery == null)
			{
				throw new ArgumentError("Parameter rawQuery cannot be null.");
			}

			if(params is Function)
			{
				callback = params as Function;
			}

			_callback = callback;

			GarbagePrevention.instance.add(this);

			var statement:BreezeSQLStatement = new BreezeSQLStatement(onRawQueryCompleted);
			statement.sqlConnection = _db.connection;
			statement.text = rawQuery;
			if(params !== null)
			{
				for(var key:String in params)
				{
					var paramKey:String = ((key.charAt(0) == ":") ? "" : ":") + key;
					statement.parameters[paramKey] = params[key];
				}
			}
			statement.execute();
			return new BreezeQueryReference(this);
		}


		/**
		 * @inheritDoc
		 */
		public function select(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			_queryType = SELECT;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function insert(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			_queryType = INSERT;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function update(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			_queryType = UPDATE;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function remove(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			_queryType = DELETE;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQuery(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return runMultiQueries(rawQueries, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQueryFailOnError(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return runMultiQueries(rawQueries, params, callback, true);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQueryTransaction(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return runMultiQueries(rawQueries, params, callback, true, true);
		}


		/**
		 *
		 *
		 * Private / Internal API
		 *
		 *
		 */


		private function runMultiQueries(rawQueries:Array, params:*, callback:Function, failOnError:Boolean = false, transaction:Boolean = false):BreezeQueryReference
		{
			if(!_db.isSetup)
			{
				throw new IllegalOperationError("Database must be set up before making a query.");
			}

			if(rawQueries == null)
			{
				throw new ArgumentError("Parameter rawQueries cannot be null.");
			}

			if(params is Function)
			{
				callback = params as Function;
				params = null;
			}

			_callback = callback;

			var database:IBreezeDatabase = null;
			var statement:BreezeSQLMultiStatement = new BreezeSQLMultiStatement();
			var length:int = rawQueries.length;
			for(var i:int = 0; i < length; ++i)
			{
				var rawQuery:* = null;
				var parameters:Object = params;
				var queryDatabase:IBreezeDatabase;
				var queryObject:Object = rawQueries[i];
				if(queryObject is String)
				{
					rawQuery = queryObject;
					queryDatabase = _db;

					// Set raw query parameters
					if(params is Array)
					{
						parameters = null;
						if(i < params.length)
						{
							parameters = params[i];
						}
					}
				}
				else if(queryObject is BreezeQueryRunner)
				{
					rawQuery = queryObject;
					queryDatabase = BreezeQueryRunner(queryObject).database;
					// Query runner already has its parameters set
				}

				// Invalid parameter
				if(rawQuery == null)
				{
					throw new ArgumentError("Each query must be a String or BreezeQueryRunner.");
				}

				// Check if all queries use the same database connection
				if(database == null)
				{
					database = queryDatabase;
				}
				else if(database != queryDatabase)
				{
					throw new IllegalOperationError("All queries must use the same database connection.")
				}

				statement.addQuery(rawQuery, parameters, transaction);
			}

			GarbagePrevention.instance.add(this);
			statement.setDatabase(database);
			statement.addEventListener(BreezeQueryEvent.SUCCESS, onSubQueryExecutionCompleted, false, 0, true);
			statement.addEventListener(BreezeQueryEvent.ERROR, onSubQueryExecutionCompleted, false, 0, true);
			statement.execute(failOnError, transaction, onRawMultiQueryCompleted);
			return new BreezeQueryReference(this);
		}


		private function onRawMultiQueryCompleted(callbackParams:Array):void
		{
			finishQuery(callbackParams);
		}


		private function onRawQueryCompleted(error:Error, statement:SQLStatement):void
		{
			var result:BreezeSQLResult = new BreezeSQLResult(statement.getResult());

			var params:Array = [error];
			
			// Dispatch event
			var eventType:String = (error == null) ? BreezeQueryEvent.SUCCESS : BreezeQueryEvent.ERROR;
			dispatchQueryEvent(eventType, error, result, statement.text);

			// Format second callback parameter based on query type
			if(_queryType == SELECT)
			{
				// Return entire Collection
				params[1] = result.data;
			}
			else if(_queryType == UPDATE || _queryType == DELETE)
			{
				// Return rows affected
				params[1] = result.rowsAffected;
			}
			else
			{
				// Return generic result
				params[1] = result;
			}

			finishQuery(params);
		}


		private function finishQuery(callbackParams:Array):void
		{
			GarbagePrevention.instance.remove(this);

			var callback:Function = _callback;
			_callback = null;
			if(!_isCancelled)
			{
				_isCompleted = true;

				Callback.call(callback, callbackParams);
			}
		}


		private function onSubQueryExecutionCompleted(event:BreezeQueryEvent):void
		{
			// Re-dispatch
			if(hasEventListener(event.type))
			{
				dispatchEvent(event);
			}
		}


		private function dispatchQueryEvent(eventType:String, error:Error, result:BreezeSQLResult, rawQuery:String):void
		{
			if(hasEventListener(eventType))
			{
				dispatchEvent(new BreezeQueryEvent(eventType, error, result, rawQuery));
			}
		}
		
		
		/**
		 * @private
		 */
		breezedb_internal function loadTableSchema(tableName:String, callback:Function):BreezeQueryReference
		{
			if(!_db.isSetup)
			{
				Callback.call(callback, [new Error("Database connection is not active."), false]);
				return null;
			}

			GarbagePrevention.instance.add(this);

			_tableName = tableName;

			_callback = callback;
			_db.connection.addEventListener(SQLEvent.SCHEMA, onTableSchemaLoadSuccess);
			_db.connection.addEventListener(SQLErrorEvent.ERROR, onTableSchemaLoadError);
			_db.connection.loadSchema(SQLTableSchema, tableName, "main", false);
			return new BreezeQueryReference(this);
		}


		/**
		 * @private
		 */
		breezedb_internal function loadColumnSchema(tableName:String, columnName:String, callback:Function):BreezeQueryReference
		{
			if(!_db.isSetup)
			{
				Callback.call(callback, [new Error("Database connection is not active."), false]);
				return null;
			}

			GarbagePrevention.instance.add(this);

			_columnName = columnName;
			_callback = callback;
			_db.connection.addEventListener(SQLEvent.SCHEMA, onColumnSchemaLoadSuccess);
			_db.connection.addEventListener(SQLErrorEvent.ERROR, onColumnSchemaLoadError);
			_db.connection.loadSchema(SQLTableSchema, tableName, "main", true);
			return new BreezeQueryReference(this);
		}


		/**
		 * @private
		 */
		internal function cancel():void
		{
			_isCancelled = true;
			_callback = null;
		}


		private function onTableSchemaLoadSuccess(event:SQLEvent):void
		{
			_db.connection.removeEventListener(SQLEvent.SCHEMA, onTableSchemaLoadSuccess);
			_db.connection.removeEventListener(SQLErrorEvent.ERROR, onTableSchemaLoadError);

			var schema:SQLSchemaResult = _db.connection.getSchemaResult();
			dispatchQueryEvent(BreezeQueryEvent.SUCCESS, null, null, "Has table [" + _tableName + "] = " + (schema.tables.length > 0));
			finishQuery([null, schema.tables.length > 0]);
		}


		private function onTableSchemaLoadError(event:SQLErrorEvent):void
		{
			_db.connection.removeEventListener(SQLEvent.SCHEMA, onTableSchemaLoadSuccess);
			_db.connection.removeEventListener(SQLErrorEvent.ERROR, onTableSchemaLoadError);

			dispatchQueryEvent(BreezeQueryEvent.SUCCESS, null, null, "Has table [" + _tableName + "] = false");
			finishQuery([event.error, false]);
		}


		private function onColumnSchemaLoadSuccess(event:SQLEvent):void
		{
			_db.connection.removeEventListener(SQLEvent.SCHEMA, onColumnSchemaLoadSuccess);
			_db.connection.removeEventListener(SQLErrorEvent.ERROR, onColumnSchemaLoadError);

			var hasColumn:Boolean = false;
			var schema:SQLSchemaResult = _db.connection.getSchemaResult();
			for each (var table:SQLTableSchema in schema.tables)
			{
				var columns:Array = table.columns;
				for each(var column:SQLColumnSchema in columns)
				{
					if(column.name == _columnName)
					{
						hasColumn = true;
						break;
					}
				}
			}

			dispatchQueryEvent(BreezeQueryEvent.SUCCESS, null, null, "Has column [" + _columnName + "] = " + hasColumn);
			finishQuery([null, hasColumn]);
		}


		private function onColumnSchemaLoadError(event:SQLErrorEvent):void
		{
			_db.connection.removeEventListener(SQLEvent.SCHEMA, onColumnSchemaLoadSuccess);
			_db.connection.removeEventListener(SQLErrorEvent.ERROR, onColumnSchemaLoadError);

			dispatchQueryEvent(BreezeQueryEvent.SUCCESS, null, null, "Has column [" + _columnName + "] = false");
			finishQuery([event.error, false]);
		}


		/**
		 *
		 *
		 * Getters / Setters
		 *
		 *
		 */
		

		/**
		 * @private
		 */
		internal function get isCancelled():Boolean
		{
			return _isCancelled;
		}


		/**
		 * @private
		 */
		internal function get isCompleted():Boolean
		{
			return _isCompleted;
		}
	}
	
}
