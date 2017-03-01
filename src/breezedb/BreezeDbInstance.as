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

package breezedb
{
	import breezedb.queries.BreezeQueryBuilder;
	import breezedb.queries.BreezeQueryReference;
	import breezedb.queries.BreezeRawQuery;
	import breezedb.schemas.BreezeSchemaBuilder;

	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	internal class BreezeDbInstance extends EventDispatcher implements IBreezeDatabase
	{
		private var _isSetup:Boolean;
		private var _isSettingUp:Boolean;
		private var _isClosing:Boolean;
		private var _name:String;
		private var _file:File;
		private var _encryptionKey:String;

		private var _setupCallback:Function;
		private var _closeCallback:Function;
		private var _transactionCallback:Function;
		private var _sqlConnection:SQLConnection;

		public function BreezeDbInstance(name:String)
		{
			if(name == null)
			{
				throw new ArgumentError("Database name cannot be null.");
			}

			_name = name;
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
		public function setup(callback:Function, databaseFile:File = null):void
		{
			if(callback === null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			if(databaseFile == null)
			{
				databaseFile = BreezeDb.storageDirectory.resolvePath(name + BreezeDb.fileExtension);
			}

			if(databaseFile.isDirectory)
			{
				throw new ArgumentError("Parameter databaseFile must point to a file, not a directory.");
			}

			if(isSetup)
			{
				callback(null);
				return;
			}

			if(_isSettingUp)
			{
				callback(new IllegalOperationError("Database setup is currently in progress."));
				return;
			}

			if(_isClosing)
			{
				callback(new IllegalOperationError("Database is currently being closed."));
				return;
			}

			_isSettingUp = true;
			_file = databaseFile;
			_setupCallback = callback;

			_sqlConnection = new SQLConnection();
			_sqlConnection.addEventListener(SQLEvent.OPEN, onDatabaseOpenSuccess);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onDatabaseOpenError);

			try
			{
				_sqlConnection.openAsync(_file, SQLMode.CREATE, null, false, 1024, generateEncryptionKey());
			}
			catch(e:Error)
			{
				_isSettingUp = false;
				_setupCallback = null;
				callback(e);
			}
		}


		/**
		 * @inheritDoc
		 */
		public function table(tableName:String):BreezeQueryBuilder
		{
			if(!isSetup)
			{
				throw new IllegalOperationError("There is no active database connection.");
			}
			return new BreezeQueryBuilder(this, tableName);
		}


		/**
		 * @inheritDoc
		 */
		public function beginTransaction(callback:Function):void
		{
			if(callback == null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			if(!isSetup)
			{
				throw new IllegalOperationError("There is no active database connection.");
			}

			_transactionCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.BEGIN, onTransactionBegan);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionError);
			_sqlConnection.begin();
		}


		/**
		 * @inheritDoc
		 */
		public function commit(callback:Function):void
		{
			if(callback == null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			if(!isSetup)
			{
				throw new IllegalOperationError("There is no active database connection.");
			}

			_transactionCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.COMMIT, onTransactionCommitted);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionError);
			_sqlConnection.commit();
		}


		/**
		 * @inheritDoc
		 */
		public function rollBack(callback:Function):void
		{
			if(callback == null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			if(!isSetup)
			{
				throw new IllegalOperationError("There is no active database connection.");
			}

			_transactionCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.ROLLBACK, onTransactionRolledBack);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionError);
			_sqlConnection.rollback();
		}


		/**
		 * @inheritDoc
		 */
		public function close(callback:Function):void
		{
			if(callback === null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			if(_sqlConnection == null || !_sqlConnection.connected)
			{
				callback(new IllegalOperationError("There is no active database connection."));
				return;
			}

			if(_isSettingUp)
			{
				callback(new IllegalOperationError("Database setup is currently in progress."));
				return;
			}

			if(_isClosing)
			{
				callback(new IllegalOperationError("Database is currently being closed."));
				return;
			}

			_isClosing = true;
			_closeCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.CLOSE, onDatabaseCloseSuccess);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);
			_sqlConnection.close();
		}


		/**
		 * @inheritDoc
		 */
		public function query(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function select(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).select(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function insert(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).insert(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function update(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).update(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function remove(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).remove(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQuery(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).multiQuery(rawQueries, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQueryFailOnError(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).multiQueryFailOnError(rawQueries, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQueryTransaction(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return new BreezeRawQuery(this).multiQueryTransaction(rawQueries, params, callback);
		}


		/**
		 *
		 *
		 * Private API
		 *
		 *
		 */


		private function onDatabaseOpenSuccess(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseOpenSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseOpenError);

			_isSetup = true;
			_isSettingUp = false;

			var callback:Function = _setupCallback;
			_setupCallback = null;
			callback(null);
		}


		private function onDatabaseOpenError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseOpenSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseOpenError);

			_isSetup = false;
			_isSettingUp = false;

			var callback:Function = _setupCallback;
			_setupCallback = null;
			callback(event.error);
		}


		private function onDatabaseCloseSuccess(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseCloseSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);

			_isSetup = false;
			_isClosing = false;

			var callback:Function = _closeCallback;
			_closeCallback = null;
			callback(null);
		}


		private function onDatabaseCloseError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseCloseSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);

			_isClosing = false;

			var callback:Function = _closeCallback;
			_closeCallback = null;
			callback(event.error);
		}


		private function onTransactionBegan(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.BEGIN, onTransactionBegan);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionError);

			triggerTransactionCallback();
		}


		private function onTransactionCommitted(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.COMMIT, onTransactionCommitted);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionError);

			triggerTransactionCallback();
		}


		private function onTransactionRolledBack(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.ROLLBACK, onTransactionRolledBack);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionError);

			triggerTransactionCallback();
		}


		private function onTransactionError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.BEGIN, onTransactionBegan);
			_sqlConnection.removeEventListener(SQLEvent.COMMIT, onTransactionCommitted);
			_sqlConnection.removeEventListener(SQLEvent.ROLLBACK, onTransactionRolledBack);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionError);

			triggerTransactionCallback(event.error);
		}


		private function triggerTransactionCallback(error:Error = null):void
		{
			if(_transactionCallback != null)
			{
				var callback:Function = _transactionCallback;
				_transactionCallback = null;
				if(callback.length == 1)
				{
					callback(error);
				}
				else
				{
					callback();
				}
			}
		}


		private function generateEncryptionKey():ByteArray
		{
			if(encryptionKey == null)
			{
				return null;
			}

			var key:String = encryptionKey;
			while(key.length < 16)
			{
				key += encryptionKey;
			}

			var result:ByteArray = new ByteArray();
			var mod:int = key.length % 16;
			if(mod != 0)
			{
				key += key.substr(key.length - 16 + mod);
			}
			var length:uint = key.length;
			var groups:int = length / 16;
			for(var i:int = 0; i < length; i += groups)
			{
				var over:Boolean = i + groups >= length;
				var group:String = key.substr(i, over ? 0x7fffffff : groups);
				var byte:int = 0;
				for(var j:int = 0; j < group.length; ++j)
				{
					var char:String = group.charAt(j);
					byte += char.charCodeAt(0);
				}
				byte = byte % 255;
				result.writeByte(byte);
				if(over)
				{
					break;
				}
			}
			return result;
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
		public function set encryptionKey(value:String):void
		{
			if(_isSetup)
			{
				throw new IllegalOperationError("Encryption key must be set before calling setup().")
			}

			_encryptionKey = value;
		}


		/**
		 * @inheritDoc
		 */
		public function get encryptionKey():String
		{
			return _encryptionKey;
		}


		/**
		 * @inheritDoc
		 */
		public function get schema():BreezeSchemaBuilder
		{
			return new BreezeSchemaBuilder(this);
		}


		/**
		 * @inheritDoc
		 */
		public function get file():File
		{
			return _file;
		}


		/**
		 * @inheritDoc
		 */
		public function get name():String
		{
			return _name;
		}


		/**
		 * @inheritDoc
		 */
		public function get isSetup():Boolean
		{
			return _isSetup && _sqlConnection != null && _sqlConnection.connected;
		}


		/**
		 * @inheritDoc
		 */
		public function get connection():SQLConnection
		{
			return _sqlConnection;
		}
	}
	
}
