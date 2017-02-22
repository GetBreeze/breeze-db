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
	import breezedb.utils.Callback;
	import breezedb.utils.GarbagePrevention;

	import flash.data.SQLColumnSchema;

	import flash.data.SQLSchemaResult;

	import flash.data.SQLStatement;
	import flash.data.SQLTableSchema;
	import flash.errors.IllegalOperationError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;

	/**
	 * @private
	 */
	public class BreezeRawQuery implements IRawQuery
	{
		private static const RAW:int = 0;
		private static const SELECT:int = 1;
		private static const INSERT:int = 2;
		private static const UPDATE:int = 3;
		private static const DELETE:int = 4;

		private var _queryType:int;
		private var _isCancelled:Boolean;
		private var _isCompleted:Boolean;
		private var _columnName:String;

		// Only the first item in the SELECT result is returned to the callback
		private var _selectFirstOnly:Boolean;

		// Running an aggregate query, a single numeric value is returned to the callback
		private var _aggregate:String;

		// Last inserted id value is returned to the callback instead of a generic result
		private var _getLastInsertId:Boolean;

		private var _db:IBreezeDatabase;
		private var _callback:Function;

		public function BreezeRawQuery(db:IBreezeDatabase)
		{
			_db = db;
			_queryType = RAW;
			_aggregate = null;
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

			GarbagePrevention.instance.add(this);

			var statement:BreezeSQLMultiStatement = new BreezeSQLMultiStatement(_db, onRawMultiQueryCompleted);
			var length:int = rawQueries.length;
			for(var i:int = 0; i < length; ++i)
			{
				var rawQuery:String = rawQueries[i] as String;
				if(rawQuery == null)
				{
					throw new ArgumentError("Each query must be a String.");
				}
				var parameters:Object = params;
				if(params is Array && i < params.length)
				{
					parameters = params[i];
				}
				statement.addQuery(rawQuery, parameters);
			}
			statement.execute(failOnError, transaction);
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

			// Format second callback parameter based on query type
			if(_queryType == SELECT)
			{
				// Return single value (first item or aggregate value)
				if(_selectFirstOnly || _aggregate != null)
				{
					var firstItem:Object = (result.data.length > 0) ? result.data[0] : null;
					if(_aggregate != null)
					{
						firstItem = (firstItem !== null && _aggregate in firstItem) ? firstItem[_aggregate] : 0;
					}
					params[1] = firstItem;
				}
				// Return entire Collection
				else
				{
					params[1] = result.data;
				}
			}
			else if(_queryType == UPDATE || _queryType == DELETE)
			{
				// Return rows affected
				params[1] = result.rowsAffected;
			}
			else if(_getLastInsertId)
			{
				// Return the last inserted id
				params[1] = result.lastInsertRowID;
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
			finishQuery([null, schema.tables.length > 0]);
		}


		private function onTableSchemaLoadError(event:SQLErrorEvent):void
		{
			_db.connection.removeEventListener(SQLEvent.SCHEMA, onTableSchemaLoadSuccess);
			_db.connection.removeEventListener(SQLErrorEvent.ERROR, onTableSchemaLoadError);

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

			finishQuery([null, hasColumn]);
		}


		private function onColumnSchemaLoadError(event:SQLErrorEvent):void
		{
			_db.connection.removeEventListener(SQLEvent.SCHEMA, onColumnSchemaLoadSuccess);
			_db.connection.removeEventListener(SQLErrorEvent.ERROR, onColumnSchemaLoadError);

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


		/**
		 * @private
		 */
		internal function get selectFirstOnly():Boolean
		{
			return _selectFirstOnly;
		}


		/**
		 * @private
		 */
		internal function set selectFirstOnly(value:Boolean):void
		{
			_selectFirstOnly = value;
		}


		/**
		 * @private
		 */
		internal function get aggregate():String
		{
			return _aggregate;
		}


		/**
		 * @private
		 */
		internal function set aggregate(value:String):void
		{
			_aggregate = value;
		}


		/**
		 * @private
		 */
		internal function get getLastInsertId():Boolean
		{
			return _getLastInsertId;
		}


		/**
		 * @private
		 */
		internal function set getLastInsertId(value:Boolean):void
		{
			_getLastInsertId = value;
		}
	}
	
}
