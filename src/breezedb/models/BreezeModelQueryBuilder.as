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
	import breezedb.IBreezeDatabase;
	import breezedb.collections.Collection;
	import breezedb.queries.BreezeQueryBuilder;
	import breezedb.queries.BreezeQueryReference;
	import breezedb.queries.BreezeSQLResult;
	import breezedb.utils.Callback;
	import breezedb.utils.GarbagePrevention;

	import flash.errors.IllegalOperationError;

	/**
	 * Class providing API to run queries on a table associated with the given model.
	 */
	public class BreezeModelQueryBuilder extends BreezeQueryBuilder
	{
		private var _model:BreezeModel;
		private var _modelClass:Class;

		/**
		 * Creates a new builder and associates it with a table of the given model.
		 *
		 * @param modelClass The model used to obtain database and table against which the queries will be executed.
		 */
		public function BreezeModelQueryBuilder(modelClass:Class)
		{
			_modelClass = modelClass;
			_model = new modelClass();
			var db:IBreezeDatabase = BreezeDb.getDb(_model.databaseName);
			super(db, _model.tableName);
		}


		/**
		 *
		 *
		 * Public API
		 *
		 *
		 */


		/**
		 * @inheritDoc
         */
		override public function fetch(callback:* = null):BreezeQueryBuilder
		{
			if(_callbackProxy == null || _callbackProxy != onFirstCompleted)
			{
				_callbackProxy = onFetchCompleted;
			}
			return super.fetch(callback);
		}


		/**
		 * Finds models that match the given primary keys.
		 *
		 * @param primaryKeys Either a single primary key or <code>Array</code> of primary keys.
		 * @param callback This parameter can be one of the following:
		 * <ul>
		 *    <li>A <code>Function</code>, i.e. a callback that is triggered once the query is completed.
		 *    Its signature depends on whether a single or multiple primary keys are passed to the the
		 *    <code>primaryKeys</code> parameter:
		 *    <listing version="3.0">
		 *    // Find a single photo with primary key = 1
		 *    var modelBuilder:BreezeModelQueryBuilder = new BreezeModelQueryBuilder(Photo);
		 *    modelBuilder.find(1, callback);
		 *    function callback(error:Error, photo:Photo):void
		 *    {
		 *    };
		 *    // Find multiple photos with primary keys 1 and 2
		 *    var modelBuilder:BreezeModelQueryBuilder = new BreezeModelQueryBuilder(Photo);
		 *    modelBuilder.find([1, 2], callback);
		 *    function callback(error:Error, photos:Collection):void
		 *    {
		 *    };
		 *    </listing>
		 *    </li>
		 *    <li>The <code>BreezeDb.DELAY</code> constant, resulting in the query being delayed. It can be executed
		 *    later by calling the <code>exec</code> method on the returned instance of <code>BreezeQueryBuilder</code>.
		 *    </li>
		 * </ul>
		 *
         * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain the query reference
		 * 		   or execute the query at later time if it was delayed.
         */
		public function find(primaryKeys:*, callback:* = null):BreezeQueryBuilder
		{
			if(primaryKeys == null)
			{
				throw new ArgumentError("Parameter primaryKeys cannot be null.");
			}

			if(_model.primaryKey == null)
			{
				throw new IllegalOperationError("The model " + _modelClass + " has no primary key set.");
			}

			// Fetch all the records whose id matches one of the value in the given array
			if(primaryKeys is Array)
			{
				return whereIn(_model.primaryKey, primaryKeys).fetch(callback);
			}

			// We are looking for a single value so use the callback proxy of the 'first' method
			_callbackProxy = onFirstCompleted;
			return where(_model.primaryKey, primaryKeys).fetch(callback);
		}


		/**
		 * Returns the first model that matches the given values. If match is not found, a new model instance
		 * with those values is returned. Note this instance is <strong>not</strong> saved to the database.
		 * You will need to call the model's <code>save</code> method.
		 *
		 * @param values Key-value object specifying column names and values that will be used to find the matching model.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * // Find or return new instance of Photo model with title "Sunset"
		 * var modelBuilder:BreezeModelQueryBuilder = new BreezeModelQueryBuilder(Photo);
		 * modelBuilder.firstOrNew({ title: "Sunset" }, callback);
		 * function callback(error:Error, photo:Photo):void
		 * {
		 * };
		 * </listing>
		 *
		 * @see #firstOrCreate()
         */
		public function firstOrNew(values:Object, callback:Function = null):void
		{
			firstOrInit(values, callback);
		}


		/**
		 * Returns the first model that matches the given values. If match is not found, a new model instance
		 * with those values is returned and saved to the database.
		 *
		 * @param values Key-value object specifying column names and values that will be used to find the matching model.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * // Find or create new instance of Photo model with title "Sunset"
		 * var modelBuilder:BreezeModelQueryBuilder = new BreezeModelQueryBuilder(Photo);
		 * modelBuilder.firstOrNew({ title: "Sunset" }, callback);
		 * function callback(error:Error, photo:Photo):void
		 * {
		 *     if(error == null)
		 *     {
		 *         trace(photo.exists); // true
		 *     }
		 * };
		 * </listing>
		 *
		 * @see #firstOrNew()
		 */
		public function firstOrCreate(values:Object, callback:Function = null):void
		{
			firstOrInit(values, callback, true);
		}


		/**
		 * Removes all the models that match the given primary keys.
		 * 
		 * @param primaryKeys Either a single primary key or <code>Array</code> of primary keys.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * // Remove photos with id of 1 and 2
		 * var modelBuilder:BreezeModelQueryBuilder = new BreezeModelQueryBuilder(Photo);
		 * modelBuilder.removeByKey([1, 2], callback);
		 * function callback(error:Error):void
		 * {
		 *    if(error == null)
		 *    {
		 *
		 *    }
		 * };
		 * </listing>
		 *
		 * @return Instance of <code>BreezeQueryBuilder</code> allowing you to obtain the query reference
		 * 		   or execute the query at later time if it was delayed.
         */
		public function removeByKey(primaryKeys:*, callback:* = null):BreezeQueryBuilder
		{
			if(primaryKeys == null)
			{
				throw new ArgumentError("Parameter primaryKeys cannot be null.");
			}

			if(_model.primaryKey == null || !(_model.primaryKey in _model))
			{
				throw new IllegalOperationError("The model " + _modelClass + " has no primary key set.");
			}

			if(primaryKeys is Array)
			{
				whereIn(_model.primaryKey, primaryKeys);
			}
			else
			{
				where(_model.primaryKey, primaryKeys);
			}

			return remove(callback);
		}


		/**
		 *
		 *
		 * Internal / Private API
		 *
		 *
		 */


		private function getTypedCollection(collection:Collection):Collection
		{
			var castCollection:Collection = new Collection();

			// Cast each Object to model object
			for(var i:int = 0; i < collection.length; i++)
			{
				var model:BreezeModel = new _modelClass();
				model.populateFromObject(collection[i]);
				castCollection.add(model);
			}

			return castCollection;
		}


		/**
		 * Internal implementation for 'firstOrNew' and 'firstOrCreate'.
		 */
		private function firstOrInit(values:Object, callback:Function = null, saveToDatabase:Boolean = false):void
		{
			if(values == null)
			{
				throw new ArgumentError("Parameter values cannot be null.");
			}

			// Add 'where' clause for each key-value
			for(var key:String in values)
			{
				where(key, values[key]);
			}

			var self:BreezeModelQueryBuilder = this;

			// Retrieve the first model matching the given values
			first(function(firstError:Error, model:BreezeModel):void
			{
				// Match not found, create new model
				if(model == null)
				{
					model = new _modelClass();
					model.populateFromObject(values, false);

					// Save the model first then trigger the callback
					if(saveToDatabase)
					{
						GarbagePrevention.instance.add(self);
						model.save(function(saveError:Error, savedModel:BreezeModel):void
						{
							GarbagePrevention.instance.remove(self);
							Callback.call(callback, [saveError, model]);
						});
						return;
					}
				}

				// Create the model with the next available id
				if(!model.exists && model.autoIncrementId && !hasSetId(model))
				{
					model[model.primaryKey] = _db.connection.lastInsertRowID + 1;
				}
				Callback.call(callback, [firstError, model]);
			});
		}


		/**
		 * @private
		 */
		internal function save(model:BreezeModel, callback:Function = null):BreezeQueryReference
		{
			_model = model;

			// Perform update
			if(model.exists)
			{
				// We need the primary key to do that
				if(model.primaryKey == null || !(model.primaryKey in model))
				{
					throw new IllegalOperationError("Cannot update model " + model + " when the primary key is unknown.");
				}

				_callbackProxy = onUpdateViaSaveCompleted;
				return where(model.primaryKey, model[model.primaryKey])
						.update(model.toKeyValue(), callback)
						.queryReference;
			}

			// Perform insertGetId
			_callbackProxy = onInsertViaSaveCompleted;

			// Omit the primary key in the insert statement to have one assigned automatically via auto-increment
			var omitPrimaryKey:Boolean = (model.autoIncrementId) && !hasSetId(model);
			return insertGetId(model.toKeyValue(omitPrimaryKey), callback).queryReference;
		}


		private function hasSetId(model:BreezeModel):Boolean
		{
			return !((model.primaryKey != null) && (model.primaryKey in model) && (model[model.primaryKey] is Number) && (model[model.primaryKey] < 1));
		}


		/**
		 *
		 * Proxy callbacks
		 *
		 * Cast query response to model's class.
		 *
		 */


		/**
		 * @private
		 */
		override protected function onFirstCompleted(error:Error, results:Collection):void
		{
			_callbackProxy = null;

			var result:Object = (results.length > 0) ? results[0] : null;
			var model:BreezeModel = null;
			if(result != null)
			{
				model = new _modelClass();
				model.populateFromObject(result);
			}
			finishProxiedQuery([error, model]);
		}
		

		/**
		 * @private
		 */
		override protected function onChunkCompleted(error:Error, results:Collection):void
		{
			var castCollection:Collection = getTypedCollection(results);
			super.onChunkCompleted(error, castCollection);
		}


		/**
		 * @private
		 */
		protected function onFetchCompleted(error:Error, results:Collection):void
		{
			_callbackProxy = null;

			var castCollection:Collection = getTypedCollection(results);
			finishProxiedQuery([error, castCollection]);
		}


		/**
		 * @private
		 */
		protected function onUpdateViaSaveCompleted(error:Error, rowsAffected:int):void
		{
			_callbackProxy = null;

			finishProxiedQuery([error, _model]);
		}


		/**
		 * @private
		 */
		protected function onInsertViaSaveCompleted(error:Error, result:BreezeSQLResult):void
		{
			_callbackProxy = null;

			if(error == null)
			{
				if(_model.primaryKey != null &&
						_model.autoIncrementId &&
						_model.hasOwnProperty(_model.primaryKey) &&
						(_model[_model.primaryKey] is Number))
				{
					_model[_model.primaryKey] = result.lastInsertRowID;
				}
				_model.setExists(true);
			}
			finishProxiedQuery([error, _model]);
		}
	}
	
}
