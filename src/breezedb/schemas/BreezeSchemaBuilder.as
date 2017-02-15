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

package breezedb.schemas
{
	import breezedb.BreezeDb;
	import breezedb.IBreezeDatabase;
	import breezedb.queries.BreezeQueryRunner;

	/**
	 * Class providing API to run table queries on associated database.
	 */
	public class BreezeSchemaBuilder extends BreezeQueryRunner
	{
		public function BreezeSchemaBuilder(db:IBreezeDatabase)
		{
			super(db);
		}
		

		/**
		 * Creates a table with the given name. If the table already exists, the query will fail with an error.
		 *
		 * @param tableName The name of the table to create.
		 * @param blueprint Function that accepts single <code>TableBlueprint</code> parameter. It is used
		 *        to create the table structure:
		 * <listing version="3.0">
		 * function createTableStructure(table:TableBlueprint):void {
		 *     // create table structure
		 *     table.increments("id");
		 *     table.string("name").defaultNull();
		 *     ...
		 * };
		 * </listing>
		 * @param callback <code>Function</code> that is called when the query is completed. If you do not wish
		 *        to execute the SQL query immediately after calling this method, you can pass in
		 *        <code>BreezeDb.DELAY</code> instead. If a <code>Function</code> is specified, it should have
		 *        the following signature:
		 * <listing version="3.0">
		 * function onTableCreated(error:Error):void {
		 *     if(error == null)
		 *     {
		 *         // table created successfully
		 *     }
		 * };
		 * </listing>
		 *
		 * @see breezedb.BreezeDb#DELAY
		 *
		 * @return <code>BreezeQueryRunner</code> object that allows cancelling the query callback or executing
		 *         the query if it was delayed.
		 */
		public function createTable(tableName:String, blueprint:Function, callback:* = null):BreezeQueryRunner
		{
			if(tableName == null)
			{
				throw new ArgumentError("Parameter tableName cannot be null.");
			}

			if(blueprint == null)
			{
				throw new ArgumentError("Parameter blueprint cannot be null.");
			}

			if(!(callback == null || callback is Function || callback === BreezeDb.DELAY))
			{
				throw new ArgumentError("Parameter callback must be a BreezeDb.DELAY constant, Function or null.");
			}

			var bp:TableBlueprint = new TableBlueprint();
			bp.setTable(tableName);
			bp.setOperation(TableBlueprint.CREATE);
			blueprint(bp);

			_queryString = bp.query;

			// Execute the query if we do not want it to be delayed
			if(callback !== BreezeDb.DELAY)
			{
				exec(callback);
			}

			return this;
		}
		
		
		public function editTable(tableName:String, blueprint:Function, callback:* = null):BreezeQueryRunner
		{
			return null;
		}


		public function dropTable(tableName:String, callback:* = null):BreezeQueryRunner
		{
			return null;
		}


		public function dropTableIfExists(tableName:String, callback:* = null):BreezeQueryRunner
		{
			return null;
		}


		public function renameTable(oldTableName:String, newTableName:String, callback:* = null):BreezeQueryRunner
		{
			return null;
		}


		public function hasTable(tableName:String, callback:* = null):BreezeQueryRunner
		{
			return null;
		}


		public function hasColumn(tableName:String, columnName:String, callback:* = null):BreezeQueryRunner
		{
			return null;
		}
		
	}
	
}
