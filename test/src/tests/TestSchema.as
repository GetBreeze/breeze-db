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
	import breezedb.schemas.TableBlueprint;

	import breezetest.Assert;

	import breezetest.async.Async;

	import flash.errors.IllegalOperationError;
	
	public class TestSchema
	{
		
		public var currentAsync:Async;

		private var _db:IBreezeDatabase;


		public function setupClass(async:Async):void
		{
			async.timeout = 2000;

			_db = BreezeDb.getDb("schema-test");
			_db.setup(onDatabaseSetup);
		}


		private function onDatabaseSetup(error:Error):void
		{
			Assert.isNull(error);
			Assert.isTrue(_db.isSetup);

			currentAsync.complete();
		}


		public function testSchema(async:Async):void
		{
			async.timeout = 5000;
			
			Assert.throwsError(function():void
			{
				_db.schema.createTable(null, null);
			}, ArgumentError);

			_db.schema.createTable("photos", function (table:TableBlueprint):void
			{
				table.increments("id");
				table.string("name");
				table.integer("views").defaultTo(0);
				table.timestamp("created_at").defaultTo(0);
				table.index("name");

				// Cannot drop index during table creation
				Assert.throwsError(function():void
				{
					table.dropIndex("views");
				}, IllegalOperationError);
			}, onPhotosTableCreated);
		}


		private function onPhotosTableCreated(error:Error):void
		{
			Assert.isNull(error);

			Assert.throwsError(function():void
			{
				_db.schema.hasTable(null, onPhotosTableCreated);
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				_db.schema.hasTable("", null);
			}, ArgumentError);

			_db.schema.hasTable("photos", hasPhotosTable);
		}


		private function hasPhotosTable(error:Error, hasTable:Boolean):void
		{
			Assert.isNull(error);
			Assert.isTrue(hasTable);

			_db.schema.hasTable("non-existing", hasNonExistingTable);
		}


		private function hasNonExistingTable(error:Error, hasTable:Boolean):void
		{
			Assert.isNotNull(error);
			Assert.isFalse(hasTable);

			checkColumnsExistence();
		}


		private function checkColumnsExistence():void
		{
			Assert.throwsError(function():void
			{
				_db.schema.hasColumn("photos", null, checkColumnsExistence);
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				_db.schema.hasColumn(null, "views", checkColumnsExistence);
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				_db.schema.hasColumn("", "views", null);
			}, ArgumentError);

			_db.schema.hasColumn("photos", "name", hasNameColumn);
		}


		private function hasNameColumn(error:Error, hasColumn:Boolean):void
		{
			Assert.isNull(error);
			Assert.isTrue(hasColumn);

			_db.schema.hasColumn("photos", "views", hasViewsColumn);
		}


		private function hasViewsColumn(error:Error, hasColumn:Boolean):void
		{
			Assert.isNull(error);
			Assert.isTrue(hasColumn);

			_db.schema.hasColumn("photos", "id", hasIdColumn);
		}


		private function hasIdColumn(error:Error, hasColumn:Boolean):void
		{
			Assert.isNull(error);
			Assert.isTrue(hasColumn);

			_db.schema.hasColumn("photos", "non-existing", hasNonExistingColumn);
		}


		private function hasNonExistingColumn(error:Error, hasColumn:Boolean):void
		{
			Assert.isNull(error);
			Assert.isFalse(hasColumn);

			_db.schema.hasColumn("non-existing", "id", hasNonExistingTableAndColumn);
		}


		private function hasNonExistingTableAndColumn(error:Error, hasColumn:Boolean):void
		{
			Assert.isNotNull(error);
			Assert.isFalse(hasColumn);

			testEditTable();
		}


		// private, called after creating the table
		private function testEditTable():void
		{
			Assert.throwsError(function():void
			{
				_db.schema.editTable(null, null);
			}, ArgumentError);

			_db.schema.editTable("photos", function (table:TableBlueprint):void
			{
				Assert.throwsError(function():void
				{
					// cannot edit existing column
					table.integer("name").notNull();
				}, IllegalOperationError);

				table.string("newColumn");
			}, onPhotosTableEdited);
		}


		private function onPhotosTableEdited(error:Error):void
		{
			Assert.isNull(error);

			_db.schema.hasColumn("photos", "newColumn", function(error:Error, hasTable:Boolean):void
			{
				Assert.isNull(error);
				Assert.isTrue(hasTable);

				_db.file.deleteFile();

				currentAsync.complete();
			});
		}


		public function tearDownClass():void
		{
			if(_db.file != null && _db.file.exists)
			{
				_db.file.deleteFile();
				_db = null;
			}
		}
		
	}
	
}
