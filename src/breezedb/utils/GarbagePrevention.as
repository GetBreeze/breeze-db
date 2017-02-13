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

package breezedb.utils
{

	/**
	 * Utility class that prevents garbage collection on objects until told to delete them.
	 * @private
	 */
	public class GarbagePrevention
	{
		private static var _instance:GarbagePrevention;

		private var _objects:Array = [];


		public function GarbagePrevention()
		{

		}


		public function add(object:*):void
		{
			_objects.push(object);
		}


		public function addOnce(object:*):void
		{
			if(!contains(object))
			{
				add(object);
			}
		}


		public function remove(object:*):Boolean
		{
			var index:int = _objects.indexOf(object);
			if(index > -1)
			{
				_objects.removeAt(index);
				return true;
			}

			return false;
		}


		public function removeAll():void
		{
			_objects.length = 0;
		}


		public function contains(object:*):Boolean
		{
			return _objects.indexOf(object) > -1;
		}


		public static function get instance():GarbagePrevention
		{
			if(_instance == null)
			{
				_instance = new GarbagePrevention();
			}

			return _instance;
		}
		
	}
	
}
