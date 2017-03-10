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

package breezedb.models
{
	import breezedb.BreezeDb;
	import breezedb.queries.BreezeQueryReference;

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	/**
	 * Base class for custom database models.
	 */
	public class BreezeModel extends EventDispatcher
	{
		// Name of the database
		protected var _databaseName:String = null;

		// Name of the database table
		protected var _tableName:String = null;

		// Name of the primary key
		protected var _primaryKey:String = "id";

		// Does this object exist in the database?
		protected var _exists:Boolean = false;

		// Does this model have an auto-increment id?
		protected var _autoIncrementId:Boolean = true;
		

		/**
		 * Creates new instance of the model.
		 *
		 * @param initialValues A key-value object representing values of the model's properties.
		 */
		public function BreezeModel(initialValues:Object = null)
		{
			super(null);

			_databaseName = BreezeDb.DEFAULT_DB;

			if(initialValues != null)
			{
				populateFromObject(initialValues, false);
			}
		}


		/**
		 *
		 *
		 * Public API
		 *
		 *
		 */


		/**
		 * Helper method that retrieves an instance of <code>BreezeModelQueryBuilder</code> for the given model.
		 *
		 * @param modelClass The model to retrieve the builder for.
		 * @return Instance of <code>BreezeModelQueryBuilder</code> associated with the given model.
		 */
		public static function query(modelClass:Class):BreezeModelQueryBuilder
		{
			return new BreezeModelQueryBuilder(modelClass);
		}


		public function save(callback:* = null):BreezeQueryReference
		{
			throw new Error("Not implemented");
		}


		public function remove(callback:* = null):BreezeQueryReference
		{
			throw new Error("Not implemented");
		}


		/**
		 *
		 *
		 * Internal / Private API
		 *
		 *
		 */


		internal function populateFromObject(values:Object, exists:Boolean = true):void
		{
			for(var property:String in values)
			{
				if(property in this)
				{
					this[property] = values[property];
				}
			}

			_exists = exists;
		}


		/**
		 *
		 *
		 * Getters / Setters
		 *
		 *
		 */


		private function get className():String
		{
			var className:String = getQualifiedClassName(this);
			var index:int = className.lastIndexOf("::");
			if(index >= 0)
			{
				className = className.slice(index + 2);
			}
			return className;
		}


		public function get tableName():String
		{
			if(_tableName != null)
			{
				return _tableName;
			}

			var regExp:RegExp = /(^[a-z]|[A-Z0-9])[a-z]*/g;
			var className:String = this.className;
			var result:Array = className.match(regExp);

			if(result != null && result.length > 0)
			{
				className = result.join("_");
			}

			return className.toLowerCase();
		}


		public function get databaseName():String
		{
			return _databaseName;
		}

		
		public function get primaryKey():String
		{
			return _primaryKey;
		}


		public function get exists():Boolean
		{
			return _exists;
		}
	}
	
}
