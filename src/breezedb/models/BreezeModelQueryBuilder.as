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

package breezedb.models
{
	import breezedb.BreezeDb;
	import breezedb.IBreezeDatabase;
	import breezedb.queries.BreezeQueryBuilder;
	import breezedb.queries.BreezeQueryReference;

	/**
	 * Class providing API to run queries on a table associated with the given model.
	 */
	public class BreezeModelQueryBuilder extends BreezeQueryBuilder
	{

		/**
		 * Creates a new builder and associates it with a table of the given model.
		 *
		 * @param modelClass The model used to obtain database and table against which the queries will be executed.
		 */
		public function BreezeModelQueryBuilder(modelClass:Class)
		{
			var model:BreezeModel = new modelClass();
			var db:IBreezeDatabase = BreezeDb.getDb(model.databaseName);
			super(db, model.tableName);
		}


		public function find(ids:*, callback:* = null):BreezeQueryReference
		{
			throw new Error("Not implemented");
		}


		public function firstOrNew(values:Object, callback:* = null):BreezeQueryReference
		{
			throw new Error("Not implemented");
		}


		public function firstOrCreate(values:Object, callback:* = null):BreezeQueryReference
		{
			throw new Error("Not implemented");
		}


		public function removeByKey(primaryKeys:*, callback:* = null):BreezeQueryReference
		{
			throw new Error("Not implemented");
		}
		
	}
	
}
