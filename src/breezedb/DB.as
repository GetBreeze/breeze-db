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

package breezedb
{
	import breezedb.queries.BreezeQueryBuilder;
	import breezedb.queries.BreezeQueryReference;
	import breezedb.schemas.BreezeSchemaBuilder;

	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	/**
	 * Class providing simplified access to the default Breeze database.
	 */
	public class DB extends EventDispatcher
	{

		/**
		 * @private
		 */
		public function DB()
		{
			throw new Error("DB is a static class.");
		}
		

		/**
		 * Sets up the database by creating SQL connection and database file, if it does not exist.
		 * The connection is created asynchronously.
		 *
		 * @param callback Function called once the setup finishes. It must have the following signature:
		 * <listing version="3.0">
		 * function callback(error:Error):void {
		 *    if(error == null)
		 *    {
		 *        // setup completed successfully
		 *    }
		 * };
		 * </listing>
		 * @param databaseFile Reference to a file where the database will be created. If not specified,
		 *        it will default to <code>BreezeDb.storageDirectory</code> where the file name is the
		 *        database name followed by <code>BreezeDb.fileExtension</code>.
		 *
		 * @see #close()
		 * @see breezedb.BreezeDb#fileExtension
		 * @see breezedb.BreezeDb#storageDirectory
		 */
		public static function setup(callback:Function, databaseFile:File = null):void
		{
			BreezeDb.db.setup(callback, databaseFile);
		}


		/**
		 * Returns query builder associated with the given table.
		 *
		 * @param tableName The table that will be associated with the returned query builder.
		 * @return Query builder associated with the given table.
		 */
		public static function table(tableName:String):BreezeQueryBuilder
		{
			return BreezeDb.db.table(tableName);
		}


		/**
		 * Begins a transaction within which all SQL statements executed against the connection's database are grouped.
		 *
		 * @param callback Function triggered once the operation finishes. It should have a single <code>Error</code>
		 *        object as a parameter.
		 *
		 * @see #commit()
		 * @see #rollBack()
		 */
		public static function beginTransaction(callback:Function):void
		{
			BreezeDb.db.beginTransaction(callback);
		}


		/**
		 * Commits an existing transaction, causing any actions performed by the transaction's statements to be
		 * permanently applied to the database.
		 *
		 * @param callback Function triggered once the operation finishes. It should have a single <code>Error</code>
		 *        object as a parameter.
		 *
		 * @see #beginTransaction()
		 * @see #rollBack()
		 */
		public static function commit(callback:Function):void
		{
			BreezeDb.db.commit(callback);
		}


		/**
		 * Rolls back an existing transaction created using the <code>beginTransaction</code> method,
		 * meaning all changes made by any SQL statements in the transaction are discarded.
		 *
		 * @param callback Function triggered once the operation finishes. It should have a single <code>Error</code>
		 *        object as a parameter.
		 *
		 * @see #commit()
		 * @see #beginTransaction()
		 */
		public static function rollBack(callback:Function):void
		{
			BreezeDb.db.rollBack(callback);
		}


		/**
		 * Executes a query on the default database. It is treated as a raw query, thus the result
		 * is returned as a generic <code>BreezeSQLResult</code> object.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.query("SELECT * FROM photos WHERE id > :id", { id: 2 }, onRawQueryCompleted);
		 *
		 * function onRawQueryCompleted(error:Error, result:BreezeSQLResult):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace(result.data); // For SELECT queries
		 *       trace(result.rowsAffected); // For UPDATE, DELETE queries
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function query(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.query(rawQuery, params, callback);
		}


		/**
		 * Executes a <code>SELECT</code> query on the default database. The result is cast to a
		 * <code>Collection</code> object.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.select("SELECT id, title, views FROM photos", onSelectCompleted);
		 *
		 * function onSelectCompleted(error:Error, results:Collection):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace(results);
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function select(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.select(rawQuery, params, callback);
		}


		/**
		 * Executes an <code>INSERT</code> query on the default database.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.insert(
		 *    "INSERT INTO photos (title, views, downloads) VALUES (:title, :views, :downloads),
		 *    { title: "Mountains", views: 35, downloads: 10 },
		 *    onInsertCompleted
		 * );
		 *
		 * function onInsertCompleted(error:Error):void
		 * {
		 *    if(error == null)
		 *    {
		 *       // Insert was successful
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function insert(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.insert(rawQuery, params, callback);
		}


		/**
		 * Executes an <code>UPDATE</code> query on the default database. The result is cast to
		 * an <code>int</code> that provides information about the number of rows affect by the query.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.update("UPDATE photos SET title = :title WHERE id = :id", { title: "Trees", id: 2 }, onUpdateCompleted);
		 *
		 * function onUpdateCompleted(error:Error, rowsAffected:int):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace("Updated", rowsAffected, "row(s)");
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function update(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.update(rawQuery, params, callback);
		}


		/**
		 * Executes a <code>DELETE</code> query on the default database. The result is cast to
		 * an <code>int</code> that provides information about the number of rows affect by the query.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.remove("DELETE FROM photos WHERE title = :title", { title: "Camp Fire" }, onDeleteCompleted);
		 *
		 * function onDeleteCompleted(error:Error, rowsAffected:int):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace("Deleted", rowsAffected, "row(s)");
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function remove(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.remove(rawQuery, params, callback);
		}


		/**
		 * Executes multiple raw queries on the default database. All queries are executed, regardless
		 * of any errors that occur in earlier queries.
		 *
		 * <p>The result is cast to a list of <code>BreezeQueryResult</code> and the results are in
		 * the same order as the executed queries. Each result contains an error and result objects.</p>
		 *
		 * @param rawQueries List of SQL queries to execute. It can be either a raw query (<code>String</code>)
		 *        or delayed <code>BreezeQueryRunner</code> (super class of <code>BreezeQueryBuilder</code>).
		 *        <strong>Note all <code>BreezeQueryRunner</code> objects must use the same database connection.</strong>
		 * @param params Optional query parameters, i.e. <code>Array</code> of key-value <code>Objects</code>
		 *        or <code>null</code>. If query parameters are not used, this parameter can specify
		 *        a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * var query1:BreezeQueryBuilder = BreezeDb.db.table("photos").where("id", 1).update({ title: "Hills" }, BreezeDb.DELAY);
		 * var query2:BreezeQueryRunner = BreezeDb.db.table("photos").where("id", 2).fetch(BreezeDb.DELAY);
		 *
		 * BreezeDb.db.multiQuery(
		 *    [
		 *     query1,
		 *     query2,
		 *     "SELECT id, title FROM photos WHERE title = :title"
		 *    ],
		 *    [null, null, { title: "Hills" }],
		 *    onMultiQueryCompleted
		 * );
		 *
		 * function onMultiQueryCompleted(results:Vector.&lt;BreezeQueryResult&gt;):void
		 * {
		 *    for each(var result:BreezeQueryResult in results)
		 *    {
		 *       if(result.error == null)
		 *       {
		 *          trace(result.data);
		 *       }
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function multiQuery(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.multiQuery(rawQueries, params, callback);
		}


		/**
		 * Executes multiple raw queries on the default database. If a query fails, the queries that follow
		 * will <strong>not</strong> be executed. Successful queries are <strong>not</strong> rolled back.
		 *
		 * <p>The first callback parameter is an <code>Error</code> object that references the error that
		 * caused the execution to stop. Additionally, a list of <code>BreezeQueryResult</code> is provided
		 * and the results are in the same order as the executed queries. Each result contains an error
		 * and result objects.</p>
		 *
		 * @param rawQueries List of SQL queries to execute. It can be either a raw query (<code>String</code>)
		 *        or delayed <code>BreezeQueryRunner</code> (super class of <code>BreezeQueryBuilder</code>).
		 *        <strong>Note all <code>BreezeQueryRunner</code> objects must use the same database connection.</strong>
		 * @param params Optional query parameters, i.e. <code>Array</code> of key-value <code>Objects</code>
		 *        or <code>null</code>. If query parameters are not used, this parameter can specify
		 *        a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.multiQueryFailOnError(
		 *    [
		 *     "SELECT * FROM photos WHEREz", // syntax error, the second query will not be executed
		 *     "SELECT id, title FROM photos WHERE title = :title"
		 *    ],
		 *    [null, { title: "Hills" }],
		 *    onMultiQueryCompleted
		 * );
		 *
		 * function onMultiQueryCompleted(error:Error, results:Vector.&lt;BreezeQueryResult&gt;):void
		 * {
		 *    trace(error); // SQLError
		 *    trace(results.length); // 1
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function multiQueryFailOnError(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.multiQueryFailOnError(rawQueries, params, callback);
		}


		/**
		 * Executes multiple raw queries on the default database. If a query fails, the queries that follow
		 * will <strong>not</strong> be executed and the database is rolled back to the state before executing
		 * the queries.
		 *
		 * <p>The first callback parameter is an <code>Error</code> object that references the error that
		 * caused the execution to stop. Additionally, a list of <code>BreezeQueryResult</code> is provided
		 * and the results are in the same order as the executed queries. Each result contains an error
		 * and result objects.</p>
		 *
		 * @param rawQueries List of SQL queries to execute. It can be either a raw query (<code>String</code>)
		 *        or delayed <code>BreezeQueryRunner</code> (super class of <code>BreezeQueryBuilder</code>).
		 *        <strong>Note all <code>BreezeQueryRunner</code> objects must use the same database connection.</strong>
		 * @param params Optional query parameters, i.e. <code>Array</code> of key-value <code>Objects</code>
		 *        or <code>null</code>. If query parameters are not used, this parameter can specify
		 *        a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.multiQueryTransaction(
		 *    [
		 *     "UPDATE photos SET title = :title",
		 *     "SELECT title FROM photos WHEREz id > 2" // syntax error, the previous UPDATE will be rolled back
		 *    ],
		 *    [{ title: "Hills" }],
		 *    onMultiQueryCompleted
		 * );
		 *
		 * function onMultiQueryCompleted(error:Error, results:Vector.&lt;BreezeQueryResult&gt;):void
		 * {
		 *    trace(error); // SQLError
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public static function multiQueryTransaction(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference
		{
			return BreezeDb.db.multiQueryTransaction(rawQueries, params, callback);
		}


		/**
		 * Closes the existing SQL connection.
		 *
		 * @param callback Function called once the operation finishes. It must have the following signature:
		 * <listing version="3.0">
		 * function callback(error:Error):void {
		 *    if(error == null)
		 *    {
		 *        // connection closed successfully
		 *    }
		 * };
		 * </listing>
		 *
		 * @see #setup()
		 */
		public static function close(callback:Function):void
		{
			BreezeDb.db.close(callback);
		}


		/**
		 * Runs the given migrations. The database must be set up before calling this method.
		 *
		 * @param migrations A class or an <code>Array</code> of migration classes.
		 *                   Each class must be a subclass of <code>BreezeMigration</code>.
		 * @param callback Function called once the migrations are completed. It must have the following signature:
		 * <listing version="3.0">
		 * function callback(error:Error):void {
		 *    if(error == null)
		 *    {
		 *        // migrations ran successfully
		 *    }
		 * };
		 * </listing>
		 *
		 * @see #migrations
		 * @see breezedb.migrations.BreezeMigration
		 */
		public static function runMigrations(migrations:*, callback:Function):void
		{
			BreezeDb.db.runMigrations(migrations, callback);
		}


		/**
		 *
		 *
		 * Getters / Setters
		 *
		 *
		 */


		/**
		 * Returns a reference to the default database instance.
		 *
		 * @see breezedb.BreezeDb#db
		 */
		public static function get instance():IBreezeDatabase
		{
			return BreezeDb.db;
		}


		/**
		 * @private
		 */
		public static function set migrations(value:*):void
		{
			BreezeDb.db.migrations = value;
		}


		/**
		 * A class or an <code>Array</code> of migration classes that will be run during the database setup.
		 * Each class must be a subclass of <code>BreezeMigration</code>.
		 *
		 * @see #runMigrations()
		 * @see breezedb.migrations.BreezeMigration
		 */
		public static function get migrations():*
		{
			return BreezeDb.db.migrations;
		}


		/**
		 * Returns schema builder associated with the database.
		 */
		public static function get schema():BreezeSchemaBuilder
		{
			return BreezeDb.db.schema;
		}


		/**
		 * Reference to the file where the database is stored.
		 */
		public static function get file():File
		{
			return BreezeDb.db.file;
		}


		/**
		 * Name of the database.
		 */
		public static function get name():String
		{
			return BreezeDb.db.name;
		}


		/**
		 * Returns <code>true</code> if the database is set up and the SQL connection is active.
		 */
		public static function get isSetup():Boolean
		{
			return BreezeDb.db.isSetup;
		}


		/**
		 * Arbitrary <code>String</code> value that is used to encrypt the database file.
		 */
		public static function set encryptionKey(value:String):void
		{
			BreezeDb.db.encryptionKey = value;
		}


		/**
		 * @private
		 */
		public static function get encryptionKey():String
		{
			return BreezeDb.db.encryptionKey;
		}


		/**
		 * Returns <code>true</code> if the database connection is currently involved in a transaction.
		 */
		public static function get inTransaction():Boolean
		{
			return BreezeDb.db.inTransaction;
		}
	}
	
}
