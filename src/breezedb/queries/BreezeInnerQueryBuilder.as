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
	/**
	 * Class providing API to build complex queries by using nested where clauses.
	 */
	public class BreezeInnerQueryBuilder
	{

		public function BreezeInnerQueryBuilder()
		{
			super();
		}


		public function where(param1:*, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			return this;
		}


		public function orWhere(param1:*, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			return this;
		}


		public function whereDay(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			return this;
		}


		public function whereMonth(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			return this;
		}


		public function whereYear(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			return this;
		}


		public function whereDate(dateColumn:String, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			return this;
		}


		public function whereColumn(param1:*, param2:* = null, param3:* = null):BreezeInnerQueryBuilder
		{
			return this;
		}
		
	}
	
}
