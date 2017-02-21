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
	import breezedb.schemas.TableBlueprint;

	import breezetest.Assert;
	import breezetest.async.Async;

	public class TestQueryBuilder
	{
		public var currentAsync:Async;

		private var _db:IBreezeDatabase;
		private var _numChunks:int = 0;

		private const _photos:Array = [
			{ title: "Mountains",   views: 35,  downloads: 10,  likes: 4,  creation_date: new Date(2014, 1, 25) },
			{ title: "Flowers",     views: 6,   downloads: 6,   likes: 6,  creation_date: new Date(2015, 3, 3) },
			{ title: "Lake",        views: 35,  downloads: 0,   likes: 0,  creation_date: new Date(2016, 5, 19) },
			{ title: "Camp Fire",   views: 13,  downloads: 13,  likes: 2,  creation_date: new Date(2016, 8, 27) },
			{ title: "Sunset",      views: 24,  downloads: 10,  likes: 10, creation_date: new Date(2015, 11, 11) }
		];
		private const _tableName:String = "photos";


		public function setupClass(async:Async):void
		{
			async.timeout = 2000;

			_db = BreezeDb.getDb("query-builder-test");
			_db.setup(onDatabaseSetup);
		}


		private function onDatabaseSetup(error:Error):void
		{
			Assert.isNull(error);
			Assert.isTrue(_db.isSetup);

			// Create test table
			_db.schema.createTable(_tableName, function(table:TableBlueprint):void
			{
				table.increments("id");
				table.string("title").defaultNull();
				table.integer("views").defaultTo(0);
				table.integer("downloads").defaultTo(0);
				table.integer("likes").defaultTo(0);
				table.date("creation_date");
			}, onTableCreated);
		}


		private function onTableCreated(error:Error):void
		{
			Assert.isNull(error);

			_db.table(_tableName).insert(_photos, onInsertInitialDataCompleted);
		}


		private function onInsertInitialDataCompleted(error:Error):void
		{
			Assert.isNull(error);

			currentAsync.complete();
		}
		
		
		public function testFirst(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).first(onFirstCompleted);
		}


		private function onFirstCompleted(error:Error, first:Object):void
		{
			Assert.isNull(error);
			Assert.isNotNull(first);

			var firstPhoto:Object = _photos[0];
			Assert.equals(1, first.id);
			Assert.equals(firstPhoto.title, first.title);
			Assert.equals(firstPhoto.views, first.views);
			Assert.equals(firstPhoto.downloads, first.downloads);

			currentAsync.complete();
		}
		
		
		public function testCount(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).count(onCountCompleted);
		}


		private function onCountCompleted(error:Error, count:int):void
		{
			Assert.isNull(error);
			Assert.equals(_photos.length, count);

			currentAsync.complete();
		}


		public function testSum(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).sum("views", onSumViewsCompleted);
		}


		private function onSumViewsCompleted(error:Error, sum:Number):void
		{
			Assert.isNull(error);

			var actual:Number = 0;
			for each(var photo:Object in _photos)
			{
				actual += photo.views;
			}

			Assert.equals(actual, sum);

			currentAsync.complete();
		}


		public function testInvalidSum(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).sum("viewz", onInvalidSumCompleted);
		}


		private function onInvalidSumCompleted(error:Error, sum:Number):void
		{
			Assert.isNotNull(error);
			Assert.equals(0, sum);

			currentAsync.complete();
		}


		public function testAvg(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).avg("downloads", onAvgDownloadsCompleted);
		}


		private function onAvgDownloadsCompleted(error:Error, avg:Number):void
		{
			Assert.isNull(error);

			var actual:Number = 0;
			for each(var photo:Object in _photos)
			{
			    actual += photo.downloads;
			}
			actual /= _photos.length;

			Assert.equals(actual, avg);

			currentAsync.complete();
		}


		public function testInvalidAvg(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).avg("downloadz", onInvalidAvgCompleted);
		}


		private function onInvalidAvgCompleted(error:Error, avg:Number):void
		{
			Assert.isNotNull(error);
			Assert.equals(0, avg);

			currentAsync.complete();
		}


		public function testMin(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).min("downloads", onMinDownloadsCompleted);
		}


		private function onMinDownloadsCompleted(error:Error, min:Number):void
		{
			Assert.isNull(error);
			Assert.equals(0, min);

			currentAsync.complete();
		}


		public function testInvalidMin(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).min("downloadz", onInvalidMinCompleted);
		}


		private function onInvalidMinCompleted(error:Error, min:Number):void
		{
			Assert.isNotNull(error);
			Assert.equals(0, min);

			currentAsync.complete();
		}


		public function testMax(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).max("views", onMaxViewsCompleted);
		}


		private function onMaxViewsCompleted(error:Error, max:Number):void
		{
			Assert.isNull(error);
			Assert.equals(35, max);

			currentAsync.complete();
		}


		public function testInvalidMax(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).max("viewz", onInvalidMaxCompleted);
		}


		private function onInvalidMaxCompleted(error:Error, max:Number):void
		{
			Assert.isNotNull(error);
			Assert.equals(0, max);

			currentAsync.complete();
		}


		public function testSelect(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).select("id", "title as name").fetch(onSelectCompleted);
		}


		private function onSelectCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(_photos.length, results.length);

			var index:int = 0;
			for each(var photo:Object in results)
			{
			    Assert.isTrue("id" in photo);
			    Assert.isTrue("name" in photo);

				Assert.equals(index + 1, photo.id);
				Assert.equals(_photos[index].title, photo.name);
			}

			currentAsync.complete();
		}


		public function testInvalidSelect(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).select("idz").fetch(onInvalidSelectCompleted);
		}


		private function onInvalidSelectCompleted(error:Error, results:Collection):void
		{
			Assert.isNotNull(error);
			Assert.isNotNull(results);
			Assert.equals(0, results.length);

			currentAsync.complete();
		}


		public function testDistinct(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).distinct("downloads").fetch(onDistinctCompleted);
		}


		private function onDistinctCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(_photos.length - 1, results.length);
			Assert.arrayEquals([10, 6, 0, 13], results.all);

			currentAsync.complete();
		}


		public function testChunk(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).chunk(1, onChunkCompleted);
		}


		private function onChunkCompleted(error:Error, results:Collection):*
		{
			_numChunks++;

			Assert.isTrue(_numChunks <= 3, "Chunk callback has been called too many times.");

			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo:Object = _photos[_numChunks - 1];
			Assert.equals(_numChunks, results[0].id);
			Assert.equals(photo.title, results[0].title);
			Assert.equals(photo.views, results[0].views);
			Assert.equals(photo.downloads, results[0].downloads);

			if(_numChunks == 3)
			{
				currentAsync.complete();
				return false;
			}
		}


		public function testWhere(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).where("id", 2).fetch(onWhereEqualCompleted);
		}
		
		
		private function onWhereEqualCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[0].id);
			Assert.equals(photo2.title, results[0].title);
			Assert.equals(photo2.views, results[0].views);
			Assert.equals(photo2.downloads, results[0].downloads);

			_db.table(_tableName).where("id", ">", 2).fetch(onWhereGreaterThanCompleted);
		}


		private function onWhereGreaterThanCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(3, results.length);

			var index:int = 2;
			var length:int = results.length;
			for(var i:int = 0; i < length; ++i)
			{
				var photo:Object = _photos[index++];
				Assert.equals(photo.id, results[i].id);
				Assert.equals(photo.title, results[i].title);
				Assert.equals(photo.views, results[i].views);
				Assert.equals(photo.downloads, results[i].downloads);
			}

			_db.table(_tableName).where("id = 2").fetch(onRawWhereCompleted);
		}


		private function onRawWhereCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[0].id);
			Assert.equals(photo2.title, results[0].title);
			Assert.equals(photo2.views, results[0].views);
			Assert.equals(photo2.downloads, results[0].downloads);

			_db.table(_tableName).where("id", ">", 2).where("downloads", ">", 0).fetch(onWhereChainedCompleted);
		}


		private function onWhereChainedCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			// Photo 3 should not be included, it has 0 downloads

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[0].id);
			Assert.equals(photo4.title, results[0].title);
			Assert.equals(photo4.views, results[0].views);
			Assert.equals(photo4.downloads, results[0].downloads);

			var photo5:Object = _photos[4]; // Photo id 5
			Assert.equals(photo5.id, results[1].id);
			Assert.equals(photo5.title, results[1].title);
			Assert.equals(photo5.views, results[1].views);
			Assert.equals(photo5.downloads, results[1].downloads);

			_db.table(_tableName).where([["id", 2], ["title", "=", "Flowers"]]).fetch(onWhereArrayCompleted);
		}


		private function onWhereArrayCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[0].id);
			Assert.equals(photo2.title, results[0].title);
			Assert.equals(photo2.views, results[0].views);
			Assert.equals(photo2.downloads, results[0].downloads);

			currentAsync.complete();
		}


		public function testOrWhere(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).where("id", 2).orWhere("id", 5).fetch(onWhereOrWhereCompleted);
		}


		private function onWhereOrWhereCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[0].id);
			Assert.equals(photo2.title, results[0].title);
			Assert.equals(photo2.views, results[0].views);
			Assert.equals(photo2.downloads, results[0].downloads);

			var photo4:Object = _photos[4]; // Photo id 5
			Assert.equals(photo4.id, results[1].id);
			Assert.equals(photo4.title, results[1].title);
			Assert.equals(photo4.views, results[1].views);
			Assert.equals(photo4.downloads, results[1].downloads);

			currentAsync.complete();
		}
		
		
		public function testWhereBetween(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereBetween("views", 10, 30).fetch(onWhereBetweenCompleted);
		}


		private function onWhereBetweenCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[0].id);
			Assert.equals(photo4.title, results[0].title);
			Assert.equals(photo4.views, results[0].views);
			Assert.equals(photo4.downloads, results[0].downloads);

			var photo5:Object = _photos[4]; // Photo id 5
			Assert.equals(photo5.id, results[1].id);
			Assert.equals(photo5.title, results[1].title);
			Assert.equals(photo5.views, results[1].views);
			Assert.equals(photo5.downloads, results[1].downloads);

			currentAsync.complete();
		}


		public function testWhereNotBetween(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereNotBetween("views", 10, 30).fetch(onWhereNotBetweenCompleted);
		}


		private function onWhereNotBetweenCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(3, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[1].id);
			Assert.equals(photo2.title, results[1].title);
			Assert.equals(photo2.views, results[1].views);
			Assert.equals(photo2.downloads, results[1].downloads);

			var photo3:Object = _photos[2]; // Photo id 3
			Assert.equals(photo3.id, results[2].id);
			Assert.equals(photo3.title, results[2].title);
			Assert.equals(photo3.views, results[2].views);
			Assert.equals(photo3.downloads, results[2].downloads);

			currentAsync.complete();
		}


		public function testWhereIn(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereIn("title", ["Camp Fire", "Sunset"]).fetch(onWhereInCompleted);
		}


		private function onWhereInCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[0].id);
			Assert.equals(photo4.title, results[0].title);
			Assert.equals(photo4.views, results[0].views);
			Assert.equals(photo4.downloads, results[0].downloads);

			var photo5:Object = _photos[4]; // Photo id 5
			Assert.equals(photo5.id, results[1].id);
			Assert.equals(photo5.title, results[1].title);
			Assert.equals(photo5.views, results[1].views);
			Assert.equals(photo5.downloads, results[1].downloads);

			currentAsync.complete();
		}


		public function testWhereNotIn(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereNotIn("title", ["Camp Fire", "Sunset"]).fetch(onWhereNotInCompleted);
		}


		private function onWhereNotInCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[1].id);
			Assert.equals(photo2.title, results[1].title);
			Assert.equals(photo2.views, results[1].views);
			Assert.equals(photo2.downloads, results[1].downloads);

			var photo3:Object = _photos[2]; // Photo id 3
			Assert.equals(photo3.id, results[2].id);
			Assert.equals(photo3.title, results[2].title);
			Assert.equals(photo3.views, results[2].views);
			Assert.equals(photo3.downloads, results[2].downloads);

			currentAsync.complete();
		}


		public function testWhereDate(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereDate("creation_date", new Date(2014, 1, 25)).fetch(onWhereDateEqualsCompleted);
		}


		private function onWhereDateEqualsCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			_db.table(_tableName).whereDate("creation_date", "<", "2015-01-01").fetch(onWhereDateLessThanCompleted);
		}


		private function onWhereDateLessThanCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			currentAsync.complete();
		}


		public function testWhereDay(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereDay("creation_date", 25).fetch(onWhereDayEqualsCompleted);
		}


		private function onWhereDayEqualsCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			_db.table(_tableName).whereDay("creation_date", ">", 24).fetch(onWhereDayGreaterThanCompleted);
		}


		private function onWhereDayGreaterThanCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[1].id);
			Assert.equals(photo4.title, results[1].title);
			Assert.equals(photo4.views, results[1].views);
			Assert.equals(photo4.downloads, results[1].downloads);

			currentAsync.complete();
		}


		public function testWhereMonth(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereMonth("creation_date", 5).fetch(onWhereMonthEqualsCompleted);
		}


		private function onWhereMonthEqualsCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo3:Object = _photos[2]; // Photo id 3
			Assert.equals(photo3.id, results[0].id);
			Assert.equals(photo3.title, results[0].title);
			Assert.equals(photo3.views, results[0].views);
			Assert.equals(photo3.downloads, results[0].downloads);

			_db.table(_tableName).whereMonth("creation_date", ">", 5).fetch(onWhereMonthGreaterThanCompleted);
		}


		private function onWhereMonthGreaterThanCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[0].id);
			Assert.equals(photo4.title, results[0].title);
			Assert.equals(photo4.views, results[0].views);
			Assert.equals(photo4.downloads, results[0].downloads);

			var photo5:Object = _photos[4]; // Photo id 5
			Assert.equals(photo5.id, results[1].id);
			Assert.equals(photo5.title, results[1].title);
			Assert.equals(photo5.views, results[1].views);
			Assert.equals(photo5.downloads, results[1].downloads);

			currentAsync.complete();
		}


		public function testWhereYear(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereYear("creation_date", 2015).fetch(onWhereYearEqualsCompleted);
		}


		private function onWhereYearEqualsCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[0].id);
			Assert.equals(photo2.title, results[0].title);
			Assert.equals(photo2.views, results[0].views);
			Assert.equals(photo2.downloads, results[0].downloads);

			var photo5:Object = _photos[4]; // Photo id 5
			Assert.equals(photo5.id, results[1].id);
			Assert.equals(photo5.title, results[1].title);
			Assert.equals(photo5.views, results[1].views);
			Assert.equals(photo5.downloads, results[1].downloads);

			_db.table(_tableName).whereYear("creation_date", "<", 2015).fetch(onWhereYearLessThanCompleted);
		}


		private function onWhereYearLessThanCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			currentAsync.complete();
		}


		public function testWhereColumn(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).whereColumn("views", "downloads").fetch(onWhereViewsEqualDownloadsCompleted);
		}


		private function onWhereViewsEqualDownloadsCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[0].id);
			Assert.equals(photo2.title, results[0].title);
			Assert.equals(photo2.views, results[0].views);
			Assert.equals(photo2.downloads, results[0].downloads);
			Assert.equals(results[0].views, results[0].downloads);

			var photo5:Object = _photos[4]; // Photo id 5
			Assert.equals(photo5.id, results[1].id);
			Assert.equals(photo5.title, results[1].title);
			Assert.equals(photo5.views, results[1].views);
			Assert.equals(photo5.downloads, results[1].downloads);
			Assert.equals(results[1].views, results[1].downloads);

			_db.table(_tableName).whereColumn("likes", "<", "downloads").fetch(onWhereLikesLessThanDownloadsCompleted);
		}


		private function onWhereLikesLessThanDownloadsCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);
			Assert.isTrue(results[0].likes < results[0].downloads);

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[1].id);
			Assert.equals(photo4.title, results[1].title);
			Assert.equals(photo4.views, results[1].views);
			Assert.equals(photo4.downloads, results[1].downloads);
			Assert.isTrue(results[1].likes < results[1].downloads);

			_db.table(_tableName).whereColumn([["views", "downloads"], ["likes", "<", "downloads"]]).fetch(onWhereViewsEqualDownloadsAndLikesLessThanDownloadsCompleted);
		}


		private function onWhereViewsEqualDownloadsAndLikesLessThanDownloadsCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[0].id);
			Assert.equals(photo4.title, results[0].title);
			Assert.equals(photo4.views, results[0].views);
			Assert.equals(photo4.downloads, results[0].downloads);
			Assert.equals(results[0].views, results[0].downloads);
			Assert.isTrue(results[0].likes < results[0].downloads);

			currentAsync.complete();
		}


		public function testOrderBy(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).orderBy("views", "ASC", "downloads", "ASC").fetch(onOrderByViewsDownloadsAscCompleted);
		}


		private function onOrderByViewsDownloadsAscCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(_photos.length, results.length);

			Assert.equals(_photos[0].views, results[4].views);
			Assert.equals(_photos[0].downloads, results[4].downloads);

			Assert.equals(_photos[1].views, results[0].views);
			Assert.equals(_photos[1].downloads, results[0].downloads);

			Assert.equals(_photos[2].views, results[3].views);
			Assert.equals(_photos[2].downloads, results[3].downloads);

			Assert.equals(_photos[3].views, results[1].views);
			Assert.equals(_photos[3].downloads, results[1].downloads);

			Assert.equals(_photos[4].views, results[2].views);
			Assert.equals(_photos[4].downloads, results[2].downloads);

			_db.table(_tableName).orderBy("views", "ASC", "downloads", "DESC").fetch(onOrderByViewsDownloadsDescCompleted);
		}


		private function onOrderByViewsDownloadsDescCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(_photos.length, results.length);

			Assert.equals(_photos[0].views, results[3].views);
			Assert.equals(_photos[0].downloads, results[3].downloads);

			Assert.equals(_photos[1].views, results[0].views);
			Assert.equals(_photos[1].downloads, results[0].downloads);

			Assert.equals(_photos[2].views, results[4].views);
			Assert.equals(_photos[2].downloads, results[4].downloads);

			Assert.equals(_photos[3].views, results[1].views);
			Assert.equals(_photos[3].downloads, results[1].downloads);

			Assert.equals(_photos[4].views, results[2].views);
			Assert.equals(_photos[4].downloads, results[2].downloads);

			currentAsync.complete();
		}


		public function testGroupBy(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName)
					.select("SUM(views) as total_views, strftime(%Y, creation_date) as year_created")
					.groupBy("year_created")
					.orderBy("total_views", "ASC")
					.fetch(onGroupByCompleted);
		}


		private function onGroupByCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(3, results.length);

			Assert.equals(30, results[0].total_views);
			Assert.equals(2015, results[0].year_created);

			Assert.equals(35, results[1].total_views);
			Assert.equals(2014, results[1].year_created);

			Assert.equals(48, results[2].total_views);
			Assert.equals(2016, results[2].year_created);

			currentAsync.complete();
		}


		public function testHaving(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName)
					.select("SUM(views) as total_views, strftime(%Y, creation_date) as year_created")
					.groupBy("year_created")
					.orderBy("total_views", "ASC")
					.having("year_created", ">", 2015)
					.fetch(onHavingCompleted);
		}


		private function onHavingCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			Assert.equals(30, results[0].total_views);
			Assert.equals(2015, results[0].year_created);

			currentAsync.complete();
		}


		public function testLimit(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).limit(2).fetch(onLimitCompleted);
		}


		private function onLimitCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo1:Object = _photos[0]; // Photo id 1
			Assert.equals(photo1.id, results[0].id);
			Assert.equals(photo1.title, results[0].title);
			Assert.equals(photo1.views, results[0].views);
			Assert.equals(photo1.downloads, results[0].downloads);

			var photo2:Object = _photos[1]; // Photo id 2
			Assert.equals(photo2.id, results[1].id);
			Assert.equals(photo2.title, results[1].title);
			Assert.equals(photo2.views, results[1].views);
			Assert.equals(photo2.downloads, results[1].downloads);

			currentAsync.complete();
		}


		public function testOffset(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).limit(2).offset(2).fetch(onOffsetCompleted);
		}


		private function onOffsetCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			var photo3:Object = _photos[2]; // Photo id 3
			Assert.equals(photo3.id, results[0].id);
			Assert.equals(photo3.title, results[0].title);
			Assert.equals(photo3.views, results[0].views);
			Assert.equals(photo3.downloads, results[0].downloads);

			var photo4:Object = _photos[3]; // Photo id 4
			Assert.equals(photo4.id, results[1].id);
			Assert.equals(photo4.title, results[1].title);
			Assert.equals(photo4.views, results[1].views);
			Assert.equals(photo4.downloads, results[1].downloads);

			currentAsync.complete();
		}


		public function testInsertAndRemove(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName).insert({ id: 6, title: "Morning Dew", views: 3, downloads: 0, likes: 0, creation_date: new Date() }, onSingleInsertCompleted);
		}


		private function onSingleInsertCompleted(error:Error):void
		{
			Assert.isNull(error);

			// Check the item has been inserted
			_db.table(_tableName).select("id", "title").where("id", 6).fetch(onSingleInsertCheckCompleted);
		}


		private function onSingleInsertCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);

			Assert.equals(6, results[0].id);
			Assert.equals("Morning Dew", results[0].title);

			_db.table(_tableName).where("id", 6).remove(onSingleRemoveCompleted);
		}
		
		
		private function onSingleRemoveCompleted(error:Error, deleted:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, deleted);

			_db.table(_tableName).insert([
				{ id: 7, title: "Morning Dew", views: 3, downloads: 0, likes: 0, creation_date: new Date() },
				{ id: 8, title: "Night Sky", views: 10, downloads: 5, likes: 2, creation_date: new Date() },
			], onMultiInsertCompleted);
		}


		private function onMultiInsertCompleted(error:Error):void
		{
			Assert.isNull(error);

			// Check the two items have been inserted
			_db.table(_tableName)
					.select("id", "title")
					.where("id", 7)
					.orWhere("id", 8)
					.fetch(onMultiInsertCheckCompleted);
		}


		private function onMultiInsertCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			Assert.equals(7, results[0].id);
			Assert.equals("Morning Dew", results[0].title);

			Assert.equals(8, results[1].id);
			Assert.equals("Night Sky", results[1].title);

			_db.table(_tableName)
					.where("id", 7)
					.orWhere("id", 8)
					.remove(onMultiRemoveCompleted);
		}


		private function onMultiRemoveCompleted(error:Error, deleted:int):void
		{
			Assert.isNull(error);
			Assert.equals(2, deleted);

			// Insert and get id
			_db.table(_tableName)
					.insertGetId({ title: "Night Sky", views: 10, downloads: 5, likes: 2, creation_date: new Date() },
					onInsertGetIdCompleted);
		}


		private function onInsertGetIdCompleted(error:Error, newId:int):void
		{
			Assert.isNull(error);
			Assert.equals(9, newId);

			currentAsync.complete();
		}


		public function testUpdate(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName)
					.where("id", 1)
					.update({ title: "Hills" }, onUpdateCompleted);
		}


		private function onUpdateCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			// Check that the title has been updated
			_db.table(_tableName)
					.select("id", "title")
					.where("id", 1)
					.fetch(onUpdateCheckCompleted);
		}


		private function onUpdateCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNull(results);
			Assert.equals(1, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals("Hills", results[0].title);

			// Change back to "Mountains"
			_db.table(_tableName)
					.where("id", 1)
					.update({ title: "Mountains" }, onRollBackUpdateCompleted);
		}


		private function onRollBackUpdateCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			currentAsync.complete();
		}


		public function testIncAndDec(async:Async):void
		{
			async.timeout = 2000;

			_db.table(_tableName)
					.where("id", 1)
					.increment("views", onSimpleIncrementCompleted);
		}


		private function onSimpleIncrementCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			// Check that the views count has been incremented by 1
			_db.table(_tableName)
					.select("id", "views")
					.where("id", 1)
					.fetch(onSimpleIncrementCheckCompleted);
		}


		private function onSimpleIncrementCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNull(results);
			Assert.equals(1, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals(_photos[0].views + 1, results[0].views);

			_db.table(_tableName)
					.where("id", 1)
					.increment("views", 4, onSpecificIncrementCompleted);
		}


		private function onSpecificIncrementCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			// Check that the views count has been further incremented by 4
			_db.table(_tableName)
					.select("id", "views")
					.where("id", 1)
					.fetch(onSpecificIncrementCheckCompleted);
		}


		private function onSpecificIncrementCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNull(results);
			Assert.equals(1, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals(_photos[0].views + 5, results[0].views);

			_db.table(_tableName)
					.where("id", 1)
					.increment("views", { title: "Mount Everest" }, onIncrementAndUpdateCompleted);
		}


		private function onIncrementAndUpdateCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			// Check that the views count has been further incremented by 1 and the title has been updated
			_db.table(_tableName)
					.select("id", "title", "views")
					.where("id", 1)
					.fetch(onIncrementAndUpdateCheckCompleted);
		}


		private function onIncrementAndUpdateCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNull(results);
			Assert.equals(1, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals(_photos[0].views + 6, results[0].views);
			Assert.equals("Mount Everest", results[0].title);

			// Continue with decrement
			_db.table(_tableName)
					.where("id", 1)
					.decrement("views", onSimpleDecrementCompleted);
		}


		private function onSimpleDecrementCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			// Check that the views count has been decremented by 1
			_db.table(_tableName)
					.select("id", "views")
					.where("id", 1)
					.fetch(onSimpleDecrementCheckCompleted);
		}


		private function onSimpleDecrementCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNull(results);
			Assert.equals(1, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals(_photos[0].views + 5, results[0].views);

			_db.table(_tableName)
					.where("id", 1)
					.decrement("views", 4, onSpecificDecrementCompleted);
		}


		private function onSpecificDecrementCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			// Check that the views count has been further decremented by 4
			_db.table(_tableName)
					.select("id", "views")
					.where("id", 1)
					.fetch(onSpecificDecrementCheckCompleted);
		}


		private function onSpecificDecrementCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNull(results);
			Assert.equals(1, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals(_photos[0].views + 1, results[0].views);

			_db.table(_tableName)
					.where("id", 1)
					.decrement("views", { title: "Mountains" }, onDecrementAndUpdateCompleted);
		}


		private function onDecrementAndUpdateCompleted(error:Error, affectedRows:int):void
		{
			Assert.isNull(error);
			Assert.equals(1, affectedRows);

			// Check that the views count has been further decremented by 1 and the title has been updated
			_db.table(_tableName)
					.select("id", "title", "views")
					.where("id", 1)
					.fetch(onDecrementAndUpdateCheckCompleted);
		}


		private function onDecrementAndUpdateCheckCompleted(error:Error, results:Collection):void
		{
			Assert.isNull(error);
			Assert.isNull(results);
			Assert.equals(1, results.length);

			Assert.equals(1, results[0].id);
			Assert.equals(_photos[0].views, results[0].views);
			Assert.equals(_photos[0].title, results[0].title);

			currentAsync.complete();
		}


		public function tearDownClass():void
		{
			if(_db != null && _db.file != null)
			{
				_db.file.deleteFile();
			}
		}
		
	}
	
}
