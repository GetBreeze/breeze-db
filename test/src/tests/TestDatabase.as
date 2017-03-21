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

package tests
{
	import breezedb.BreezeDb;
	import breezedb.IBreezeDatabase;
	import breezedb.collections.Collection;
	import breezedb.events.BreezeDatabaseEvent;
	import breezedb.events.BreezeQueryEvent;
	import breezedb.schemas.TableBlueprint;

	import breezetest.Assert;
	import breezetest.async.Async;

	import flash.errors.IllegalOperationError;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	public class TestDatabase
	{

		private var _numRawQueryExecutedEvents:int;
		private var _numTransactionBeginEvents:int;
		private var _numTransactionCommitEvents:int;
		private var _numTransactionRollBackEvents:int;
		private var _numDbSetupEvents:int;
		private var _numDbCloseEvents:int;

		public var currentAsync:Async;
		public var _transactionDb:IBreezeDatabase;
		
		public function testSetupAndClose(async:Async):void
		{
			async.timeout = 5000;

			// Setup db in the default storage directory
			Assert.isFalse(BreezeDb.db.isSetup);

			BreezeDb.db.addEventListener(BreezeDatabaseEvent.SETUP_ERROR, onDbSetupErrorEvent);
			BreezeDb.db.addEventListener(BreezeDatabaseEvent.SETUP_SUCCESS, onDbSetupSuccessEvent);
			BreezeDb.db.addEventListener(BreezeDatabaseEvent.CLOSE_ERROR, onDbCloseErrorEvent);
			BreezeDb.db.addEventListener(BreezeDatabaseEvent.CLOSE_SUCCESS, onDbCloseSuccessEvent);
			BreezeDb.db.setup(onDefaultDbSetup);

			// Cannot setup while another setup is in progress
			BreezeDb.db.setup(function(error:Error):void
			{
				Assert.isNotNull(error);
				Assert.isType(error, IllegalOperationError);
			});
		}
		
		
		private function onDbSetupErrorEvent(event:BreezeDatabaseEvent):void
		{
			Assert.fail("Setup error event should not be dispatched.");
		}
		
		
		private function onDbSetupSuccessEvent(event:BreezeDatabaseEvent):void
		{
			Assert.equals(BreezeDatabaseEvent.SETUP_SUCCESS, event.type);
			
			_numDbSetupEvents++;
		}


		private function onDbCloseErrorEvent(event:BreezeDatabaseEvent):void
		{
			Assert.fail("Close error event should not be dispatched.");
		}


		private function onDbCloseSuccessEvent(event:BreezeDatabaseEvent):void
		{
			Assert.equals(BreezeDatabaseEvent.CLOSE_SUCCESS, event.type);

			_numDbCloseEvents++;
		}


		private function onDefaultDbSetup(error:Error):void
		{
			Assert.isNull(error);
			Assert.isTrue(BreezeDb.db.isSetup);
			Assert.isNotNull(BreezeDb.db.file);
			Assert.isTrue(BreezeDb.db.file.exists);

			BreezeDb.db.close(onDefaultDbClosed);

			// Cannot close while another close is in progress
			BreezeDb.db.close(function(error:Error):void
			{
				Assert.isNotNull(error);
				Assert.isType(error, IllegalOperationError);
			});
		}


		private function onDefaultDbClosed(error:Error):void
		{
			Assert.isNull(error);
			Assert.isFalse(BreezeDb.db.isSetup);

			BreezeDb.db.file.deleteFile();

			// Setup db in custom file
			var file:File = File.applicationStorageDirectory.resolvePath("custom-db-file.sqlite");
			var customDb:IBreezeDatabase = BreezeDb.getDb("custom-db");
			customDb.addEventListener(BreezeDatabaseEvent.SETUP_ERROR, onDbSetupErrorEvent);
			customDb.addEventListener(BreezeDatabaseEvent.SETUP_SUCCESS, onDbSetupSuccessEvent);
			customDb.encryptionKey = "fDIOeVLyhh";

			Assert.notSame(customDb, BreezeDb.db);

			customDb.setup(onCustomDbSetup, file);
		}


		private function onCustomDbSetup(error:Error):void
		{
			Assert.isNull(error);

			var customDb:IBreezeDatabase = BreezeDb.getDb("custom-db");
			Assert.isTrue(customDb.isSetup);
			Assert.isNotNull(customDb.file);
			var file:File = File.applicationStorageDirectory.resolvePath("custom-db-file.sqlite");
			Assert.isTrue(file.exists);
			Assert.equals(file.url, customDb.file.url);

			Assert.throwsError(function():void
			{
				// Cannot modify after setup is called
				customDb.encryptionKey = "new-key";
			});

			customDb.addEventListener(BreezeDatabaseEvent.CLOSE_ERROR, onDbCloseErrorEvent);
			customDb.addEventListener(BreezeDatabaseEvent.CLOSE_SUCCESS, onDbCloseSuccessEvent);

            setTimeout(customDb.close, 500, onCustomDbClosed);
		}


		private function onCustomDbClosed(error:Error):void
		{
			Assert.isNull(error);

			var customDb:IBreezeDatabase = BreezeDb.getDb("custom-db");
			Assert.isFalse(customDb.isSetup);

			customDb.file.deleteFile();
			
			Assert.equals(2, _numDbSetupEvents);
			Assert.equals(2, _numDbCloseEvents);

			currentAsync.complete();
		}


		public function testEncryptionKey(async:Async):void
		{
			var db:IBreezeDatabase = BreezeDb.getDb("enc-key");

			// Empty encryption key
			Assert.throwsError(function():void
			{
				db.encryptionKey = "";
			}, ArgumentError);

			// Invalid ByteArray length
			Assert.throwsError(function():void
			{
				db.encryptionKey = new ByteArray();
			}, ArgumentError);

			// Write 16 bytes
			var key:ByteArray = new ByteArray();
			for(var i:int = 0; i < 16; ++i)
			{
				key.writeByte(i);
			}
			db.encryptionKey = key;

			db.setup(onEncryptedDbSetup);
		}

		private function onEncryptedDbSetup(error:Error):void
		{
			Assert.isNull(error);

			var db:IBreezeDatabase = BreezeDb.getDb("enc-key");
			Assert.isTrue(db.isSetup);

			Assert.throwsError(function():void
			{
				db.encryptionKey = "new-key";
			}, IllegalOperationError);

			db.close(onEncryptedDbClosed);
		}


		private function onEncryptedDbClosed(error:Error):void
		{
			Assert.isNull(error);

			var db:IBreezeDatabase = BreezeDb.getDb("enc-key");
			Assert.isFalse(db.isSetup);

			// Remove encryption key and try to open the encrypted database
			db.encryptionKey = null;

			db.setup(onEncryptedDbWithoutKeySetup);
		}


		private function onEncryptedDbWithoutKeySetup(error:Error):void
		{
			Assert.isNotNull(error);

			var db:IBreezeDatabase = BreezeDb.getDb("enc-key");
			Assert.isFalse(db.isSetup);

			// Setup again with the correct key
			var key:ByteArray = new ByteArray();
			for(var i:int = 0; i < 16; ++i)
			{
				key.writeByte(i);
			}
			db.encryptionKey = key;

			db.setup(onCheckEncryptedDbSetup);
		}


		private function onCheckEncryptedDbSetup(error:Error):void
		{
			Assert.isNull(error);

			var db:IBreezeDatabase = BreezeDb.getDb("enc-key");
			Assert.isTrue(db.isSetup);

			db.close(onEncryptedDbFinalClosed);
		}


		private function onEncryptedDbFinalClosed(error:Error):void
		{
			Assert.isNull(error);

			var db:IBreezeDatabase = BreezeDb.getDb("enc-key");
			Assert.isFalse(db.isSetup);

			db.file.deleteFile();

			currentAsync.complete();
		}


		public function testStorageDirectory():void
		{
			Assert.isNotNull(BreezeDb.storageDirectory);
			Assert.equals(File.applicationStorageDirectory.url, BreezeDb.storageDirectory.url);

			BreezeDb.storageDirectory = File.documentsDirectory;
			Assert.equals(File.documentsDirectory.url, BreezeDb.storageDirectory.url);

			Assert.throwsError(function():void
			{
				BreezeDb.storageDirectory = null;
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				BreezeDb.storageDirectory = File.applicationStorageDirectory.resolvePath("random.file");
			}, Error);

			BreezeDb.storageDirectory = File.applicationStorageDirectory;
		}
		
		
		public function testFileExtension():void
		{
			Assert.equals(".sqlite", BreezeDb.fileExtension);

			BreezeDb.fileExtension = ".dat";

			Assert.equals(".dat", BreezeDb.fileExtension);

			Assert.throwsError(function():void
			{
				BreezeDb.fileExtension = null;
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				BreezeDb.fileExtension = "  .dat";
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				BreezeDb.fileExtension = "dat";
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				BreezeDb.fileExtension = "dat.";
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				BreezeDb.fileExtension = "dat. dat";
			}, ArgumentError);

			BreezeDb.fileExtension = ".sqlite";
		}


		public function testTransaction(async:Async):void
		{
			_transactionDb = BreezeDb.getDb("transaction-test");
			_transactionDb.addEventListener(BreezeQueryEvent.ERROR, onRawQueryExecutedEvent);
			_transactionDb.addEventListener(BreezeQueryEvent.SUCCESS, onRawQueryExecutedEvent);
			_transactionDb.addEventListener(BreezeDatabaseEvent.BEGIN_SUCCESS, onTransactionBeganEvent);
			_transactionDb.addEventListener(BreezeDatabaseEvent.BEGIN_ERROR, onTransactionBeganEvent);
			_transactionDb.addEventListener(BreezeDatabaseEvent.COMMIT_SUCCESS, onTransactionCommittedEvent);
			_transactionDb.addEventListener(BreezeDatabaseEvent.COMMIT_ERROR, onTransactionCommittedEvent);
			_transactionDb.addEventListener(BreezeDatabaseEvent.ROLL_BACK_SUCCESS, onTransactionRolledBackEvent);
			_transactionDb.addEventListener(BreezeDatabaseEvent.ROLL_BACK_ERROR, onTransactionRolledBackEvent);

			// Test transaction API while the database is not setup
			_transactionDb.beginTransaction(onNonSetupDbTransactionAttempted);
			_transactionDb.commit(onNonSetupDbTransactionAttempted);
			_transactionDb.rollBack(onNonSetupDbTransactionAttempted);

			_transactionDb.setup(onTransactionDatabaseSetup);
		}


		private function onNonSetupDbTransactionAttempted(error:Error):void
		{
			Assert.isNotNull(error);
			Assert.isType(error, IllegalOperationError);
		}


		private function onTransactionDatabaseSetup(error:Error):void
		{
			Assert.isNull(error);

			_transactionDb.schema.createTable("test", function(table:TableBlueprint):void
			{
				table.increments("id");
				table.string("title").defaultNull();
			}, onTableCreated);
		}


		private function onTableCreated(error:Error):void
		{
			Assert.isNull(error);

			_transactionDb.beginTransaction(onFirstTransactionBegan);
		}


		private function onFirstTransactionBegan(error:Error):void
		{
			Assert.isNull(error);

			_transactionDb.table("test").insert({ id: 1, title: "Test" }, onFirstInsertCompleted);
		}


		private function onFirstInsertCompleted(error:Error):void
		{
			Assert.isNull(error);

			_transactionDb.rollBack(onTransactionRolledBack);
		}


		private function onTransactionRolledBack(error:Error):void
		{
			Assert.isNull(error);

			// Check the record was not inserted
			_transactionDb.table("test").fetch(onCheckRollBackCompleted);
		}


		private function onCheckRollBackCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(0, results.length);

			_transactionDb.beginTransaction(onSecondTransactionBegan);
		}


		private function onSecondTransactionBegan(error:Error):void
		{
			Assert.isNull(error);

			_transactionDb.table("test").insert({ id: 1, title: "Test" }, onSecondInsertCompleted);
		}


		private function onSecondInsertCompleted(error:Error):void
		{
			Assert.isNull(error);

			_transactionDb.commit(onTransactionCommitted);
		}


		private function onTransactionCommitted(error:Error):void
		{
			Assert.isNull(error);

			// Check the record was inserted
			_transactionDb.table("test").fetch(onCheckCommitCompleted);
		}


		private function onCheckCommitCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);
			Assert.equals(1, results[0].id);
			Assert.equals("Test", results[0].title);

            setTimeout(_transactionDb.close, 500, onTransactionDatabaseClosed);
		}


		private function onTransactionDatabaseClosed(error:Error):void
		{
			if(_transactionDb.file != null)
			{
				_transactionDb.file.deleteFile();
			}
			_transactionDb = null;

			Assert.equals(5, _numRawQueryExecutedEvents);
			Assert.equals(2, _numTransactionBeginEvents);
			Assert.equals(1, _numTransactionCommitEvents);
			Assert.equals(1, _numTransactionRollBackEvents);

			currentAsync.complete();
		}


		private function onRawQueryExecutedEvent(event:BreezeQueryEvent):void
		{
			Assert.equals(BreezeQueryEvent.SUCCESS, event.type);

			_numRawQueryExecutedEvents++;
		}


		private function onTransactionBeganEvent(event:BreezeDatabaseEvent):void
		{
			Assert.equals(BreezeDatabaseEvent.BEGIN_SUCCESS, event.type);

			_numTransactionBeginEvents++;
		}


		private function onTransactionCommittedEvent(event:BreezeDatabaseEvent):void
		{
			Assert.equals(BreezeDatabaseEvent.COMMIT_SUCCESS, event.type);

			_numTransactionCommitEvents++;
		}


		private function onTransactionRolledBackEvent(event:BreezeDatabaseEvent):void
		{
			Assert.equals(BreezeDatabaseEvent.ROLL_BACK_SUCCESS, event.type);

			_numTransactionRollBackEvents++;
		}
		
	}
	
}
