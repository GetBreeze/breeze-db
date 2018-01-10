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
	import breezedb.queries.BreezeQueryResult;
	import breezedb.schemas.TableBlueprint;

	import breezetest.Assert;
	import breezetest.async.Async;

	import flash.errors.SQLError;
	import flash.utils.setTimeout;

	public class TestQueryQueue
	{
		public var currentAsync:Async;

		private var _db:IBreezeDatabase;
		private var _completedQueries:String;

		private const _photo:Object = { title: "Mountains",   views: 35,  downloads: 10 };
		private const _tableName:String = "photos";


		public function setupClass(async:Async):void
		{
			async.timeout = 2000;

			BreezeDb.isQueryQueueEnabled = true;

			_completedQueries = "";

			_db = BreezeDb.getDb("query-queue-test");
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
			}, onTableCreated);
		}


		private function onTableCreated(error:Error):void
		{
			Assert.isNull(error);

			currentAsync.complete();
		}


		public function testQueue(async:Async):void
		{
			async.timeout = 5000;

			// Multi insert
			var photos:Array = [];
			var numPhotos:int = 200;
			for(var i:int = 0; i < numPhotos; ++i)
			{
				photos[i] = _photo;
			}
			_db.table(_tableName).insert(photos, onInsertCompleted);

			// Multi query in transaction
			_db.multiQueryTransaction([
				"UPDATE " + _tableName + " SET title = :title WHERE id = :id",
				"SELECT id, title FROM " + _tableName + " WHERE title = 'Hills'"
			], [{ title: "Hills", id: 1 }], onMultiQueryCompleted);

			// Faulty query, must not cause roll back on previous transaction query
			_db.query("DROP TABLEz " + _tableName, onFaultyQueryCompleted); // forced error

			// Delayed query must not be added to the queue
			_db.table(_tableName).where("id", 1).remove(BreezeDb.DELAY);

			// Cancelled query must not block the queue
			_db.table(_tableName).where("id", 1).fetch().queryReference.cancel();

			// Check query
			_db.select("SELECT id, title FROM " + _tableName + " WHERE id = :id", { id: 1 }, onCheckMultiQueryCompleted);
		}


		private function onInsertCompleted(error:Error):void
		{
			Assert.isNull(error);

			_completedQueries += "insert-";
		}


		private function onMultiQueryCompleted(error:Error, results:Vector.<BreezeQueryResult>):void
		{
			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(2, results.length);

			_completedQueries += "multiQ1-";

			// UPDATE result
			var result:BreezeQueryResult = results[0];
			Assert.isNull(result.error);
			Assert.isNotNull(result);
			Assert.equals(1, result.rowsAffected);

			// SELECT result
			result = results[1];
			Assert.isNull(result.error);
			Assert.isNotNull(result);
			Assert.isNotNull(result.data);
			Assert.equals(1, result.data.length);
		}


		private function onFaultyQueryCompleted(error:Error):void
		{
			Assert.isNotNull(error);
			Assert.isType(error, SQLError);

			_completedQueries += "multiQ2-";
		}


		private function onCheckMultiQueryCompleted(error:Error, results:Collection):void
		{
			_completedQueries += "check";

			Assert.isNull(error);
			Assert.isNotNull(results);
			Assert.equals(1, results.length);
			Assert.equals(1, results[0].id);
			Assert.equals("Hills", results[0].title);
			Assert.equals("insert-multiQ1-multiQ2-check", _completedQueries);

			currentAsync.complete();
		}


        public function tearDownClass(async:Async):void
        {
            if(_db != null && _db.isSetup)
            {
                setTimeout(_db.close, 500, onDatabaseClosed);
            }
        }


        private function onDatabaseClosed(error:Error):void
        {
            Assert.isNull(error);

            if(_db.file != null && _db.file.exists)
            {
                _db.file.deleteFile();
            }

            currentAsync.complete();
        }
		
	}
	
}
