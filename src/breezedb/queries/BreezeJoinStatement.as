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
	
	internal class BreezeJoinStatement
	{
		public static const INNER_JOIN:String = "INNER JOIN";
		public static const LEFT_OUTER_JOIN:String = "LEFT OUTER JOIN";
		public static const CROSS_JOIN:String = "CROSS JOIN";

		private var _type:String;
		private var _tableName:String;
		private var _predicate:String;
		
		public function BreezeJoinStatement(type:String, tableName:String, predicate:String = null)
		{
			_type = type;
			_tableName = tableName;
			_predicate = predicate;
		}
		

		public function get type():String
		{
			return _type;
		}


		public function get tableName():String
		{
			return _tableName;
		}


		public function get predicate():String
		{
			return _predicate;
		}
	}
	
}
