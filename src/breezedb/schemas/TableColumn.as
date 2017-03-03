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
	
	internal class TableColumn implements IColumnConstraint
	{
		private var _name:String;
		private var _dataType:int;
		private var _creationMode:Boolean;

		private var _autoIncrement:Boolean;
		private var _notNull:Boolean;
		private var _defaultTo:* = null;
		private var _defaultNull:Boolean;
		private var _unique:Boolean;
		private var _primaryKey:Boolean;


		/**
		 * @private
		 */
		public function TableColumn(name:String, dataType:int, creationMode:Boolean)
		{
			_name = name;
			if(_name.indexOf("[") < 0)
			{
				_name = "[" + _name + "]";
			}
			_dataType = dataType;
			_creationMode = creationMode;
		}


		/**
		 * Makes the column value to be auto-incremented.
		 *
		 * @return Reference to <code>IColumnConstraint</code> allowing to chain additional constraints.
		 */
		public function autoIncrement():IColumnConstraint
		{
			_autoIncrement = true;
			return this;
		}


		/**
		 * @inheritDoc
		 */
		public function notNull():IColumnConstraint
		{
			_notNull = true;
			return this;
		}


		/**
		 * @inheritDoc
		 * @return
		 */
		public function defaultTo(value:*):IColumnConstraint
		{
			_defaultTo = value;
			_defaultNull = false;
			return this;
		}


		/**
		 * @inheritDoc
		 */
		public function defaultNull():IColumnConstraint
		{
			_defaultNull = true;
			_defaultTo = null;
			return this;
		}


		/**
		 * @inheritDoc
		 */
		public function unique():IColumnConstraint
		{
			_unique = true;
			return this;
		}


		/**
		 * @inheritDoc
		 */
		public function primary():IColumnConstraint
		{
			if(!_creationMode)
			{
				throw new IllegalOperationError("Primary key cannot be changed after the table is created.");
			}

			_primaryKey = true;
			return this;
		}


		/**
		 * @private
		 */
		internal function get isPrimaryKey():Boolean
		{
			return _primaryKey;
		}


		/**
		 * @private
		 */
		internal function get name():String
		{
			return _name;
		}


		/**
		 * @private
		 * @param includePrimaryKey If the column is designated as primary key and this parameter is true
		 *        then the result text will contain PRIMARY KEY. The parameter should be false in cases
		 *        when there are multiple primary keys, which requires different SQL syntax.
		 */
		internal function getSQLText(includePrimaryKey:Boolean):String
		{
			var result:String = _name + " " + ColumnDataType.toString(_dataType);

			if(_primaryKey && includePrimaryKey)
			{
				result += " PRIMARY KEY";
			}

			if(_autoIncrement)
			{
				result += " AUTOINCREMENT";
			}

			if(_notNull)
			{
				result += " NOT NULL";
			}

			if(_unique)
			{
				result += " UNIQUE";
			}

			if(_defaultNull)
			{
				result += " DEFAULT (NULL)";
			}
			else if(_defaultTo !== null)
			{
				result += " DEFAULT (" + defaultValue + ")";
			}
			return result;
		}


		private function get defaultValue():*
		{
			if(_defaultTo is String)
			{
				return "'" + _defaultTo + "'";
			}
			return _defaultTo;
		}
	}
	
}
