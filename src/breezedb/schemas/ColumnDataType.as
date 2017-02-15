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

	internal class ColumnDataType
	{
		
		public static const INTEGER:int = 0;
		public static const TEXT:int = 1;
		public static const BLOB:int = 2;
		public static const NUMERIC:int = 3;
		public static const DATE:int = 4;
		public static const DATE_TIME:int = 5;


		internal static function toString(value:int):String
		{
			switch(value)
			{
				case INTEGER:
					return "INTEGER";
				case TEXT:
					return "TEXT";
				case BLOB:
					return "BLOB";
				case NUMERIC:
					return "NUMERIC";
				case DATE:
					return "DATE";
				case DATE_TIME:
					return "DATETIME";
			}
			throw new ArgumentError("Unknown data type value: " + value);
		}

	}
	
}
