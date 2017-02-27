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

	import flash.data.SQLStatement;
	import flash.errors.IllegalOperationError;

	internal class BreezeSQLMultiStatement
	{
		private var _isRunning:Boolean;
		private var _currentIndex:int = -1;
		private var _failOnError:Boolean;
		private var _transaction:Boolean;

		private var _db:IBreezeDatabase;
		private var _callback:Function;
		private var _queries:Vector.<BreezeSQLStatement>;
		private var _results:Vector.<BreezeQueryResult>;
		private var _fatalError:Error;


		public function BreezeSQLMultiStatement()
		{
			_queries = new <BreezeSQLStatement>[];
			_results = new <BreezeQueryResult>[];
		}
		
		
		/**
		 *
		 *
		 * Public API
		 *
		 *
		 */
		
		
		public function addQuery(query:String, params:Object = null):void
		{
			var statement:BreezeSQLStatement = new BreezeSQLStatement(onQueryCompleted);
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

			if(transaction)
			{
				_db.beginTransaction();
			}

			GarbagePrevention.instance.add(this);

			executeNextStatement();
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
		
		
		private function onQueryCompleted(error:Error, statement:SQLStatement):void
		{
			_results[_currentIndex] = new BreezeQueryResult(statement.getResult(), error);

			if(error != null && (_failOnError || _transaction))
			{
				if(_transaction)
				{
					_db.rollBack();
				}
				_fatalError = error;
				finalize();
				return;
			}

			executeNextStatement();
		}


		private function executeNextStatement():void
		{
			if(_currentIndex >= _queries.length - 1)
			{
				if(_transaction)
				{
					_db.commit();
				}

				finalize();
				return;
			}

			var statement:BreezeSQLStatement = _queries[++_currentIndex];
			statement.sqlConnection = _db.connection;
			statement.execute();
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
