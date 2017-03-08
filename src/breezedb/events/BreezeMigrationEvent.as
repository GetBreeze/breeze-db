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

package breezedb.events
{
	import flash.events.Event;

	/**
	 * Event dispatched when a database migration is completed, either successfully or with an error.
	 */
	public class BreezeMigrationEvent extends Event
	{
		/**
		 * A migration has completed.
		 */
		public static const COMPLETE:String = "BreezeMigrationEvent::complete";

		private var _successful:Boolean;
		private var _didRun:Boolean;


		/**
		 * @private
		 */
		public function BreezeMigrationEvent(type:String, didRun:Boolean = true, successful:Boolean = true)
		{
			super(type, false, false);

			_didRun = didRun;
			_successful = successful;
		}


		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new BreezeMigrationEvent(type, _didRun, _successful);
		}
		

		/**
		 * Returns <code>true</code> if the migration was successful, <code>false</code> otherwise.
		 */
		public function get successful():Boolean
		{
			return _successful;
		}


		/**
		 * Returns <code>true</code> if the migration was run, or <code>false</code> if the migration
		 * had run in the past.
		 */
		public function get didRun():Boolean
		{
			return _didRun;
		}
	}
	
}
