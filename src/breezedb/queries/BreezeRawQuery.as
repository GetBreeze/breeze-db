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

	import flash.data.SQLConnection;

	/**
	 * @private
	 */
	public class BreezeRawQuery implements ICancellableRawQuery
	{
		private static const RAW:int = 0;
		private static const SELECT:int = 1;
		private static const INSERT:int = 2;
		private static const UPDATE:int = 3;
		private static const DELETE:int = 4;

		private var _queryType:int;
		private var _isCancelled:Boolean;
		private var _isCompleted:Boolean;

		private var _db:IBreezeDatabase;
		private var _sqlConnection:SQLConnection;
		private var _callback:Function;

		public function BreezeRawQuery(db:IBreezeDatabase)
		{
			_db = db;
			_sqlConnection = db.connection;
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
		public function query(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			return new BreezeQueryReference(this);
		}


		/**
		 * @inheritDoc
		 */
		public function select(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			_queryType = SELECT;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function insert(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			_queryType = INSERT;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function update(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			_queryType = UPDATE;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function remove(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			_queryType = DELETE;
			return query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function cancel():void
		{
			_isCancelled = true;
			_callback = null;
		}


		/**
		 *
		 *
		 * Getters / Setters
		 *
		 *
		 */
		

		/**
		 * @inheritDoc
		 */
		public function get isCancelled():Boolean
		{
			return _isCancelled;
		}


		/**
		 * @inheritDoc
		 */
		public function get isCompleted():Boolean
		{
			return _isCompleted;
		}
	}
	
}
