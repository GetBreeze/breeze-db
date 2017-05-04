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

	import flash.errors.IllegalOperationError;

	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	import org.kuwamoto.Inflect;

	/**
	 * Base class for custom database models.
	 */
	public class BreezeModel extends EventDispatcher
	{
		/**
		 * @private
		 */
		protected var _databaseName:String = null;


		/**
		 * @private
		 */
		protected var _tableName:String = null;


		/**
		 * @private
		 */
		protected var _primaryKey:String = "id";


		/**
		 * @private
		 */
		protected var _exists:Boolean = false;


		/**
		 * @private
		 */
		protected var _autoIncrementId:Boolean = true;
		

		/**
		 * Creates new instance of the model.
		 *
		 * @param initialValues A key-value <code>Object</code> (where keys represent column names) used
		 *                      to initialize the model's properties.
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
		 * Helper method that retrieves an instance of <code>BreezeModelQueryBuilder</code> for the given model class.
		 *
		 * @param modelClass The model to retrieve the builder for. <strong>Must be a subclass
		 *                   of <code>BreezeModel</code> class.</strong>
		 * @return Instance of <code>BreezeModelQueryBuilder</code> associated with the given model.
		 */
		public static function query(modelClass:Class):BreezeModelQueryBuilder
		{
			return new BreezeModelQueryBuilder(modelClass);
		}


		/**
		 * Saves this model to the database. If it exists, its values will be updated.
		 *
		 * @param callback Function that is triggered when the query is completed. The saved model is returned
		 * 		  to the callback as the second argument.
		 *
		 * <listing version="3.0">
		 * var photo:Photo = new Photo();
		 * photo.title = "Sunset";
		 * photo.save(callback);
		 * function callback(error:Error, photo:Photo):void
		 * {
		 *
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
         */
		public function save(callback:Function = null):BreezeQueryReference
		{
			var modelClass:Class = Object(this).constructor as Class;
			return new BreezeModelQueryBuilder(modelClass).save(this, callback);
		}


		/**
		 * Removes this model from the database.
		 *
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeModelQueryBuilder.query(Photo).find(1, function(findError:Error, photo:Photo):void
		 * {
		 *     if(photo != null)
		 *     {
		 *        photo.remove(function(removeError:Error):void
		 *        {
		 *
		 *        });
		 *     }
		 * });
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		public function remove(callback:Function = null):BreezeQueryReference
		{
			var modelClass:Class = Object(this).constructor as Class;
			if(primaryKey == null || !(primaryKey in this))
			{
				throw new IllegalOperationError("The model " + modelClass + " has no primary key set.");
			}
			return new BreezeModelQueryBuilder(modelClass).removeByKey(this[primaryKey], callback).queryReference;
		}


		/**
		 *
		 *
		 * Internal / Private API
		 *
		 *
		 */


		/**
		 * @private
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

			setExists(exists);
		}


		/**
		 * @private
		 */
		internal function toKeyValue(omitPrimaryKey:Boolean = false):Object
		{
			var result:Object = {};

			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables)
			{
				var column:String = variable.@name;
				if((column == '') || (omitPrimaryKey && (primaryKey == column)))
				{
					continue;
				}

				result[column] = this[column];
			}

			return result;
		}


		/**
		 * @private
		 */
		internal function setExists(value:Boolean):void
		{
			_exists = value;
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


		/**
		 * Returns the model's table name.
		 */
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

			className = className.toLowerCase();

			_tableName = Inflect.pluralize(className);
			return _tableName;
		}


		/**
		 * Returns the model's database name.
		 */
		public function get databaseName():String
		{
			return _databaseName;
		}

		
		/**
		 * Returns the name of the model's primary key.
		 */
		public function get primaryKey():String
		{
			return _primaryKey;
		}


		/**
		 * Returns <code>true</code> if the model exists in the database.
		 */
		public function get exists():Boolean
		{
			return _exists;
		}


		/**
		 * Returns <code>true</code> if the model has an auto-incrementing id.
		 */
		public function get autoIncrementId():Boolean
		{
			return _autoIncrementId;
		}
	}
	
}
