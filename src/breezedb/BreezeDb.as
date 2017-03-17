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
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	/**
	 * Class providing API that allows access to databases.
	 */
	public class BreezeDb
	{
		/**
		 * BreezeDb library version.
		 */
		public static const VERSION:String = "1.0.0";

		/**
		 * Name of the default database.
		 */
		public static const DEFAULT_DB:String = "database";

		/**
		 * Constant used in place of a query callback to delay query execution.
		 */
		public static const DELAY:Boolean = false;

		private static var _databases:Dictionary;
		private static var _fileExtension:String = ".sqlite";
		private static var _storageDirectory:File = File.applicationStorageDirectory;


		/**
		 * Retrieves the default database object.
		 */
		public static function get db():IBreezeDatabase
		{
			return getDb(DEFAULT_DB);
		}


		/**
		 * Retrieves reference to database of given name. The name <code>database</code> is reserved
		 * for the default database accessed using <code>BreezeDb.db</code> or the <code>DB</code>
		 * facade class.
		 *
		 * @param databaseName The name of the database to retrieve. It will be created if it does not exist.
		 * @return Reference to the database.
		 *
		 * @see #db
		 */
		public static function getDb(databaseName:String):IBreezeDatabase
		{
			if(_databases == null)
			{
				_databases = new Dictionary();
			}

			// Create new database
			if(!(databaseName in _databases))
			{
				_databases[databaseName] = new BreezeDbInstance(databaseName);
			}
			return _databases[databaseName];
		}


		/**
		 * The directory where the database files are created.
		 *
		 * @default File.applicationStorageDirectory
		 */
		public static function get storageDirectory():File
		{
			return _storageDirectory;
		}


		/**
		 * @private
		 */
		public static function set storageDirectory(value:File):void
		{
			if(value == null)
			{
				throw new ArgumentError("Storage directory cannot be null.");
			}

			if(!value.exists || !value.isDirectory)
			{
				throw new Error("Storage directory must point to an existing directory.");
			}

			_storageDirectory = value;
		}


		/**
		 * File extension for the database files. It must contain a dot followed by at least one character,
		 * without spaces.
		 *
		 * @default .sqlite
		 */
		public static function get fileExtension():String
		{
			return _fileExtension;
		}


		/**
		 * @private
		 */
		public static function set fileExtension(value:String):void
		{
			if(value == null)
			{
				throw new ArgumentError("File extension cannot be null.");
			}

			if(value.indexOf(" ") >= 0)
			{
				throw new ArgumentError("Extension cannot contain spaces");
			}

			var dotIndex:int = value.lastIndexOf(".");
			if(!(dotIndex >= 0 && dotIndex != value.length - 1))
			{
				throw new ArgumentError("Extension must contain a dot followed by at least one character.");
			}

			_fileExtension = value;
		}
	}
}
