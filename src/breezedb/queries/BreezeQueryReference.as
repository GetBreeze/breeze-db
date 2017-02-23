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
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * Class providing API that allows cancelling callback of executed query.
	 */
	public class BreezeQueryReference extends EventDispatcher
	{
		/**
		 * Name for event that is dispatched when the query is cancelled.
		 */
		public static const CANCEL:String = "cancel";

		private var _rawQuery:BreezeRawQuery;


		/**
		 * @private
		 */
		public function BreezeQueryReference(rawQuery:BreezeRawQuery)
		{
			_rawQuery = rawQuery;
		}


		/**
		 * Prevents the query callback from being triggered. Note that this <strong>does not stop</strong>
		 * the actual SQL query from running, it only stops the callback from being called.
		 */
		public function cancel():void
		{
			_rawQuery.cancel();
			dispatchEvent(new Event(CANCEL));
		}


		/**
		 * Returns <code>true</code> if the query is completed.
		 */
		public function get isCompleted():Boolean
		{
			return _rawQuery.isCompleted;
		}


		/**
		 * Returns <code>true</code> if the query is cancelled.
		 */
		public function get isCancelled():Boolean
		{
			return _rawQuery.isCancelled;
		}
	}
	
}
