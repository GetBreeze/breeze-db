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
	import breezedb.IBreezeDatabase;
	import breezedb.queries.BreezeQueryReference;

	import flash.data.SQLConnection;

	/**
	 * Class providing API to run table queries on associated database.
	 */
	public class BreezeSchemaBuilder
	{
		private var _db:IBreezeDatabase;
		private var _sqlConnection:SQLConnection;
		
		public function BreezeSchemaBuilder(db:IBreezeDatabase)
		{
			_db = db;
			_sqlConnection = db.connection;
		}
		
		
		public function createTable(tableName:String, blueprint:Function, callback:Function):BreezeQueryReference
		{
			return null;
		}
		
		
		public function editTable(tableName:String, blueprint:Function, callback:Function):BreezeQueryReference
		{
			return null;
		}


		public function dropTable(tableName:String, callback:Function):BreezeQueryReference
		{
			return null;
		}


		public function dropTableIfExists(tableName:String, callback:Function):BreezeQueryReference
		{
			return null;
		}


		public function renameTable(oldTableName:String, newTableName:String, callback:Function):BreezeQueryReference
		{
			return null;
		}


		public function hasTable(tableName:String, callback:Function):BreezeQueryReference
		{
			return null;
		}


		public function hasColumn(tableName:String, columnName:String, callback:Function):BreezeQueryReference
		{
			return null;
		}
		
	}
	
}
