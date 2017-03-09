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
	import breezedb.collections.Collection;
	import breezedb.events.BreezeQueryEvent;
	import breezedb.utils.Callback;
	import breezedb.utils.GarbagePrevention;

	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	internal class BreezeSQLMultiStatement extends EventDispatcher
	{
		private var _isRunning:Boolean;
		private var _currentIndex:int = -1;
		private var _currentRawQuery:String;
		private var _failOnError:Boolean;
		private var _transaction:Boolean;

		// True if this multi-statement is in control of the current transaction
		private var _transactionControl:Boolean;

		private var _db:IBreezeDatabase;
		private var _callback:Function;
		private var _queries:Array;
		private var _results:Vector.<BreezeQueryResult>;
		private var _fatalError:Error;


		public function BreezeSQLMultiStatement()
		{
			_queries = [];
			_results = new <BreezeQueryResult>[];
		}
		
		
		/**
		 *
		 *
		 * Public API
		 *
		 *
		 */
		

		/**
		 * Adds a query to the list of queries to be executed.
		 *
		 * @param query Either a raw query (String) or delayed BreezeQueryRunner.
		 * @param params Parameters for the raw query.
		 * @param transaction true if the multi-statement will be run within a transaction. In that case,
		 *        any multi-query runners cannot run within a transaction.
		 */
		public function addQuery(query:*, params:Object = null, transaction:Boolean = false):void
		{
			// Raw query, create SQL statement
			if(query is String)
			{
				var statement:BreezeSQLStatement = new BreezeSQLStatement(onRawQueryCompleted);
				statement.text = query;
				if(params != null)
				{
					for(var key:String in params)
					{
						var paramKey:String = ((key.charAt(0) == ":") ? "" : ":") + key;
						statement.parameters[paramKey] = params[key];
					}
				}
				_queries[_queries.length] = statement;
			}
			// Query runner is executed as is, no SQL statement is created for it
			// because the runner can execute multiple queries itself
			else if(query is BreezeQueryRunner)
			{
				// Run the query in transaction only if this multi-statement is not run in transaction
				BreezeQueryRunner(query).setMultiQueryMethod(transaction ? BreezeQueryRunner.MULTI_QUERY_FAIL_ON_ERROR : BreezeQueryRunner.MULTI_QUERY_TRANSACTION);
				_queries[_queries.length] = query;
			}
			else
			{
				throw new ArgumentError("Parameter query must be a String or BreezeQueryRunner");
			}
		}
		
		
		public function execute(failOnError:Boolean = true, transaction:Boolean = false, callback:Function = null):void
		{
			if(_db == null)
			{
				throw new IllegalOperationError("Database must be set before executing the queries.");
			}

			if(_isRunning)
			{
				throw new Error("The execute statement can not be called while queries are running");
			}

			_callback = callback;

			_transaction = transaction;
			_failOnError = failOnError;
			_isRunning = true;

			if(transaction && !_db.inTransaction)
			{
				_transactionControl = true;
				_db.beginTransaction(onTransactionBegan);
				return;
			}

			startExecution();
		}


		public function setDatabase(db:IBreezeDatabase):void
		{
			_db = db;
		}


		/**
		 *
		 *
		 * Private API
		 *
		 *
		 */


		private function startExecution():void
		{
			GarbagePrevention.instance.add(this);

			executeNextStatement();
		}
		
		
		private function onRawQueryCompleted(error:Error, statement:SQLStatement):void
		{
			var result:BreezeQueryResult = new BreezeQueryResult(statement.getResult(), error);
			addResult(result);
		}
		
		
		private function onQueryRunnerCompleted(error:Error, queryResult:* = null):void
		{
			var result:BreezeQueryResult = null;

			// Generic result
			if(queryResult is BreezeSQLResult)
			{
				result = new BreezeQueryResult(BreezeSQLResult(queryResult).sqlResult, error);
			}
			// SELECT result
			else if(queryResult is Collection)
			{
				result = new BreezeQueryResult(new SQLResult(Collection(queryResult).all), error);
			}
			// DELETE, UPDATE or aggregate result
			else if(queryResult is Number)
			{
				var rowsAffected:int = (queryResult is int) ? queryResult : 0;
				result = new BreezeQueryResult(new SQLResult([queryResult], rowsAffected), error);
			}
			// Multi-query result
			else if(queryResult is Vector.<BreezeQueryResult>)
			{
				var multiResult:Vector.<BreezeQueryResult> = queryResult as Vector.<BreezeQueryResult>;
				if(multiResult.length > 0)
				{
					result = multiResult[0];
				}
			}
			// Single object, e.g. when executing first()
			else if(queryResult != null)
			{
				result = new BreezeQueryResult(new SQLResult([queryResult]), error);
			}

			if(result == null)
			{
				result = new BreezeQueryResult(new SQLResult(), error);
			}

			addResult(result);
		}


		private function addResult(result:BreezeQueryResult):void
		{
			_results[_currentIndex] = result;

			// Dispatch event for each sub-query
			var eventType:String = (result.error == null) ? BreezeQueryEvent.SUCCESS : BreezeQueryEvent.ERROR;
			if(hasEventListener(eventType))
			{
				dispatchEvent(new BreezeQueryEvent(eventType, result.error, result, _currentRawQuery));
			}

			if(result.error != null && (_failOnError || _transaction))
			{
				_fatalError = result.error;
				if(_transaction && _db.inTransaction && _transactionControl)
				{
					_db.rollBack(onTransactionEnded);
					return;
				}
				finalize();
				return;
			}

			executeNextStatement();
		}
		
		
		private function onTransactionBegan(error:Error):void
		{
			if(error == null)
			{
				startExecution();
			}
			else
			{
				_fatalError = error;
				finalize();
			}
		}


		private function onTransactionEnded(error:Error):void
		{
			if(error != null && _fatalError == null)
			{
				_fatalError = error;
			}
			finalize();
		}


		private function executeNextStatement():void
		{
			if(_currentIndex >= _queries.length - 1)
			{
				if(_transaction && _db.inTransaction && _transactionControl)
				{
					_db.commit(onTransactionEnded);
					return;
				}

				finalize();
				return;
			}

			var query:* = _queries[++_currentIndex];

			// Execute SQL statement
			if(query is BreezeSQLStatement)
			{
				var statement:BreezeSQLStatement = query as BreezeSQLStatement;
				statement.sqlConnection = _db.connection;
				_currentRawQuery = statement.text;
				statement.execute();
			}
			// Otherwise execute delayed query runner
			else
			{
				_currentRawQuery = BreezeQueryRunner(query).queryString;
				BreezeQueryRunner(query).exec(onQueryRunnerCompleted);
			}
		}


		private function finalize():void
		{
			_isRunning = false;
			GarbagePrevention.instance.remove(this);

			var result:Array = [];
			if(_failOnError || _transaction)
			{
				result[0] = _fatalError;
			}
			result[result.length] = _results;

			Callback.call(_callback, [result]);
		}
	}
	
}
