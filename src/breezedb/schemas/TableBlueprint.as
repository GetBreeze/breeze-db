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
	import flash.errors.IllegalOperationError;

	public class TableBlueprint
	{
		internal static const CREATE:int = 0;
		internal static const EDIT:int = 1;

		private var _operation:int;
		private var _tableName:String;
		private var _columns:Vector.<TableColumn>;
		private var _createIndex:String;
		private var _dropIndex:String;

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
			addColumn(columnName, ColumnDataType.INTEGER)
					.autoIncrement()
					.primary()
					.notNull();
			// No more constraints should be added to this column
		}
		

		/**
		 * Adds a new column with the given name and type <code>INTEGER</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function integer(columnName:String):IColumnConstraint
		{
			return addColumn(columnName, ColumnDataType.INTEGER);
		}


		/**
		 * Adds a new column with the given name and type <code>INTEGER</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function string(columnName:String):IColumnConstraint
		{
			return addColumn(columnName, ColumnDataType.TEXT);
		}


		/**
		 * Adds a new column with the given name and type <code>BLOB</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function blob(columnName:String):IColumnConstraint
		{
			return addColumn(columnName, ColumnDataType.BLOB);
		}


		/**
		 * Adds a new column with the given name and type <code>INTEGER</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function boolean(columnName:String):IColumnConstraint
		{
			return addColumn(columnName, ColumnDataType.INTEGER);
		}


		/**
		 * Adds a new column with the given name and type <code>NUMERIC</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function number(columnName:String):IColumnConstraint
		{
			return addColumn(columnName, ColumnDataType.NUMERIC);
		}


		/**
		 * Adds a new column with the given name and type <code>DATE</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function date(columnName:String):IColumnConstraint
		{
			return addColumn(columnName, ColumnDataType.DATE);
		}


		/**
		 * Adds a new column with the given name and type <code>DATETIME</code>.
		 *
		 * @param columnName Name of the column.
		 * @return <code>IColumnConstraint</code> object that allows adding additional constraints on the column.
		 */
		public function timestamp(columnName:String):IColumnConstraint
		{
			return addColumn(columnName, ColumnDataType.DATE_TIME);
		}


		/**
		 * Creates primary key on one or multiple columns. You can only use this method when creating table.
		 *
		 * @param rest List of names (<code>String</code>) for existing columns on which the primary key will be created.
		 */
		public function primary(...rest):void
		{
			if(_operation == EDIT)
			{
				throw new IllegalOperationError("Primary key cannot be changed after the table is created.");
			}

			var length:int = rest.length;
			for(var i:int = 0; i < length; ++i)
			{
				var columnName:String = rest[i] as String;
				if(columnName == null)
				{
					throw new ArgumentError("The name of the column must be a String.");
				}

				var column:TableColumn = getColumn(columnName);
				if(column == null)
				{
					throw new Error("Cannot create primary key on non-existing column '" + columnName + "'.");
				}
				column.primary();
			}
		}
		

		/**
		 * Creates an index on the given column(s).
		 *
		 * @param indexes Either a <code>String</code> (column name) or <code>Array</code> of <code>Strings</code>
		 *        (multiple column names).
		 * @param indexName Optional index name. If not specified, it will default to <code>index_{column_name}</code>.
		 * @param unique Similar to <code>UNIQUE</code> constraint, unique index prevents duplicate entries
		 *        in the column or combination of columns on which there's an index.
		 */
		public function index(indexes:*, indexName:String = null, unique:Boolean = false):void
		{
			if(indexes is String)
			{
				indexes = [indexes];
			}

			if(!(indexes is Array))
			{
				throw new ArgumentError("Parameter indexes must be either a String or Array.");
			}

			if((indexes as Array).length == 0)
			{
				throw new ArgumentError("At least one column name must be specified.");
			}

			_createIndex = "CREATE " + (unique ? "UNIQUE " : "") + "INDEX ";

			var customIndexName:Boolean = indexName != null;
			if(!customIndexName)
			{
				indexName = "index_";
			}

			var columns:String = "(";
			var length:int = indexes.length;
			for(var i:int = 0; i < length; ++i)
			{
				var index:String = indexes[i] as String;
				if(index == null)
				{
					throw new ArgumentError("The name of the column must be a String.");
				}

				if(i > 0)
				{
					columns += ", ";
				}
				columns += index;

				if(!customIndexName)
				{
					if(i > 0)
					{
						indexName += "_";
					}
					indexName += index;
				}
			}
			columns += ")";

			_createIndex += indexName;
			_createIndex += " ON " + _tableName + " ";
			_createIndex += columns + ";";
		}


		/**
		 * Removes index with the given name. You can only use this method when editing table.
		 *
		 * @param indexName Name of the index to remove.
		 */
		public function dropIndex(indexName:String):void
		{
			if(_operation == CREATE)
			{
				throw new IllegalOperationError("Index can be dropped only when editing table.");
			}

			if(indexName == null)
			{
				throw new ArgumentError("Parameter indexName cannot be null.");
			}

			_dropIndex = "DROP INDEX " + indexName + ";";
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
		

		/**
		 * @private
		 */
		internal function setTable(tableName:String):void
		{
			_tableName = tableName;
		}


		/**
		 * @private
		 */
		internal function get query():String
		{
			var result:String = "";
			if(_columns.length > 0)
			{
				result = ((_operation == CREATE) ? "CREATE TABLE" : "ALTER TABLE") + " " + _tableName + "("

				var primaryKeys:Vector.<TableColumn> = this.primaryKeys;
				var hasCompositeKey:Boolean = primaryKeys.length > 1;
				var i:int = 0;
				for each(var column:TableColumn in _columns)
				{
					// Add comma to separate the previous line
					if(i++ > 0)
					{
						result += ", ";
					}
					result += column.getSQLText(!hasCompositeKey);
				}

				// Add primary key on multiple fields if has composite key
				if(hasCompositeKey)
				{
					i = 0;
					result += ", PRIMARY KEY (";
					for each(column in primaryKeys)
					{
						// Add comma to separate the previous line
						if(i++ > 0)
						{
							result += ", ";
						}
						result += column.name;
					}
					result += ")";
				}
				result += ");";
			}

			// Add index statement if needed
			if(_createIndex != null)
			{
				result += _createIndex;
			}
			if(_dropIndex != null)
			{
				result += _dropIndex;
			}

			return result;
		}


		/**
		 * Returns list of columns that are designated as a primary key.
		 */
		private function get primaryKeys():Vector.<TableColumn>
		{
			var result:Vector.<TableColumn> = new <TableColumn>[];
			for each(var column:TableColumn in _columns)
			{
				if(column.isPrimaryKey)
				{
					result[result.length] = column;
				}
			}
			return result;
		}
	}
	
}
