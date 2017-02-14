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
	import breezedb.queries.IRawQuery;

	import flash.data.SQLConnection;
	
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;

	/**
	 * Interface that defines API to interact with the database.
	 */
	public interface IBreezeDatabase extends IEventDispatcher, IRawQuery
	{
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
		function setup(callback:Function, databaseFile:File = null):void;


		/**
		 * Returns query builder associated with the given table.
		 *
		 * @param tableName The table that will be associated with the returned query builder.
		 * @return Query builder associated with the given table.
		 */
		function table(tableName:String):BreezeQueryBuilder;


		/**
		 * Begins a transaction within which all SQL statements executed against the connection's database are grouped.
		 *
		 * @see #commit()
		 * @see #rollBack()
		 */
		function beginTransaction():void;


		/**
		 * Commits an existing transaction, causing any actions performed by the transaction's statements to be
		 * permanently applied to the database.
		 *
		 * @see #beginTransaction()
		 * @see #rollBack()
		 */
		function commit():void;


		/**
		 * Rolls back an existing transaction created using the <code>beginTransaction</code> method,
		 * meaning all changes made by any SQL statements in the transaction are discarded.
		 *
		 * @see #commit()
		 * @see #beginTransaction()
		 */
		function rollBack():void;


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
		function close(callback:Function):void;


		/**
		 * Reference to the file where the database is stored.
		 */
		function get file():File;


		/**
		 * Name of the database.
		 */
		function get name():String;


		/**
		 * Returns <code>true</code> if the database is set up and the SQL connection is active.
		 */
		function get isSetup():Boolean;


		/**
		 * Arbitrary <code>String</code> value that is used to encrypt the database file.
		 */
		function set encryptionKey(value:String):void;


		/**
		 * @private
		 */
		function get encryptionKey():String;


		/**
		 * The SQL connection for this database.
		 */
		function get connection():SQLConnection;
	}
	
}
