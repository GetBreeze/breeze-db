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
	
	internal class TableColumn implements IColumnConstraint
	{
		private var _name:String;
		private var _dataType:int;
		private var _creationMode:Boolean;
		
		public function TableColumn(name:String, dataType:int, creationMode:Boolean)
		{
			_name = name;
			_dataType = dataType;
			_creationMode = creationMode;
		}


		public function autoIncrement():IColumnConstraint
		{
			return this;
		}


		public function notNull():IColumnConstraint
		{
			return this;
		}


		public function defaultTo(value:*):IColumnConstraint
		{
			return this;
		}


		public function defaultNull():IColumnConstraint
		{
			return this;
		}


		public function unique():IColumnConstraint
		{
			return this;
		}


		public function primary():IColumnConstraint
		{
			return this;
		}


		/**
		 * @private
		 */
		public function get name():String
		{
			return _name;
		}
	}
	
}
