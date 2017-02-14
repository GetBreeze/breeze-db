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
	import breezedb.schemas.BreezeSchemaBuilder;

	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	/**
	 * Class providing simplified access to the default Breeze database.
	 */
	public class DB extends EventDispatcher
	{
		
		public function DB()
		{
			throw new Error("DB is a static class.");
		}


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
		 * @see #commit()
		 * @see #rollBack()
		 */
		public static function beginTransaction():void
		{
			BreezeDb.db.beginTransaction();
		}


		/**
		 * Commits an existing transaction, causing any actions performed by the transaction's statements to be
		 * permanently applied to the database.
		 *
		 * @see #beginTransaction()
		 * @see #rollBack()
		 */
		public static function commit():void
		{
			BreezeDb.db.commit();
		}


		/**
		 * Rolls back an existing transaction created using the <code>beginTransaction</code> method,
		 * meaning all changes made by any SQL statements in the transaction are discarded.
		 *
		 * @see #commit()
		 * @see #beginTransaction()
		 */
		public static function rollBack():void
		{
			BreezeDb.db.rollBack();
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
		 *
		 *
		 * Getters / Setters
		 *
		 *
		 */


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
	}
	
}
