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
	public class TableBlueprint
	{
		internal static const CREATE:int = 0;
		internal static const EDIT:int = 1;

		private var _operation:int;
		private var _columns:Vector.<TableColumn>;
		
		public function TableBlueprint()
		{
			_columns = new <TableColumn>[];
		}
		

		/**
		 * Adds a new column with the given name and type <code>INTEGER</code>.
		 * The column is created as follows: <code>[name] INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL</code>,
		 * additional constraints cannot be applied.
		 *
		 * @param columnName Name of the column.
		 */
		public function increments(columnName:String):void
		{
		}
		

		/**
		 * Adds a new column with the given name and type <code>INTEGER</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function integer(columnName:String):IColumnConstraint
		{
			return null;
		}


		/**
		 * Adds a new column with the given name and type <code>INTEGER</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function string(columnName:String):IColumnConstraint
		{
			return null;
		}


		/**
		 * Adds a new column with the given name and type <code>BLOB</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function blob(columnName:String):IColumnConstraint
		{
			return null;
		}


		/**
		 * Adds a new column with the given name and type <code>INTEGER</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function boolean(columnName:String):IColumnConstraint
		{
			return null;
		}


		/**
		 * Adds a new column with the given name and type <code>NUMERIC</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function number(columnName:String):IColumnConstraint
		{
			return null;
		}


		/**
		 * Adds a new column with the given name and type <code>DATE</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function date(columnName:String):IColumnConstraint
		{
			return null;
		}


		/**
		 * Adds a new column with the given name and type <code>DATE_TIME</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function timestamp(columnName:String):IColumnConstraint
		{
			return null;
		}


		/**
		 * Creates primary key on multiple columns. You can only use this method when creating a table.
		 *
		 * @param rest List of names (<code>String</code>) for existing columns on which the primary key will be created.
		 */
		public function primary(...rest):void
		{
		}
		

		/**
		 * Creates an index on the given column(s).
		 *
		 * @param indexes Either a <code>String</code> (column name) or <code>Array</code> of <code>Strings</code>
		 *        (multiple column names).
		 * @param indexName Optional index name. If not specified, it will default to <code>index_{column_name}</code>.
		 */
		public function index(indexes:*, indexName:String = null):void
		{
		}


		/**
		 * Removes index with the given name.
		 *
		 * @param indexName Name of the index to remove.
		 */
		public function dropIndex(indexName:String):void
		{
		}
		
		
		/**
		 *
		 *
		 * Private API
		 *
		 *
		 */
		
		
		private function addColumn(columnName:String, dataType:int):TableColumn
		{
			if(columnName == null)
			{
				throw new ArgumentError("Parameter columnName cannot be null.");
			}

			var newColumn:TableColumn = new TableColumn(columnName, dataType, _operation == CREATE);
			var index:int = 0;
			for each(var column:TableColumn in _columns)
			{
				if(column.name == newColumn.name)
				{
					break;
				}
				index++;
			}
			_columns[index] = newColumn;
			return newColumn;
		}


		private function getColumn(columnName:String):TableColumn
		{
			for each(var column:TableColumn in _columns)
			{
				if(column.name == columnName)
				{
					return column;
				}
			}
			return null;
		}


		/**
		 * @private
		 */
		internal function setOperation(value:int):void
		{
			_operation = value;
		}
		
	}
	
}
