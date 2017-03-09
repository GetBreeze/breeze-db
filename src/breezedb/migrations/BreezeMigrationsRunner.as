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
	import breezedb.collections.Collection;
	import breezedb.events.BreezeMigrationEvent;
	import breezedb.schemas.TableBlueprint;

	import flash.events.EventDispatcher;

	/**
	 * @private
	 */
	public class BreezeMigrationsRunner extends EventDispatcher
	{
		private static const MIGRATIONS_TABLE:String = "breeze_migrations_internal";

		private var _currentIndex:int = -1;

		// True if this runner is in control of the current transaction
		private var _transactionControl:Boolean;

		private var _db:IBreezeDatabase;
		private var _callback:Function;
		private var _migrations:Vector.<BreezeMigration>;
		private var _previousMigrations:Collection;

		public function BreezeMigrationsRunner(db:IBreezeDatabase)
		{
			_db = db;
			_migrations = new <BreezeMigration>[];
		}


		breezedb_internal function run(migrations:*, callback:Function = null):void
		{
			_callback = callback;

			if(migrations is Class)
			{
				migrations = [migrations];
			}

			if(!(migrations is Array) || (migrations.length == 0))
			{
				triggerCallback(new ArgumentError("Migrations can be either a Class or Array of Classes."));
				return;
			}

			var length:int = migrations.length;
			for(var i:int = 0; i < length; ++i)
			{
				var migrationClass:* = migrations[i];
				if(!(migrationClass is Class))
				{
					triggerCallback(new ArgumentError("Migration can be either a Class or Array of Classes."));
					return;
				}
				if(!addMigrationClass(migrationClass))
				{
					triggerCallback(new ArgumentError(migrationClass + " must be a subclass of BreezeMigration."));
					return;
				}
			}

			loadPreviousMigrations();
		}


		private function addMigrationClass(migrationClass:Class):Boolean
		{
			var migration:* = new migrationClass();
			if(!(migration is BreezeMigration))
			{
				return false;
			}
			_migrations[_migrations.length] = migration as BreezeMigration;
			return true;
		}


		private function loadPreviousMigrations():void
		{
			_db.schema.hasTable(MIGRATIONS_TABLE, onMigrationTableSchemaLoaded);
		}


		private function onMigrationTableSchemaLoaded(error:Error, hasTable:Boolean):void
		{
			// Create the table if it does not exist
			if(!hasTable)
			{
				_db.schema.createTable(MIGRATIONS_TABLE, function(table:TableBlueprint):void
				{
					table.string("name").unique();
				}, onMigrationsTableCreated);
			}
			// Otherwise load the table records
			else
			{
				_db.table(MIGRATIONS_TABLE).fetch(onPreviousMigrationsLoaded);
			}
		}


		private function onMigrationsTableCreated(error:Error):void
		{
			if(error == null)
			{
				// Table has just been created, no migrations exist
				onPreviousMigrationsLoaded(null, new Collection());
			}
			// Failed to create the table so fail the current migrations
			else
			{
				triggerCallback(error);
			}
		}


		private function onPreviousMigrationsLoaded(error:Error, previousMigrations:Collection):void
		{
			if(error == null)
			{
				_previousMigrations = previousMigrations;

				// Begin transaction and run the migrations
				if(!_db.inTransaction)
				{
					_transactionControl = true;
					_db.beginTransaction(onTransactionBegan);
				}
				else
				{
					onTransactionBegan(null);
				}
			}
			// Failed to load previous migrations so fail the current migrations
			else
			{
				triggerCallback(error);
			}
		}


		private function onTransactionBegan(error:Error):void
		{
			if(error == null)
			{
				runNextMigration();
			}
			// Failed to begin transaction so fail the migrations
			else
			{
				triggerCallback(error);
			}
		}


		private function runNextMigration():void
		{
			if(_currentIndex >= _migrations.length - 1)
			{
				// Finished migrations successfully, commit the transaction
				if(_transactionControl)
				{
					_db.commit(onTransactionCommitted);
				}
				else
				{
					onTransactionCommitted(null);
				}
				return;
			}

			var migration:BreezeMigration = _migrations[++_currentIndex];
			migration.addEventListener(BreezeMigrationEvent.COMPLETE, onMigrationCompleted);

			// Do not run the migration if it ran in the past
			if(_previousMigrations.contains(migration.name, "name"))
			{
				// Dispatch event with 'didRun' set to false
				migration.dispatchEvent(new BreezeMigrationEvent(BreezeMigrationEvent.COMPLETE, false));
				return;
			}

			// Run the migration now
			migration.run(_db);
		}


		private function onMigrationCompleted(event:BreezeMigrationEvent):void
		{
			var migration:BreezeMigration = event.currentTarget as BreezeMigration;
			migration.removeEventListener(BreezeMigrationEvent.COMPLETE, onMigrationCompleted);

			dispatchEvent(event);

			// If current migration failed then roll back
			if(!event.successful)
			{
				if(_transactionControl)
				{
					_db.rollBack(function(rollBackError:Error):void
					{
						triggerCallback(new Error("Migration '" + migration.name + "' failed."));
					});
				}
				else
				{
					triggerCallback(new Error("Migration '" + migration.name + "' failed."));
				}
			}
			// If the migration ran then store it in the database so that it does not run again in the future
			else if(event.didRun)
			{
				storeMigration(migration);
			}
			// Otherwise run the next migration
			else
			{
				runNextMigration();
			}
		}


		private function storeMigration(migration:BreezeMigration):void
		{
			_db.table(MIGRATIONS_TABLE).insert({ name: migration.name }, function(insertError:Error):void
			{
				// Migration stored successfully, run the next migration
				if(insertError == null)
				{
					runNextMigration();
				}
				// Otherwise roll back and fail the migrations
				else
				{
					if(_transactionControl)
					{
						_db.rollBack(function(rollBackError:Error):void
						{
							triggerCallback(insertError);
						});
					}
					else
					{
						triggerCallback(insertError);
					}
				}
			});
		}


		private function onTransactionCommitted(error:Error):void
		{
			triggerCallback(error);
		}


		private function triggerCallback(error:Error = null):void
		{
			var callback:Function = _callback;
			_callback = null;
			if(callback != null)
			{
				callback(error);
			}
		}
		
	}
	
}
