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
	import breezedb.queries.BreezeQueryReference;
	import breezedb.queries.BreezeQueryRunner;
	import breezedb.queries.BreezeRawQuery;
	
	/**
	 * Class providing API to run table queries on associated database.
	 */
	public class BreezeSchemaBuilder extends BreezeQueryRunner
	{
		/**
		 * Creates a schema builder and associates it with the given database.
		 *
		 * @param db The database to associate the builder with.
		 */
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
		 * @see breezedb.schemas.TableBlueprint
		 *
		 * @return <code>BreezeQueryRunner</code> object that allows cancelling the query callback or executing
		 *         the query if it was delayed.
		 */
		public function createTable(tableName:String, blueprint:Function, callback:* = null):BreezeQueryRunner
		{
			return makeTableQuery(TableBlueprint.CREATE, tableName, blueprint, callback);
		}
		

		/**
		 * Edits a table with the given name. If the table does not exist, the query will fail with an error.
		 *
		 * @param tableName The name of the table to edit.
		 * @param blueprint Function that accepts single <code>TableBlueprint</code> parameter. It is used
		 *        to edit the table structure. Note existing columns <strong>cannot</strong> be edited,
		 *        only new ones can be added.
		 * <listing version="3.0">
		 * function editTableStructure(table:TableBlueprint):void {
		 *     // add new column
		 *     table.string("name").defaultNull();
		 *     ...
		 * };
		 * </listing>
		 * @param callback <code>Function</code> that is called when the query is completed. If you do not wish
		 *        to execute the SQL query immediately after calling this method, you can pass in
		 *        <code>BreezeDb.DELAY</code> instead. If a <code>Function</code> is specified, it should have
		 *        the following signature:
		 * <listing version="3.0">
		 * function onTableEdited(error:Error):void {
		 *     if(error == null)
		 *     {
		 *         // table edited successfully
		 *     }
		 * };
		 * </listing>
		 *
		 * @see breezedb.BreezeDb#DELAY
		 * @see breezedb.schemas.TableBlueprint
		 *
		 * @return <code>BreezeQueryRunner</code> object that allows cancelling the query callback or executing
		 *         the query if it was delayed.
		 */
		public function editTable(tableName:String, blueprint:Function, callback:* = null):BreezeQueryRunner
		{
			return makeTableQuery(TableBlueprint.ALTER, tableName, blueprint, callback);
		}


		/**
		 * Drops a table with the given name. If the table does not exist, the query will fail with an error.
		 *
		 * @param tableName Name of the table to drop.
		 * @param callback <code>Function</code> that is called when the query is completed. If you do not wish
		 *        to execute the SQL query immediately after calling this method, you can pass in
		 *        <code>BreezeDb.DELAY</code> instead. If a <code>Function</code> is specified, it should have
		 *        the following signature:
		 * <listing version="3.0">
		 * function onTableDropped(error:Error):void {
		 *     if(error == null)
		 *     {
		 *         // table dropped successfully
		 *     }
		 * };
		 * </listing>
		 *
		 * @see breezedb.BreezeDb#DELAY
		 * @see #dropTableIfExists()
		 *
		 * @return <code>BreezeQueryRunner</code> object that allows cancelling the query callback or executing
		 *         the query if it was delayed.
		 */
		public function dropTable(tableName:String, callback:* = null):BreezeQueryRunner
		{
			return dropTableInternal(tableName, callback);
		}


		/**
		 * Drops a table with the given name. If the table does not exist, the query will not fail with an error.
		 *
		 * @param tableName Name of the table to drop.
		 * @param callback <code>Function</code> that is called when the query is completed. If you do not wish
		 *        to execute the SQL query immediately after calling this method, you can pass in
		 *        <code>BreezeDb.DELAY</code> instead. If a <code>Function</code> is specified, it should have
		 *        the following signature:
		 * <listing version="3.0">
		 * function onTableDropped(error:Error):void {
		 *     if(error == null)
		 *     {
		 *         // table may or may have not been dropped successfully
		 *     }
		 * };
		 * </listing>
		 *
		 * @see breezedb.BreezeDb#DELAY
		 * @see #dropTable()
		 *
		 * @return <code>BreezeQueryRunner</code> object that allows cancelling the query callback or executing
		 *         the query if it was delayed.
		 */
		public function dropTableIfExists(tableName:String, callback:* = null):BreezeQueryRunner
		{
			return dropTableInternal(tableName, callback, true);
		}


		/**
		 * Renames a table with the given name. If the table does not exist, the query will fail with an error.
		 *
		 * @param oldTableName Name of the existing table that should be renamed.
		 * @param newTableName New table name.
		 * @param callback <code>Function</code> that is called when the query is completed. If you do not wish
		 *        to execute the SQL query immediately after calling this method, you can pass in
		 *        <code>BreezeDb.DELAY</code> instead. If a <code>Function</code> is specified, it should have
		 *        the following signature:
		 * <listing version="3.0">
		 * function onTableRenamed(error:Error):void {
		 *     if(error == null)
		 *     {
		 *         // table renamed successfully
		 *     }
		 * };
		 * </listing>
		 *
		 * @see breezedb.BreezeDb#DELAY
		 *
		 * @return <code>BreezeQueryRunner</code> object that allows cancelling the query callback or executing
		 *         the query if it was delayed.
		 */
		public function renameTable(oldTableName:String, newTableName:String, callback:* = null):BreezeQueryRunner
		{
			if(oldTableName == null)
			{
				throw new ArgumentError("Parameter oldTableName cannot be null.");
			}

			if(newTableName == null)
			{
				throw new ArgumentError("Parameter newTableName cannot be null.");
			}

			if(oldTableName.indexOf(";") >= 0)
			{
				throw new ArgumentError("Parameter oldTableName cannot contain semicolon.");
			}

			if(newTableName.indexOf(";") >= 0)
			{
				throw new ArgumentError("Parameter newTableName cannot contain semicolon.");
			}

			if(!(callback == null || callback is Function || callback === BreezeDb.DELAY))
			{
				throw new ArgumentError("Parameter callback must be a BreezeDb.DELAY constant, Function or null.");
			}

			_queryString = "ALTER TABLE [" + oldTableName + "] RENAME TO [" + newTableName + "];";

			// Execute the query if we do not want it to be delayed
			if(callback !== BreezeDb.DELAY)
			{
				exec(callback);
			}

			return this;
		}


		/**
		 * Loads the table schema to see if a table with the given name exists.
		 *
		 * @param tableName The name of the table to check for existence.
		 * @param callback Function with the following signature:
		 * <listing version="3.0">
		 * function callback(error:Error, hasTable:Boolean):void {
		 *     if(error == null)
		 *     {
		 *         trace(hasTable);
		 *     }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public function hasTable(tableName:String, callback:Function):BreezeQueryReference
		{
			if(tableName == null)
			{
				throw new ArgumentError("Parameter tableName cannot be null.");
			}

			if(callback == null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			_queryString = "";
			_queryReference = new BreezeRawQuery(_db).breezedb_internal::loadTableSchema(tableName, callback);
			return _queryReference;
		}


		/**
		 * Loads the table schema to see if a column with the given name exists in a table with the given name.
		 *
		 * @param tableName The name of the table where to look for the column.
		 * @param columnName The name of the column to check for existence.
		 * @param callback Function with the following signature:
		 * <listing version="3.0">
		 * function callback(error:Error, hasColumn:Boolean):void {
		 *     if(error == null)
		 *     {
		 *         trace(hasColumn);
		 *     }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public function hasColumn(tableName:String, columnName:String, callback:Function):BreezeQueryReference
		{
			if(tableName == null)
			{
				throw new ArgumentError("Parameter tableName cannot be null.");
			}

			if(columnName == null)
			{
				throw new ArgumentError("Parameter columnName cannot be null.");
			}

			if(callback == null)
			{
				throw new ArgumentError("Parameter callback cannot be null.");
			}

			_queryString = "";
			_queryReference = new BreezeRawQuery(_db).breezedb_internal::loadColumnSchema(tableName, columnName, callback);
			return _queryReference;
		}


		/**
		 *
		 *
		 * Private API
		 *
		 *
		 */


		private function makeTableQuery(statement:int, tableName:String, blueprint:Function, callback:* = null):BreezeQueryRunner
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
			bp.setStatement(statement);
			blueprint(bp);

			_queryString = bp.query;

			// Execute the query if we do not want it to be delayed
			if(callback !== BreezeDb.DELAY)
			{
				exec(callback);
			}

			return this;
		}


		private function dropTableInternal(tableName:String, callback:*, ifExists:Boolean = false):BreezeQueryRunner
		{
			if(tableName == null)
			{
				throw new ArgumentError("Parameter tableName cannot be null.");
			}

			if(tableName.indexOf(";") >= 0)
			{
				throw new ArgumentError("Parameter tableName cannot contain semicolon.");
			}

			if(!(callback == null || callback is Function || callback === BreezeDb.DELAY))
			{
				throw new ArgumentError("Parameter callback must be a BreezeDb.DELAY constant, Function or null.");
			}

			_queryString = "DROP TABLE " + (ifExists ? "IF EXISTS " : "") + "[" + tableName + "];";

			// Execute the query if we do not want it to be delayed
			if(callback !== BreezeDb.DELAY)
			{
				exec(callback);
			}

			return this;
		}
		
	}
	
}
