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
		private var _name:String;
		private var _file:File;
		private var _encryptionKey:String;

		private var _setupCallback:Function;
		private var _closeCallback:Function;
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
				_setupCallback = null;
				callback(e);
			}
		}


		/**
		 * @inheritDoc
		 */
		public function table(tableName:String):BreezeQueryBuilder
		{
			return new BreezeQueryBuilder(this, tableName);
		}


		/**
		 * @inheritDoc
		 */
		public function beginTransaction():void
		{
		}


		/**
		 * @inheritDoc
		 */
		public function commit():void
		{
		}


		/**
		 * @inheritDoc
		 */
		public function rollBack():void
		{
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
				callback(new Error("There is no active database connection."));
				return;
			}

			_closeCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.CLOSE, onDatabaseCloseSuccess);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);
			_sqlConnection.close();
		}


		/**
		 * @inheritDoc
		 */
		public function query(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			return null;
		}


		/**
		 * @inheritDoc
		 */
		public function select(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			return null;
		}


		/**
		 * @inheritDoc
		 */
		public function insert(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			return null;
		}


		/**
		 * @inheritDoc
		 */
		public function update(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			return null;
		}


		/**
		 * @inheritDoc
		 */
		public function remove(rawQuery:String, params:*, callback:Function = null):BreezeQueryReference
		{
			return null;
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

			var callback:Function = _setupCallback;
			_setupCallback = null;
			callback(null);
		}


		private function onDatabaseOpenError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseOpenSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseOpenError);

			_isSetup = false;

			var callback:Function = _setupCallback;
			_setupCallback = null;
			callback(event.error);
		}


		private function onDatabaseCloseSuccess(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseCloseSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);

			_isSetup = false;

			var callback:Function = _closeCallback;
			_closeCallback = null;
			callback(null);
		}


		private function onDatabaseCloseError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseCloseSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);

			var callback:Function = _closeCallback;
			_closeCallback = null;
			callback(event.error);
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
			var bytes:int = 0;
			for(var i:int = 0; i < length; i += groups)
			{
				var over:Boolean = i + groups >= length;
				var hex:String = key.substr(i, over ? 0x7fffffff : groups);
				var byte:int = 0;
				for(var j:int = 0; j < hex.length; ++j)
				{
					var char:String = hex.charAt(j);
					byte += char.charCodeAt(0);
				}
				byte = byte % 255;
				result.writeByte(byte);
				bytes++;
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
	}
	
}
