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

package breezedb
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	internal class BreezeDbInstance extends EventDispatcher implements IDatabase
	{
		private var _isSetup:Boolean;
		private var _name:String;
		private var _file:File;
		private var _encryptionKey:String;
		
		public function BreezeDbInstance(name:String)
		{
			if(name == null)
			{
				throw new ArgumentError("Database name cannot be null.");
			}

			_name = name;
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
		public function setup(callback:Function, databaseFile:File = null):void
		{

		}


		/**
		 * @inheritDoc
		 */
		public function table(tableName:String):IQueryBuilder
		{
			return new BreezeQueryBuilder(this, tableName);
		}


		/**
		 * @inheritDoc
		 */
		public function beginTransaction():void
		{
		}


		/**
		 * @inheritDoc
		 */
		public function commit():void
		{
		}


		/**
		 * @inheritDoc
		 */
		public function rollBack():void
		{
		}


		/**
		 * @inheritDoc
		 */
		public function close(callback:Function):void
		{

		}


		/**
		 *
		 *
		 * Private API
		 *
		 *
		 */


		/**
		 *
		 *
		 * Getters / Setters
		 *
		 *
		 */


		/**
		 * @inheritDoc
		 */
		public function set encryptionKey(value:String):void
		{
			if(_isSetup)
			{
				throw new IllegalOperationError("Encryption key must be set before calling setup().")
			}

			_encryptionKey = value;
		}


		/**
		 * @inheritDoc
		 */
		public function get encryptionKey():String
		{
			return _encryptionKey;
		}


		/**
		 * @inheritDoc
		 */
		public function get file():File
		{
			return _file;
		}


		/**
		 * @inheritDoc
		 */
		public function get name():String
		{
			return _name;
		}


		/**
		 * @inheritDoc
		 */
		public function get isSetup():Boolean
		{
			return _isSetup;
		}
	}
	
}
