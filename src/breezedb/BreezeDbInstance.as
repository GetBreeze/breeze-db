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
	import breezedb.events.BreezeDatabaseEvent;
	import breezedb.events.BreezeMigrationEvent;
	import breezedb.events.BreezeQueryEvent;
	import breezedb.migrations.BreezeMigrationsRunner;
	import breezedb.queries.BreezeQueryBuilder;
	import breezedb.queries.BreezeQueryReference;
	import breezedb.queries.BreezeRawQuery;
	import breezedb.schemas.BreezeSchemaBuilder;

	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLTransactionLockType;
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

        // String or ByteArray
		private var _encryptionKey:* = null;

		// Migrations
		private var _migrations:*;
		private var _migrationsRunner:BreezeMigrationsRunner;

		// Transaction callbacks
		private var _beginCallback:Function;
		private var _commitCallback:Function;
		private var _rollBackCallback:Function;

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
				callback(new IllegalOperationError("There is no active database connection."));
				return;
			}

			_beginCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.BEGIN, onTransactionBegan);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionBeginError);
			_sqlConnection.begin(SQLTransactionLockType.IMMEDIATE);
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

			if(!inTransaction)
			{
				callback(new IllegalOperationError("There is no active transaction."));
				return;
			}

			_commitCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.COMMIT, onTransactionCommitted);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionCommitError);
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

			if(!inTransaction)
			{
				callback(new IllegalOperationError("There is no active transaction."));
				return;
			}

			_rollBackCallback = callback;

			_sqlConnection.addEventListener(SQLEvent.ROLLBACK, onTransactionRolledBack);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionRollBackError);
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
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.query(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function select(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.select(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function insert(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.insert(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function update(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.update(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function remove(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.remove(rawQuery, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQuery(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.multiQuery(rawQueries, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQueryFailOnError(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.multiQueryFailOnError(rawQueries, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function multiQueryTransaction(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			var query:BreezeRawQuery = new BreezeRawQuery(this);
			query.addEventListener(BreezeQueryEvent.ERROR, onRawQueryCompleted, false, 0, true);
			query.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryCompleted, false, 0, true);
			return query.multiQueryTransaction(rawQueries, params, callback);
		}


		/**
		 * @inheritDoc
		 */
		public function runMigrations(migrations:*, callback:Function):void
		{
			if(callback == null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			if(migrations == null)
			{
				throw new ArgumentError("Parameter migrations cannot be null.");
			}

			if(!isSetup || _isSettingUp)
			{
				callback(new IllegalOperationError("Database must be set up before running migrations."));
				return;
			}

			runMigrationsInternal(migrations, callback);
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

			// Run migrations if there are any
			if(_migrations != null)
			{
				// This flag must be set to true otherwise we would not be able to run migration queries
				_isSetup = true;

				runMigrationsInternal(_migrations, onSetupMigrationsCompleted);
			}
			// Otherwise finalize the setup
			else
			{
				finalizeSetup();
			}
		}


		private function onSetupMigrationsCompleted(migrationsError:Error):void
		{
			// Migrations failed, close the database connection
			if(migrationsError != null)
			{
				_isSettingUp = false;
				close(function(error:Error):void
				{
					finalizeSetup(migrationsError);
				});
			}
			// Otherwise finalize the setup
			else
			{
				finalizeSetup();
			}
		}


		private function finalizeSetup(error:Error = null):void
		{
			// Setup successfully
			if(error == null)
			{
				_isSetup = true;

				dispatchDatabaseEvent(BreezeDatabaseEvent.SETUP_SUCCESS);
			}
			// Setup failed
			else
			{
				_isSetup = false;

				dispatchDatabaseEvent(BreezeDatabaseEvent.SETUP_ERROR, error);
			}

			_isSettingUp = false;
			var callback:Function = _setupCallback;
			_setupCallback = null;
			callback(error);
		}


		private function onDatabaseOpenError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseOpenSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseOpenError);

			finalizeSetup(event.error);
		}


		private function onDatabaseCloseSuccess(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseCloseSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);

			_isSetup = false;
			_isClosing = false;

			dispatchDatabaseEvent(BreezeDatabaseEvent.CLOSE_SUCCESS);

			var callback:Function = _closeCallback;
			_closeCallback = null;
			callback(null);
		}


		private function onDatabaseCloseError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.OPEN, onDatabaseCloseSuccess);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onDatabaseCloseError);

			_isClosing = false;

			dispatchDatabaseEvent(BreezeDatabaseEvent.CLOSE_ERROR, event.error);

			var callback:Function = _closeCallback;
			_closeCallback = null;
			callback(event.error);
		}


		private function onTransactionBegan(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.BEGIN, onTransactionBegan);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionBeginError);

			dispatchDatabaseEvent(BreezeDatabaseEvent.BEGIN_SUCCESS);

			var callback:Function = _beginCallback;
			_beginCallback = null;
			triggerTransactionCallback(callback);
		}


		private function onTransactionBeginError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.BEGIN, onTransactionBegan);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionBeginError);

			dispatchDatabaseEvent(BreezeDatabaseEvent.BEGIN_ERROR, event.error);

			var callback:Function = _beginCallback;
			_beginCallback = null;
			triggerTransactionCallback(callback, event.error);
		}


		private function onTransactionCommitted(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.COMMIT, onTransactionCommitted);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionCommitError);

			dispatchDatabaseEvent(BreezeDatabaseEvent.COMMIT_SUCCESS);

			var callback:Function = _commitCallback;
			_commitCallback = null;
			triggerTransactionCallback(callback);
		}


		private function onTransactionCommitError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.COMMIT, onTransactionBegan);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionCommitError);

			dispatchDatabaseEvent(BreezeDatabaseEvent.COMMIT_ERROR, event.error);

			var callback:Function = _commitCallback;
			_commitCallback = null;
			triggerTransactionCallback(callback, event.error);
		}


		private function onTransactionRolledBack(event:SQLEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.ROLLBACK, onTransactionRolledBack);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionRollBackError);

			dispatchDatabaseEvent(BreezeDatabaseEvent.ROLL_BACK_SUCCESS);

			var callback:Function = _rollBackCallback;
			_rollBackCallback = null;
			triggerTransactionCallback(callback);
		}


		private function onTransactionRollBackError(event:SQLErrorEvent):void
		{
			_sqlConnection.removeEventListener(SQLEvent.ROLLBACK, onTransactionBegan);
			_sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionRollBackError);

			dispatchDatabaseEvent(BreezeDatabaseEvent.ROLL_BACK_ERROR, event.error);

			var callback:Function = _rollBackCallback;
			_rollBackCallback = null;
			triggerTransactionCallback(callback, event.error);
		}


		private function triggerTransactionCallback(callback:Function, error:Error = null):void
		{
			if(callback != null)
			{
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
			if(encryptionKey === null || encryptionKey is ByteArray)
			{
				return encryptionKey;
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


		private function onRawQueryCompleted(event:BreezeQueryEvent):void
		{
			if(hasEventListener(event.type))
			{
				dispatchEvent(event);
			}
		}


		private function runMigrationsInternal(migrations:*, callback:Function):void
		{
			_migrationsRunner = new BreezeMigrationsRunner(this);
			_migrationsRunner.addEventListener(BreezeMigrationEvent.RUN_SUCCESS, onMigrationEventReceived, false, 0, true);
			_migrationsRunner.addEventListener(BreezeMigrationEvent.RUN_ERROR, onMigrationEventReceived, false, 0, true);
			_migrationsRunner.addEventListener(BreezeMigrationEvent.SKIP, onMigrationEventReceived, false, 0, true);
			_migrationsRunner.addEventListener(BreezeMigrationEvent.FINISH, onMigrationEventReceived, false, 0, true);
			_migrationsRunner.breezedb_internal::run(migrations, callback);
		}


		private function onMigrationEventReceived(event:BreezeMigrationEvent):void
		{
			if(hasEventListener(event.type))
			{
				dispatchEvent(event);
			}
		}


		private function dispatchDatabaseEvent(eventType:String, error:Error = null):void
		{
			if(hasEventListener(eventType))
			{
				dispatchEvent(new BreezeDatabaseEvent(eventType, error));
			}
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
		public function get migrations():*
		{
			return _migrations;
		}


		/**
		 * @inheritDoc
		 */
		public function set migrations(value:*):void
		{
			_migrations = value;
		}


		/**
		 * @inheritDoc
		 */
		public function set encryptionKey(value:*):void
		{
			if(_isSetup)
			{
				throw new IllegalOperationError("Encryption key must be set before calling setup().")
			}

			if(!((value === null) || (value is String) || (value is ByteArray)))
			{
				throw new ArgumentError("Parameter value can be a String, ByteArray or null.");
			}

			if(value is String && String(value).length == 0)
			{
				throw new ArgumentError("Encryption key cannot be empty String");
			}

			if(value is ByteArray && ByteArray(value).length != 16)
			{
				throw new ArgumentError("ByteArray encryption key must be 16 bytes long.");
			}

			_encryptionKey = value;
		}


		/**
		 * @inheritDoc
		 */
		public function get encryptionKey():*
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


		/**
		 * @inheritDoc
		 */
		public function get inTransaction():Boolean
		{
			return isSetup && _sqlConnection.inTransaction;
		}
	}
	
}
