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
		
		
		override public function fetch(callback:* = null):BreezeQueryBuilder
		{
			if(_callbackProxy == null || _callbackProxy != onFirstCompleted)
			{
				_callbackProxy = onFetchCompleted;
			}
			return super.fetch(callback);
		}
		
		
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


		public function firstOrNew(values:Object, callback:* = null):BreezeQueryBuilder
		{
			throw new Error("Not implemented");
		}


		public function firstOrCreate(values:Object, callback:* = null):BreezeQueryBuilder
		{
			throw new Error("Not implemented");
		}


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
			return insertGetId(model.toKeyValue(), callback).queryReference;
		}


		/**
		 *
		 * Proxy callbacks
		 *
		 * Cast query response to model's class.
		 *
		 */


		override protected function onFirstCompleted(error:Error, results:Collection):void
		{
			var result:Object = (results.length > 0) ? results[0] : null;
			var model:BreezeModel = null;
			if(result != null)
			{
				model = new _modelClass();
				model.populateFromObject(result);
			}
			finishProxiedQuery([error, model]);
		}
		
		
		override protected function onChunkCompleted(error:Error, results:Collection):void
		{
			var castCollection:Collection = getTypedCollection(results);
			super.onChunkCompleted(error, castCollection);
		}


		protected function onFetchCompleted(error:Error, results:Collection):void
		{
			var castCollection:Collection = getTypedCollection(results);
			finishProxiedQuery([error, castCollection]);
		}


		protected function onUpdateViaSaveCompleted(error:Error, rowsAffected:int):void
		{
			finishProxiedQuery([error, _model]);
		}


		protected function onInsertViaSaveCompleted(error:Error, result:BreezeSQLResult):void
		{
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
