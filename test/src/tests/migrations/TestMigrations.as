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

package tests.migrations
{
	import breezedb.BreezeDb;
	import breezedb.IBreezeDatabase;
	import breezedb.collections.Collection;
	import breezedb.events.BreezeMigrationEvent;
	import breezedb.migrations.BreezeMigration;

	import breezetest.Assert;
	
	import breezetest.async.Async;

    import flash.utils.setTimeout;

    public class TestMigrations extends BreezeMigration
	{
		
		public var currentAsync:Async;
		private var _db:IBreezeDatabase;
		private var _migrationEvents:Vector.<BreezeMigrationEvent>;
		private var _testRepeatMigrations:Boolean;
		private var _isRepeatedMigration:Boolean;
		
		
		public function testSetupMigrations(async:Async):void
		{
			async.timeout = 3000;

			_migrationEvents = new <BreezeMigrationEvent>[];
			_testRepeatMigrations = true;
			_isRepeatedMigration = false;

			_db = BreezeDb.getDb("setup-migrations");
			_db.addEventListener(BreezeMigrationEvent.COMPLETE, onMigrationCompleted);
			_db.migrations = [Migration_Create_Table_Photos, Migration_Insert_Default_Photos];
			_db.setup(onSetupWithMigrationsCompleted);
		}


		private function onSetupWithMigrationsCompleted(error:Error):void
		{
			Assert.isNull(error);
			Assert.isTrue(_db.isSetup);

			validateMigrations();
		}


		private function validateMigrations():void
		{
			// Check the table has been created
			_db.schema.hasTable("photos", onCheckTableCompleted);
		}


		private function onCheckTableCompleted(error:Error, hasTable:Boolean):void
		{
			Assert.isNull(error);
			Assert.isTrue(hasTable);

			// Check the photos has been inserted
			_db.table("photos").fetch(onCheckInsertCompleted);
		}


		private function onCheckInsertCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(3, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals("Mountains", results[0].title);
			Assert.equals(35, results[0].views);
			Assert.equals(10, results[0].downloads);
			Assert.equals(4, results[0].likes);

			Assert.equals(2, results[1].id);
			Assert.equals("Flowers", results[1].title);
			Assert.equals(6, results[1].views);
			Assert.equals(6, results[1].downloads);
			Assert.equals(6, results[1].likes);

			Assert.equals(3, results[2].id);
			Assert.equals("Lake", results[2].title);
			Assert.equals(35, results[2].views);
			Assert.equals(0, results[2].downloads);
			Assert.equals(0, results[2].likes);

			Assert.equals(2, _migrationEvents.length);
			var length:int = _migrationEvents.length;
			for(var i:int = 0; i < length; ++i)
			{
				Assert.isTrue(_migrationEvents[i].successful);
				if(_isRepeatedMigration)
				{
					Assert.isFalse(_migrationEvents[i].didRun);
				}
				else
				{
					Assert.isTrue(_migrationEvents[i].didRun);
				}
			}

			_migrationEvents.length = 0;

			_db.removeEventListener(BreezeMigrationEvent.COMPLETE, onMigrationCompleted);

            setTimeout(_db.close, 500, onDbClosed);
		}


		private function onDbClosed(error:Error):void
		{
			Assert.isNull(error);

			// Try to run the same migrations again
			if(_testRepeatMigrations)
			{
				_testRepeatMigrations = false;
				_isRepeatedMigration = true;
				_db.addEventListener(BreezeMigrationEvent.COMPLETE, onMigrationCompleted);
				_db.setup(onSetupWithMigrationsCompleted);
			}
			else
			{
                _db.file.deleteFile();

                currentAsync.complete();
			}
		}


		public function testAfterSetupMigrations(async:Async):void
		{
			async.timeout = 3000;

			_migrationEvents = new <BreezeMigrationEvent>[];
			_testRepeatMigrations = false;
			_isRepeatedMigration = false;

			_db = BreezeDb.getDb("after-setup-migrations");
			_db.addEventListener(BreezeMigrationEvent.COMPLETE, onMigrationCompleted);
			_db.setup(onDbSetup);
		}


		private function onDbSetup(error:Error):void
		{
			Assert.isNull(error);
			Assert.isTrue(_db.isSetup);

			_db.runMigrations([Migration_Create_Table_Photos, Migration_Insert_Default_Photos], onAfterSetupMigrationsCompleted);
		}


		private function onAfterSetupMigrationsCompleted(error:Error):void
		{
			Assert.isNull(error);

			validateMigrations();
		}


		private function onMigrationCompleted(event:BreezeMigrationEvent):void
		{
			_migrationEvents[_migrationEvents.length] = event;
		}


		public function testInvalidMigrationClass(async:Async):void
		{
			async.timeout = 3000;

			_db = BreezeDb.getDb("invalid-migration-class");
			_db.migrations = Migration_Invalid_Class;
			_db.setup(onInvalidMigrationClassDbSetup);
		}


		private function onInvalidMigrationClassDbSetup(error:Error):void
		{
			Assert.isNotNull(error);
			Assert.isType(error, ArgumentError);
			Assert.isFalse(_db.isSetup);

            _db.file.deleteFile();

            currentAsync.complete();
		}


		public function testUnsuccessfulMigration(async:Async):void
		{
			async.timeout = 3000;

			_db = BreezeDb.getDb("unsuccessful-migration");
			_db.migrations = [Migration_Create_Table_Photos, Migration_Unsuccessful];
			_db.setup(onUnsuccessfulMigrationDbSetup);
		}


		private function onUnsuccessfulMigrationDbSetup(error:Error):void
		{
			Assert.isNotNull(error);
			Assert.isFalse(_db.isSetup);

			// Check that the successful migration has not been committed
			_db.schema.hasTable("photos", onCheckMigrationRollBackCompleted);
		}


		private function onCheckMigrationRollBackCompleted(error:Error, hasTable:Boolean):void
		{
			Assert.isFalse(hasTable);

			_db.close(function(error:Error):void
            {
                _db.file.deleteFile();

                currentAsync.complete();
            });
		}


		public function testInvalidMigrationArgument(async:Async):void
		{
			async.timeout = 3000;

			_db = BreezeDb.getDb("invalid-migration-argument");
			_db.migrations = ["Invalid migration value"];
			_db.setup(onInvalidMigrationArgumentDbSetup);
		}


		private function onInvalidMigrationArgumentDbSetup(error:Error):void
		{
			Assert.isNotNull(error);
			Assert.isFalse(_db.isSetup);

            _db.file.deleteFile();

			currentAsync.complete();
		}
	}
	
}
