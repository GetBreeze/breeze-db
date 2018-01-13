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
	import breezedb.events.BreezeDatabaseEvent;
	import breezedb.events.BreezeSQLStatementEvent;

	import flash.utils.Dictionary;

	internal class SQLStatementQueue
	{
		private static var _queues:Dictionary;

		private var _db:IBreezeDatabase;
		private var _currentStatement:ISQLStatement;
		private var _queue:Vector.<ISQLStatement>;

		public function SQLStatementQueue(db:IBreezeDatabase)
		{
			_db = db;
			_db.addEventListener(BreezeDatabaseEvent.CLOSE_SUCCESS, onDatabaseClosed, false, 0, true);

			_queue = new <ISQLStatement>[];
		}


		public static function forDatabase(db:IBreezeDatabase):SQLStatementQueue
		{
			if(_queues == null)
			{
				_queues = new Dictionary();
			}

			// Existing queue
			if(db in _queues)
			{
				return _queues[db];
			}

			// New queue
			var queue:SQLStatementQueue = new SQLStatementQueue(db);
			_queues[db] = queue;
			return queue;
		}


		public function add(statement:ISQLStatement):void
		{
			if(_queue.length == 0 && _currentStatement == null)
			{
				_currentStatement = statement;
				_currentStatement.addEventListener(BreezeSQLStatementEvent.COMPLETE, onStatementCompleted);
				_currentStatement.exec();
				return;
			}

			_queue[_queue.length] = statement;
		}


		public function dispose():void
		{
			if(_currentStatement != null)
			{
				_currentStatement.removeEventListener(BreezeSQLStatementEvent.COMPLETE, onStatementCompleted);
				_currentStatement = null;
			}
			_db.removeEventListener(BreezeDatabaseEvent.CLOSE_SUCCESS, onDatabaseClosed);
			_db = null;
		}


		private function onStatementCompleted(event:BreezeSQLStatementEvent):void
		{
			_currentStatement.removeEventListener(BreezeSQLStatementEvent.COMPLETE, onStatementCompleted);
			_currentStatement = null;

			if(_queue.length > 0)
			{
				_currentStatement = _queue.shift();
				_currentStatement.addEventListener(BreezeSQLStatementEvent.COMPLETE, onStatementCompleted);
				_currentStatement.exec();
			}
		}


		private function onDatabaseClosed(event:BreezeDatabaseEvent):void
		{
			if(_queues != null)
			{
				var db:IBreezeDatabase = event.currentTarget as IBreezeDatabase;
				if(db in _queues)
				{
					var queue:SQLStatementQueue = _queues[db];
					queue.dispose();
					delete _queues[db];
				}
			}
		}
		
	}
	
}
