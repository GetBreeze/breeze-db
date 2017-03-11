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

package tests.models
{
	import breezedb.BreezeDb;
	import breezedb.IBreezeDatabase;
	import breezedb.collections.Collection;
	import breezedb.models.BreezeModel;
	import breezedb.schemas.TableBlueprint;

	import breezetest.Assert;
	import breezetest.async.Async;
	
	public class TestModel
	{
		// Used by custom models
		public static const DB_NAME:String = "test-model";
		
		public var currentAsync:Async;

		private var _db:IBreezeDatabase;

		private const _photos:Array = [
			{ title: "Mountains",   views: 35,  downloads: 10,  creation_date: new Date(2014, 1, 25) },
			{ title: "Flowers",     views: 6,   downloads: 6,   creation_date: new Date(2015, 3, 3) },
			{ title: "Lake",        views: 35,  downloads: 0,   creation_date: new Date(2016, 5, 19) },
			{ title: "Camp Fire",   views: 13,  downloads: 13,  creation_date: new Date(2016, 8, 27) }
		];
		private const _photosTable:String = "photo";


		public function setupClass(async:Async):void
		{
			async.timeout = 3000;

			_db = BreezeDb.getDb(DB_NAME);
			_db.setup(onDatabaseSetup);
		}


		private function onDatabaseSetup(error:Error):void
		{
			Assert.isNull(error);
			Assert.isTrue(_db.isSetup);

			_db.schema.createTable(_photosTable, function (table:TableBlueprint):void
			{
				table.increments("id");
				table.string("title").defaultNull();
				table.integer("views").defaultTo(0);
				table.integer("downloads").defaultTo(0);
				table.date("creation_date").defaultNull();
			}, onTableCreated);
		}


		private function onTableCreated(error:Error):void
		{
			Assert.isNull(error);

			// Insert photos
			_db.table(_photosTable).insert(_photos, onPhotosInserted);
		}


		private function onPhotosInserted(error:Error):void
		{
			Assert.isNull(error);

			currentAsync.complete();
		}
		
		
		public function testTableName():void
		{
			var photo:Photo = new Photo();
			Assert.equals("photo", photo.tableName);

			var photoAlbum:PhotoAlbum = new PhotoAlbum();
			Assert.equals("photo_album", photoAlbum.tableName);

			var customTable:CustomTableModel = new CustomTableModel();
			Assert.equals("custom_table_name", customTable.tableName);
		}


		public function testSave(async:Async):void
		{
			async.timeout = 3000;

			// Save new photo
			var photo:Photo = new Photo();
			photo.id = 6;
			photo.title = "Hills";
			photo.views = 7;
			photo.downloads = 3;
			photo.creation_date = new Date(2016, 7, 7);
			photo.save(onNewPhotoSaved)
		}
		
		
		private function onNewPhotoSaved(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);
			Assert.equals(6, photo.id);
			Assert.equals("Hills", photo.title);
			Assert.equals(7, photo.views);
			Assert.equals(3, photo.downloads);
			Assert.isNotNull(photo.creation_date);
			Assert.equals(2016, photo.creation_date.fullYear);
			Assert.equals(7, photo.creation_date.month);
			Assert.equals(7, photo.creation_date.date);

			// Update the photo via save
			photo.title = "Great Smoky Mountains";
			photo.views = 13;
			photo.downloads = 10;
			photo.save(onPhotoUpdated);
		}


		private function onPhotoUpdated(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);
			Assert.equals(6, photo.id);
			Assert.equals("Great Smoky Mountains", photo.title);
			Assert.equals(13, photo.views);
			Assert.equals(10, photo.downloads);
			Assert.isNotNull(photo.creation_date);
			Assert.equals(2016, photo.creation_date.fullYear);
			Assert.equals(7, photo.creation_date.month);
			Assert.equals(7, photo.creation_date.date);

			currentAsync.complete();
		}


		public function testFirstAndRemove(async:Async):void
		{
			async.timeout = 3000;

			BreezeModel.query(Photo).first(onFirstPhotoRetrieved);
		}
		
		
		private function onFirstPhotoRetrieved(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);
			
			Assert.equals(1, photo.id);
			Assert.equals("Mountains", photo.title);
			Assert.equals(35, photo.views);
			Assert.equals(10, photo.downloads);

			photo.remove(onFirstPhotoDeleted);
		}


		private function onFirstPhotoDeleted(error:Error):void
		{
			Assert.isNull(error);

			BreezeModel.query(Photo).where("id", 1).fetch(onPhotoDeleteCheckCompleted);
		}


		private function onPhotoDeleteCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(0, results.length);

			currentAsync.complete();
		}
		
		
		public function testFirstOrNew(async:Async):void
		{
			async.timeout = 3000;
			
			BreezeModel.query(Photo).firstOrNew({ id: 5, title: "Sunrise" }, onFirstOrNewCompleted);
		}


		private function onFirstOrNewCompleted(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);

			Assert.equals(5, photo.id);
			Assert.equals("Sunrise", photo.title);
			Assert.equals(0, photo.views);
			Assert.equals(0, photo.downloads);
			Assert.isFalse(photo.exists);

			// Check that the photo is not in the database
			BreezeModel.query(Photo).where("id", 5).fetch(onFirstOrNewCheckCompleted);
		}


		private function onFirstOrNewCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(0, results.length);

			BreezeModel.query(Photo).firstOrNew({ title: "Sunrise" }, onFirstOrNewWithoutIdCompleted);
		}


		private function onFirstOrNewWithoutIdCompleted(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);

			// The photo should have auto-incremented id, non-zero
			Assert.isTrue(photo.id != 0);
			Assert.equals("Sunrise", photo.title);
			Assert.equals(0, photo.views);
			Assert.equals(0, photo.downloads);
			Assert.isFalse(photo.exists);

			// Check that the photo is not in the database
			BreezeModel.query(Photo).where("id", photo.id).fetch(onFirstOrNewWithoutIdCheckCompleted);
		}


		private function onFirstOrNewWithoutIdCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(0, results.length);

			currentAsync.complete();
		}


		public function testFirstOrCreate(async:Async):void
		{
			async.timeout = 3000;

			BreezeModel.query(Photo).firstOrCreate({ id: 20, title: "Sunset", views: 10 }, onFirstOrCreateCompleted);
		}


		private function onFirstOrCreateCompleted(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);

			Assert.equals(20, photo.id);
			Assert.equals("Sunset", photo.title);
			Assert.equals(10, photo.views);
			Assert.equals(0, photo.downloads);
			Assert.isTrue(photo.exists);

			// Check that the photo is in the database
			BreezeModel.query(Photo).where("id", 20).fetch(onFirstOrCreateCheckCompleted);
		}


		private function onFirstOrCreateCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			Assert.isType(results[0], Photo);

			var photo:Photo = results[0] as Photo;

			Assert.equals(20, photo.id);
			Assert.equals("Sunset", photo.title);
			Assert.equals(10, photo.views);
			Assert.equals(0, photo.downloads);

			// Save new photo without specifying the id (it must auto-increment)
			BreezeModel.query(Photo).firstOrCreate({ title: "Cloudy Sky" }, onFirstOrCreateWithoutIdCompleted);
		}


		private function onFirstOrCreateWithoutIdCompleted(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);

			Assert.equals(21, photo.id);
			Assert.equals("Cloudy Sky", photo.title);
			Assert.isTrue(photo.exists);

			// Check that the photo is in the database
			BreezeModel.query(Photo).where("id", 21).fetch(onFirstOrCreateWithoutIdCheckCompleted);
		}


		private function onFirstOrCreateWithoutIdCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			Assert.isType(results[0], Photo);

			var photo:Photo = results[0] as Photo;

			Assert.equals(21, photo.id);
			Assert.equals("Cloudy Sky", photo.title);
			Assert.equals(0, photo.views);
			Assert.equals(0, photo.downloads);

			currentAsync.complete();
		}


		public function testFindAndRemoveByKey(async:Async):void
		{
			async.timeout = 3000;
			
			// Check that all photos that are about to be removed are in the database
			BreezeModel.query(Photo).find(2, onFindSinglePhotoCompleted);
		}


		private function onFindSinglePhotoCompleted(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNotNull(photo);

			Assert.equals(2, photo.id);
			Assert.equals("Flowers", photo.title);
			Assert.equals(6, photo.views);
			Assert.equals(6, photo.downloads);

			BreezeModel.query(Photo).find([3, 4], onFindMultiplePhotosCompleted);
		}


		private function onFindMultiplePhotosCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var length:int = results.length;
			for(var i:int = 0; i < length; ++i)
			{
				Assert.isType(results[i], Photo);
				Assert.equals(i + 3, Photo(results[i]).id);
			}

			// Remove photo with id of 2
			BreezeModel.query(Photo).removeByKey(2, onPhoto2Removed);
		}


		private function onPhoto2Removed(error:Error):void
		{
			Assert.isNull(error);

			// Check the photo with id of 2 was removed
			BreezeModel.query(Photo).find(2, onPhoto2RemoveCheckCompleted);
		}


		private function onPhoto2RemoveCheckCompleted(error:Error, photo:Photo):void
		{
			Assert.isNull(error);
			Assert.isNull(photo);

			// Remove photos with id of 3 and 4
			BreezeModel.query(Photo).removeByKey([3, 4], onPhoto3And4Removed);
		}


		private function onPhoto3And4Removed(error:Error):void
		{
			Assert.isNull(error);

			// Check the photos with id of 2 and 3 were removed
			BreezeModel.query(Photo).find([2, 3], onPhoto2And3RemoveCheckCompleted);
		}


		private function onPhoto2And3RemoveCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(0, results.length);

			currentAsync.complete();
		}


		public function tearDownClass():void
		{
			if(_db != null && _db.file != null && _db.file.exists)
			{
				_db.file.deleteFile();
			}
		}
		
	}
	
}
