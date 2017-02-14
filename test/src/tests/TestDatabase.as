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

	import breezetest.Assert;
	import breezetest.async.Async;

	import flash.filesystem.File;
	
	public class TestDatabase
	{

		public var currentAsync:Async;
		
		public function testSetupAndClose(async:Async):void
		{
			async.timeout = 5000;

			// Setup db in the default storage directory
			Assert.isFalse(BreezeDb.db.isSetup);
			BreezeDb.db.setup(onDefaultDbSetup);
		}


		private function onDefaultDbSetup(error:Error):void
		{
			Assert.isNull(error);
			Assert.isTrue(BreezeDb.db.isSetup);
			Assert.isNotNull(BreezeDb.db.file);
			Assert.isTrue(BreezeDb.db.file.exists);

			BreezeDb.db.close(onDefaultDbClosed);
		}


		private function onDefaultDbClosed(error:Error):void
		{
			Assert.isNull(error);
			Assert.isFalse(BreezeDb.db.isSetup);

			BreezeDb.db.file.deleteFile();

			// Setup db in custom file
			var file:File = File.applicationStorageDirectory.resolvePath("custom-db-file.sqlite");
			var customDb:IBreezeDatabase = BreezeDb.getDb("custom-db");
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

			customDb.close(onCustomDbClosed);
		}


		private function onCustomDbClosed(error:Error):void
		{
			Assert.isNull(error);

			var customDb:IBreezeDatabase = BreezeDb.getDb("custom-db");
			Assert.isFalse(customDb.isSetup);

			customDb.file.deleteFile();

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
		
	}
	
}
