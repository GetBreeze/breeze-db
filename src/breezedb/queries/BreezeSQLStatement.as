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
	import breezedb.utils.Callback;
	import breezedb.utils.GarbagePrevention;

	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.net.Responder;

	internal class BreezeSQLStatement extends SQLStatement
	{
		private var _callback:Function;


		public function BreezeSQLStatement(callback:Function)
		{
			_callback = callback;
		}
		
		
		/**
		 *
		 *
		 * Public API
		 *
		 *
		 */
		
		
		override public function execute(prefetch:int = -1, responder:Responder = null):void
		{
			fixParameterMismatch();
			
			addEventListener(SQLEvent.RESULT, onQuerySuccess, false, 0, true);
			addEventListener(SQLErrorEvent.ERROR, onQueryError, false, 0, true);
			
			GarbagePrevention.instance.add(this);
			
			super.execute(prefetch, responder);
		}
		
		
		/**
		 *
		 *
		 * Private API
		 *
		 *
		 */
		
		
		/**
		 * This method fixes the annoying "feature" in SQLite that only allows parameters that
		 * are actually used within the query.
		 */
		private function fixParameterMismatch():void
		{
			for(var property:String in parameters)
			{
				if(text.indexOf(property) == -1)
				{
					delete parameters[property];
				}
			}
		}
		
		
		private function onQuerySuccess(event:SQLEvent):void
		{
			Callback.call(_callback, [null, this]);
			
			GarbagePrevention.instance.remove(this);
		}
		
		
		private function onQueryError(event:SQLErrorEvent):void
		{
			Callback.call(_callback, [event.error, this]);
			
			GarbagePrevention.instance.remove(this);
		}
	}
	
}
