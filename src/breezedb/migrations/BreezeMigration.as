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

package breezedb.migrations
{
	import breezedb.IBreezeDatabase;
	import breezedb.events.BreezeMigrationEvent;

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	/**
	 * Base class providing API to run a database migration.
	 */
	public class BreezeMigration extends EventDispatcher
	{

		/**
		 * @private
		 */
		public function BreezeMigration()
		{
		}


		/**
		 * Provides the migration functionality. <strong>Must be overridden.</strong>
		 *
		 * @param db Reference to the database used during this migration.
		 */
		public function run(db:IBreezeDatabase):void
		{
			throw new Error("The run method must be overridden.");
		}


		/**
		 * The <code>done</code> method must be called at the end of each migration.
		 *
		 * @param successful <code>true</code> if the migration was successful, <code>false</code> otherwise.
		 */
		protected final function done(successful:Boolean = true):void
		{
			dispatchEvent(new BreezeMigrationEvent(BreezeMigrationEvent.COMPLETE, true, successful));
		}


		/**
		 * Returns the class name. Stored in a database table to track previously run migrations.
		 */
		internal function get name():String
		{
			var className:String = getQualifiedClassName(this);
			var index:int = className.lastIndexOf("::");
			if(index >= 0)
			{
				className = className.slice(index + 2);
			}
			return className;
		}
		
	}
	
}
