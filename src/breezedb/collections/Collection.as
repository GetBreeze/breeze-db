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

package breezedb.collections
{

	/**
	 * Collection class provides a fluent, convenient wrapper for working with arrays of data.
	 */
	public dynamic class Collection extends Array
	{
		public function Collection(...rest)
		{
			super();

			var length:int = rest.length;
			for(var i:int = 0; i < length; ++i)
			{
				this[i] = rest[i];
			}
		}


		public function add(element:*):Collection
		{
			throw new Error("Not implemented");
		}


		public function all():Array
		{
			throw new Error("Not implemented");
		}


		public function avg(keyOrCallback:* = null):Number
		{
			throw new Error("Not implemented");
		}


		public function max(keyOrCallback:* = null):Number
		{
			throw new Error("Not implemented");
		}


		public function min(keyOrCallback:* = null):Number
		{
			throw new Error("Not implemented");
		}


		public function sum(keyOrCallback:* = null):Number
		{
			throw new Error("Not implemented");
		}

	}
	
}
