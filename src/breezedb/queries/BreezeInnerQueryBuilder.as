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

package breezedb.queries
{
	import flash.globalization.DateTimeFormatter;
	
	/**
	 * Class providing API to build complex queries by using nested where clauses.
	 */
	public class BreezeInnerQueryBuilder
	{
		private static var sLongDateFormatter:DateTimeFormatter = null;
		private static var sShortDateFormatter:DateTimeFormatter = null;
		
		private var _where:Array = [[]];
		private var _parametersIndex:uint = 0;
		private var _queryParams:*;


		/**
		 * @private
		 */
		public function BreezeInnerQueryBuilder(queryParams:*, parametersIndex:uint)
		{
			super();
			_queryParams = queryParams;
			_parametersIndex = parametersIndex;
		}


		public function where(param1:*, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			// Function to build nested where clauses
			if(param1 is Function && param2 === null && param3 === null)
			{
				var builder:BreezeInnerQueryBuilder = new BreezeInnerQueryBuilder(_queryParams, _parametersIndex);
				param1(builder);
				_parametersIndex = builder.parametersIndex;
				if(builder.queryExists)
				{
					whereRaw(builder.queryString);
				}
			}
			// Raw where statement, e.g. where("id > 2")
			else if(param1 is String && param2 === null && param3 === null)
			{
				whereRaw(param1);
			}
			// Simple equal statement, e.g. where("id", 15)
			else if(param1 is String && param3 === null)
			{
				where(param1, "=", param2);
			}
			// Simple statement with operator, e.g. where("id", "!=", 15)
			else if(param1 is String && param2 is String && param3 !== null)
			{
				whereRaw(param1 + " " + param2 + " " + inputToParameter(param3));
			}
			// Array of statements, e.g. where([["id", 15], ["name", "!=", "Kevin"])
			else if(param1 is Array && param2 === null && param3 === null)
			{
				for each(var statement:* in param1)
				{
					if(!(statement is Array))
					{
						throw new Error("Where must be an Array of Arrays.");
					}

					if(statement.length == 3)
					{
						where(statement[0], statement[1], statement[2]);
					}
					else if(statement.length == 2)
					{
						where(statement[0], "=", statement[1]);
					}
					else
					{
						throw new Error("Invalid where parameters.");
					}

				}
			}
			// Invalid input
			else
			{
				throw new ArgumentError("Invalid where parameters.");
			}

			return this;
		}


		public function orWhere(param1:*, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			_where[_where.length] = [];
			where(param1, param2, param3);

			return this;
		}


		public function whereDay(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			validateColumnName(dateColumn);

			param2 = formatDayOrMonth(param2, "date");
			param3 = formatDayOrMonth(param3, "date");

			where("strftime('%d', " + dateColumn + ")", param2, param3);

			return this;
		}


		public function whereMonth(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			validateColumnName(dateColumn);

			param2 = formatDayOrMonth(param2, "month");
			param3 = formatDayOrMonth(param3, "month");

			where("strftime('%m', " + dateColumn + ")", param2, param3);

			return this;
		}


		public function whereYear(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			validateColumnName(dateColumn);

			param2 = formatDayOrMonth(param2, "fullYear");
			param3 = formatDayOrMonth(param3, "fullYear");

			where("strftime('%Y', " + dateColumn + ")", param2, param3);

			return this;
		}


		public function whereDate(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			validateColumnName(dateColumn);

			if(param2 is Date)
			{
				param2 = getShortStringFromDate(param2);
			}

			if(param3 is Date)
			{
				param3 = getShortStringFromDate(param3);
			}

			where("date(" + dateColumn + ")", param2, param3);

			return this;
		}


		public function whereColumn(param1:*, param2:String = null, param3:String = null):BreezeInnerQueryBuilder
		{
			if(!(param1 is Array || param1 is String))
			{
				throw new ArgumentError("Parameter param1 must be either an Array or String.");
			}

			// Simple equal statement, e.g. whereColumn("views", "downloads)
			if(param1 is String && param3 === null)
			{
				whereColumn(param1, "=", param2);
			}
			// Simple statement with operator, e.g. whereColumn("views", ">", "downloads")
			else if(param1 is String && param2 !== null && param3 !== null)
			{
				validateColumnName(param1);
				validateColumnName(param3);

				whereRaw(param1 + " " + param2 + " " + param3);
			}
			// Array of statements, e.g. whereColumn([["views", "downloads"], ["likes", ">", "downloads"])
			else if(param1 is Array && param2 === null && param3 === null)
			{
				for each(var statement:* in param1)
				{
					if(!(statement is Array))
					{
						throw new Error("Where must be an Array of Arrays.");
					}

					if(statement.length == 3)
					{
						whereColumn(statement[0], statement[1], statement[2]);
					}
					else if(statement.length == 2)
					{
						whereColumn(statement[0], "=", statement[1]);
					}
					else
					{
						throw new Error("Invalid whereColumn parameters.");
					}

				}
			}
			// Invalid input
			else
			{
				throw new ArgumentError("Invalid whereColumn parameters.");
			}

			return this;
		}


		/**
		 *
		 *
		 * Private / Internal API
		 *
		 *
		 */


		/**
		 * @private
		 */
		internal function get parametersIndex():uint
		{
			return _parametersIndex;
		}


		/**
		 * @private
		 */
		internal function set parametersIndex(value:uint):void
		{
			_parametersIndex = value;
		}


		/**
		 * @private
		 */
		internal function get queryExists():Boolean
		{
			return _where.length > 0 && _where[0].length > 0;
		}


		/**
		 * @private
		 */
		internal function get queryString():String
		{
			var tmpOrWhere:Array = [];
			for each(var whereArray:Array in _where)
			{
				var innerClause:String = whereArray.join(" AND ");
				if(whereArray.length > 1 || innerClause.charAt(0) != "(")
				{
					innerClause = "(" + innerClause + ")";
				}
				tmpOrWhere[tmpOrWhere.length] = innerClause;
			}

			var result:String = tmpOrWhere.join(" OR ");
			if(tmpOrWhere.length > 1)
			{
				result = "(" + result + ")";
			}
			return result;
		}


		/**
		 * @private
		 */
		internal function whereRaw(query:String):void
		{
			var lastWhere:Array = _where[_where.length - 1];
			lastWhere[lastWhere.length] = query;
		}


		private function inputToParameter(value:*):String
		{
			var name:String = ":param_" + _parametersIndex++;
			if(value is Date)
			{
				value = getLongStringFromDate(value as Date);
			}
			if(_queryParams == null)
			{
				_queryParams = {};
			}
			_queryParams[name] = value;
			return name;
		}
		
		
		/**
		 * Formats the given value to a two-digit String,
		 * used for SQL comparison of months and days.
		 */
		private function formatDayOrMonth(param2:*, dateValue:String):*
		{
			if(param2 is Date)
			{
				param2 = param2[dateValue];
				
				// Month value starts from 0 so it must be incremented to match the SQL value
				if(dateValue == "month")
				{
					param2++;
				}
			}
			
			if(param2 is Number)
			{
				if(param2 < 0)
				{
					throw new ArgumentError("Negative value cannot be used for comparison.");
				}
				
				// Add leading zero if needed
				param2 = ((param2 < 10) ? "0" : "") + int(param2);
			}
			
			return param2;
		}
		
		
		private function validateColumnName(columnName:String):void
		{
			if(columnName == null)
			{
				throw new ArgumentError("Column name cannot be null.");
			}
			
			if(columnName.indexOf(";") >= 0)
			{
				throw new ArgumentError("Invalid column name: " + columnName);
			}
		}
		
		
		private function getShortStringFromDate(date:Date):String
		{
			return shortDateFormatter.format(date);
		}
		
		
		private function getLongStringFromDate(date:Date):String
		{
			return longDateFormatter.format(date);
		}
		
		
		private static function get shortDateFormatter():DateTimeFormatter
		{
			if(sShortDateFormatter == null)
			{
				sShortDateFormatter = new DateTimeFormatter("en-US");
				sShortDateFormatter.setDateTimePattern("yyyy-MM-dd");
			}
			return sShortDateFormatter;
		}
		
		
		private static function get longDateFormatter():DateTimeFormatter
		{
			if(sLongDateFormatter == null)
			{
				sLongDateFormatter = new DateTimeFormatter("en-US");
				sLongDateFormatter.setDateTimePattern("yyyy-MM-dd HH:mm:ss");
			}
			return sLongDateFormatter;
		}
	}
	
}
