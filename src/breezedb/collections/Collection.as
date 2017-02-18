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

package breezedb.collections
{

	/**
	 * Collection class provides a fluent, convenient wrapper for working with arrays of data.
	 */
	public dynamic class Collection extends Array
	{
		public function Collection(...rest)
		{
			super();

			var length:int = rest.length;
			for(var i:int = 0; i < length; ++i)
			{
				this[i] = rest[i];
			}
		}


		/**
		 * Adds a single element to the end of the collection. If inserting a single element then this method is
		 * preferred to <code>push</code> where new allocation is made due to the <code>rest</code> parameter.
		 *
		 * @param element Element to be added.
		 * @return Reference to the collection, allowing method chaining.
		 */
		public function add(element:*):Collection
		{
			this[length] = element;
			return this;
		}


		/**
		 * Returns the underlying array (a shallow copy) represented by the collection.
		 *
		 * @return Underlying array (a shallow copy) represented by the collection.
		 */
		public function get all():Array
		{
			var result:Array = [];
			var length:int = this.length;
			for(var i:int = 0; i < length; ++i)
			{
				result[i] = this[i];
			}
			return result;
		}


		/**
		 * Returns the average of all items in the collection.
		 *
		 * @param keyOrCallback The parameter can be one of the following:
		 *        <ul>
		 *            <li><code>null</code>: The items are used to find the average.</li>
		 *            <li><code>String</code>: The key on which to find the average value.</li>
		 *            <li><code>Function</code>: Custom callback that returns the value to be averaged.</li>
		 *        </ul>
		 * <listing version="3.0">
		 * var collection:Collection = new Collection( {name: "iPhone 6", price: 549}, {name: "Galaxy S6", price: 399} );
		 * collection.avg("price"); // 474
		 * collection.avg(function(item:Object):Number
		 * {
		 *    return item.price;
		 * }); // 474
		 * </listing>
		 * @return Average of all items in the collection.
		 */
		public function avg(keyOrCallback:* = null):Number
		{
			var length:int = this.length;
			if(length == 0)
			{
				return 0;
			}
			return sum(keyOrCallback) / length;
		}


		/**
		 * Returns the maximum of all items in the collection.
		 *
		 * @param keyOrCallback The parameter can be one of the following:
		 *        <ul>
		 *            <li><code>null</code>: The items are compared to find the maximum.</li>
		 *            <li><code>String</code>: The key on which to find the maximum value.</li>
		 *            <li><code>Function</code>: Custom callback that returns the value to be compared.</li>
		 *        </ul>
		 * <listing version="3.0">
		 * var collection:Collection = new Collection( {name: "iPhone 6", price: 549}, {name: "Galaxy S6", price: 399} );
		 * collection.max("price"); // 549
		 * collection.max(function(item:Object):Number
		 * {
		 *    return item.price;
		 * }); // 549
		 * </listing>
		 * @return Maximum of all items in the collection.
		 */
		public function max(keyOrCallback:* = null):Number
		{
			var length:int = this.length;
			if(length == 0)
			{
				return 0;
			}

			// Invalid parameter type
			if(!(keyOrCallback == null || keyOrCallback is Function || keyOrCallback is String))
			{
				throw new ArgumentError("Parameter keyOrCallback must be a String, Function or null.");
			}

			var result:Number = NaN;

			// No key or callback, just try to find the max element in the collection
			if(keyOrCallback === null)
			{
				for(var i:int = 0; i < length; ++i)
				{
					if(result !== result || result < this[i])
					{
						result = this[i];
					}
				}
				return result;
			}

			// Key provided, try to find max on that key
			if(keyOrCallback is String)
			{
				var key:String = keyOrCallback as String;
				for(i = 0; i < length; ++i)
				{
					var element:Object = this[i];
					var next:Number = (key in element) ? element[key] : Number.MIN_VALUE;
					if(result !== result || result < next)
					{
						result = next;
					}
				}
				if(result == Number.MIN_VALUE)
				{
					result = 0;
				}
				return result;
			}

			// Use the provided callback to retrieve the value
			var valueRetriever:Function = keyOrCallback as Function;
			for(i = 0; i < length; ++i)
			{
				var ret:Number = valueRetriever(this[i]);
				if(ret === ret && (result !== result || result < ret))
				{
					result = ret;
				}
			}

			if(result !== result) // isNaN
			{
				result = 0;
			}
			return result;
		}


		/**
		 * Returns the minimum of all items in the collection.
		 *
		 * @param keyOrCallback The parameter can be one of the following:
		 *        <ul>
		 *            <li><code>null</code>: The items are compared to find the minimum.</li>
		 *            <li><code>String</code>: The key on which to find the minimum value.</li>
		 *            <li><code>Function</code>: Custom callback that returns the value to be compared.</li>
		 *        </ul>
		 * <listing version="3.0">
		 * var collection:Collection = new Collection( {name: "iPhone 6", price: 549}, {name: "Galaxy S6", price: 399} );
		 * collection.min("price"); // 399
		 * collection.min(function(item:Object):Number
		 * {
		 *    return item.price;
		 * }); // 399
		 * </listing>
		 * @return Minimum of all items in the collection.
		 */
		public function min(keyOrCallback:* = null):Number
		{
			var length:int = this.length;
			if(length == 0)
			{
				return 0;
			}

			// Invalid parameter type
			if(!(keyOrCallback == null || keyOrCallback is Function || keyOrCallback is String))
			{
				throw new ArgumentError("Parameter keyOrCallback must be a String, Function or null.");
			}

			var result:Number = NaN;

			// No key or callback, just try to find the min element in the collection
			if(keyOrCallback === null)
			{
				for(var i:int = 0; i < length; ++i)
				{
					if(result !== result || result > this[i])
					{
						result = this[i];
					}
				}
				return result;
			}

			// Key provided, try to find max on that key
			if(keyOrCallback is String)
			{
				var key:String = keyOrCallback as String;
				for(i = 0; i < length; ++i)
				{
					var element:Object = this[i];
					var next:Number = (key in element) ? element[key] : Number.MAX_VALUE;
					if(result !== result || result > next)
					{
						result = next;
					}
				}
				if(result == Number.MAX_VALUE)
				{
					result = 0;
				}
				return result;
			}


			// Invalid parameter type
			if(!(keyOrCallback is Function))
			{
				throw new ArgumentError("Parameter keyOrCallback must be a String, Function or null.");
			}

			// Use the provided callback to retrieve the value
			var valueRetriever:Function = keyOrCallback as Function;
			for(i = 0; i < length; ++i)
			{
				var ret:Number = valueRetriever(this[i]);
				if(ret === ret && (result !== result || result > ret))
				{
					result = ret;
				}
			}

			if(result !== result) // isNaN
			{
				result = 0;
			}
			return result;
		}


		/**
		 * Returns the sum of all items in the collection.
		 *
		 * @param keyOrCallback The parameter can be one of the following:
		 *        <ul>
		 *            <li><code>null</code>: The items in the collections are summed up.</li>
		 *            <li><code>String</code>: The key for the value that is to be summed up.</li>
		 *            <li><code>Function</code>: Custom callback that returns the value to be summed up.</li>
		 *        </ul>
		 * <listing version="3.0">
		 * var collection:Collection = new Collection( {name: "iPhone 6", price: 549}, {name: "Galaxy S6", price: 399} );
		 * collection.sum("price"); // 948
		 * collection.sum(function(item:Object):Number
		 * {
		 *    return item.price;
		 * }); // 948
		 * </listing>
		 * @return Sum of all items in the collection.
		 */
		public function sum(keyOrCallback:* = null):Number
		{
			var length:int = this.length;
			if(length == 0)
			{
				return 0;
			}

			// Invalid parameter type
			if(!(keyOrCallback == null || keyOrCallback is Function || keyOrCallback is String))
			{
				throw new ArgumentError("Parameter keyOrCallback must be a String, Function or null.");
			}

			var result:Number = 0;

			// No key or callback, just try to sum the collection elements
			if(keyOrCallback === null)
			{
				for(var i:int = 0; i < length; ++i)
				{
					result += this[i];
				}
				return result;
			}

			// Key provided, try to sum on that key
			if(keyOrCallback is String)
			{
				var key:String = keyOrCallback as String;
				for(i = 0; i < length; ++i)
				{
					var element:Object = this[i];
					result += (key in element) ? element[key] : 0;
				}
				return result;
			}

			// Use the provided callback to retrieve the value
			var valueRetriever:Function = keyOrCallback as Function;
			for(i = 0; i < length; ++i)
			{
				element = this[i];
				var ret:Number = valueRetriever(element);
				if(ret === ret)
				{
					result += ret;
				}
			}
			return result;
		}
		

		/**
		 * Reduces the collection to a single value, passing the result of each iteration into the subsequent iteration.
		 *
		 * @param callback Function with the following signature:
		 * <listing version="3.0">
		 * function reduceCallback(carry:&#42;, item:&#42;):&#42; {
		 *    return carry + item; // Creates sum of the collection items
		 * };
		 * </listing>
		 * @param initial Initial value for the callback's <code>carry</code> parameter.
		 */
		public function reduce(callback:Function, initial:* = null):*
		{
			if(callback == null)
			{
				throw new ArgumentError( "Parameter callback cannot be null." );
			}

			var next:* = initial;
			var length:int = this.length;
			for(var i:int = 0; i < length; ++i)
			{
				next = callback(next, this[i]);
			}
			return next;
		}


		/**
		 * Returns the first item in the collection that passes the given test. If truth test is not provided then the
		 * first item is returned. If the collection is empty then <code>null</code> is returned.
		 *
		 * @param truthTest Optional truth test:
		 * <listing version="3.0">
		 * var companies:Collection = new Collection(
		 *    { name: "Microsoft", ceo: "Satya Nadella" },
		 *    { name: "Apple",     ceo: "Tim Cook" },
		 *    { name: "Google",    ceo: "Sundar Pichai" },
		 * );
		 * companies.first(truthTest); // { name: "Apple", ceo: "Tim Cook" };
		 * function truthTest(company:Object):Boolean {
		 *    return company.name == "Apple";
		 * };
		 * </listing>
		 * @return The first item in the collection that passes the given test. If truth test is not provided then the
		 * first item is returned. If the collection is empty then <code>null</code> is returned.
		 */
		public function first(truthTest:Function = null):*
		{
			for each(var item:* in this)
			{
				// No truth test, return the first item
				if(truthTest == null)
				{
					return item;
				}

				// Perform truth test
				var passesTest:Boolean = truthTest(item);
				if(passesTest)
				{
					return item;
				}
			}
			return null;
		}


		/**
		 * Returns the last item in the collection that passes the given test. If truth test is not provided then the
		 * last item is returned. If the collection is empty then <code>null</code> is returned.
		 *
		 * @param truthTest Optional truth test:
		 * <listing version="3.0">
		 * var numbers:Collection = new Collection(-3, -2, -1, 0, 1, 2, 3, 4, 5);
		 * numbers.last(truthTest); // -1
		 * function truthTest(n:Number):Boolean {
		 *    return n &lt; 0;
		 * };
		 * </listing>
		 * @return The last item in the collection that passes the given test. If truth test is not provided then the
		 * last item is returned. If the collection is empty then <code>null</code> is returned.
		 */
		public function last(truthTest:Function = null):*
		{
			for(var i:int = length - 1; i >= 0; --i)
			{
				var item:* = this[i];

				// No truth test, return the last item
				if(truthTest == null)
				{
					return item;
				}

				// Perform truth test
				var passesTest:Boolean = truthTest(item);
				if(passesTest)
				{
					return item;
				}
			}
			return null;
		}


		/**
		 * Returns <code>true</code> if the collection contains the given item. Strict equality
		 * operator (<code>===</code>) is used to compare the collection items or their keys.
		 *
		 * @param searchElement The item to find.
		 * @param searchKey The key to perform the search on.
		 * <listing version="3.0">
		 * var devices:Collection = new Collection(
		 *	 {name: "iPhone 6",    brand: "Apple",   price: 549},
		 *	 {name: "iPhone SE",   brand: "Apple",   price: 399},
		 *	 {name: "Galaxy S6",   brand: "Samsung", price: 399}
		 * );
		 * devices.contains("iPhone 6"); // false
		 * devices.contains("iPhone 6", "name"); // true
		 * </listing>
		 * @return <code>true</code> if the collection contains the given item, <code>false</code> otherwise.
		 */
		public function contains(searchElement:*, searchKey:String = null):Boolean
		{
			if(searchElement == null)
			{
				throw new ArgumentError("Parameter searchElement cannot be null.");
			}

			for each(var item:* in this)
			{
				if(searchKey == null)
				{
					if(item === searchElement)
					{
						return true;
					}
				}
				else
				{
					if(searchKey in item && item[searchKey] === searchElement)
					{
						return true;
					}
				}
			}

			return false;
		}


		/**
		 * Returns the value at a given key, or <code>null</code> if the key does not exist.
		 *
		 * @param key Key for which to find the value.
		 * @param defaultValue Default value in case the key is not found, or <code>Function</code> that returns
		 *        the default value.
		 * @return The value at a given key, or <code>null</code> if the key does not exist.
		 */
		public function get(key:String, defaultValue:* = null):*
		{
			if(key == null)
			{
				throw new ArgumentError( "Parameter key cannot be null." );
			}

			for each(var item:* in this)
			{
				if(key in item)
				{
					return item[key];
				}
			}

			return (defaultValue is Function) ? defaultValue() : defaultValue;
		}
		

		/**
		 * Returns <code>true</code> if any item in the collection has the given key.
		 *
		 * @param key Key to find.
		 * @return <code>true</code> if any item in the collection has the given key, <code>false</code> otherwise.
		 */
		public function has(key:String):Boolean
		{
			if(key == null)
			{
				throw new ArgumentError( "Parameter key cannot be null." );
			}

			for each(var item:* in this)
			{
				for( var itemKey:String in item)
				{
					if(itemKey == key)
					{
						return true;
					}
				}
			}
			return false;
		}
		

		/**
		 * Retrieves all values for the given key. This method does not modify the original collection.
		 *
		 * @param key Key for which the values are to be retrieved.
		 * @param keyBy Specifies how the resulting collection will be keyed.
		 * <listing version="3.0">
		 * var devices:Collection = new Collection(
		 *	 {name: "iPhone 6",    brand: "Apple",   price: 549},
		 *	 {name: "iPhone SE",   brand: "Apple",   price: 399},
		 *	 {name: "Galaxy S6",   brand: "Samsung", price: 399}
		 * );
		 * device.pluck("name").all; // ["iPhone 6", "iPhone SE", "Galaxy S6"]
		 * device.pluck("price", "name").all; // [{"iPhone 6": 549}, {"iPhone SE": 399}, {"Galaxy S6": 399}]
		 * </listing>
		 * @return New <code>Collection</code> with all the values for the given key.
		 */
		public function pluck(key:String, keyBy:String = null):Collection
		{
			if(key == null)
			{
				throw new ArgumentError( "Parameter key cannot be null." );
			}

			var result:Collection = new Collection();

			for each(var elem:* in this)
			{
				var value:* = null;
				if(key in elem)
				{
					value = elem[key];
				}
				if(value != null && keyBy != null)
				{
					var pluckedKey:String = (keyBy in elem && elem[keyBy] is String) ? elem[keyBy] : keyBy;
					var plucked:Object = {};
					plucked[pluckedKey] = value;
					value = plucked;
				}
				if(value != null)
				{
					result.add(value);
				}
			}

			return result;
		}


		/**
		 * Adds an item to the beginning of the collection. If inserting a single element then this method is
		 * preferred to <code>unshift</code> where new allocation is made due to the <code>rest</code> parameter.
		 *
		 * @param item Item to be added to the beginning of the collection.
		 * @return Reference to the modified collection, allowing method chaining.
		 */
		public function prepend(item:*):Collection
		{
			if(item === null)
			{
				throw new ArgumentError("Parameter item cannot be null.");
			}

			for(var i:int = length - 1; i >= 0; --i)
			{
				var oldItem:* = this[i];
				this[i + 1] = oldItem;
			}

			this[0] = item;

			return this;
		}


		/**
		 * Removes and returns an item from the collection by its key
		 *
		 * @param key The key used to find the item.
		 * @return The removed item, or <code>null</code> if it was not found.
		 */
		public function pull(key:String):*
		{
			if(key === null)
			{
				throw new ArgumentError("Parameter key cannot be null.");
			}

			var index:int = 0;
			for each(var item:* in this)
			{
				if(key in item)
				{
					this.removeAt(index);
					return item;
				}
				index++;
			}

			return null;
		}
		

		/**
		 * Filters the collection by the given key / value pair. Uses equality operator (<code>==</code>)
		 * to compare item values.
		 *
		 * @param key The key used to find the value.
		 * @param value The value to compare against.
		 * 
		 * <listing version="3.0">
		 * var devices:Collection = new Collection(
		 *	 {name: "iPhone 6",    brand: "Apple",   price: 549},
		 *	 {name: "iPhone SE",   brand: "Apple",   price: 399},
		 *	 {name: "Galaxy S6",   brand: "Samsung", price: 399}
		 * );
		 * var filtered:Collection = devices.where("brand", "Apple");
		 * trace(filtered.all); // [{name: "iPhone 6", brand: "Apple", price: 549}, {name: "iPhone SE", brand: "Apple", price: 399}]
		 * </listing>
		 * 
		 * @return New <code>Collection</code> with the filtered values.
		 *
		 * @see #whereStrict()
		 * @see #whereIn()
		 * @see #whereInStrict()
		 */
		public function where(key:String, value:*):Collection
		{
			return whereInternal(key, value);
		}


		/**
		 * Filters the collection by the given key / value pair. Uses strict equality operator (<code>===</code>)
		 * to compare item values.
		 *
		 * @param key The key used to find the value.
		 * @param value The value to compare against.
		 *
		 * <listing version="3.0">
		 * var devices:Collection = new Collection(
		 *	 {name: "iPhone 6",    brand: "Apple",   price: 549},
		 *	 {name: "iPhone SE",   brand: "Apple",   price: 399},
		 *	 {name: "Galaxy S6",   brand: "Samsung", price: 399}
		 * );
		 * var filtered:Collection = devices.whereStrict("price", 399);
		 * trace(filtered.all); // [{name: "iPhone SE", brand: "Apple", price: 399}, {name: "Galaxy S6", brand: "Samsung", price: 399}]
		 * filtered = devices.whereStrict("price", "399");
		 * trace(filtered.all); // []
		 * </listing>
		 *
		 * @return New <code>Collection</code> with the filtered values.
		 *
		 * @see #where()
		 * @see #whereIn()
		 * @see #whereInStrict()
		 */
		public function whereStrict(key:String, value:*):Collection
		{
			return whereInternal(key, value, true);
		}


		/**
		 * Filters the collection by the given key / value contained within the given array.
		 * Uses equality operator (<code>==</code>) to compare item values.
		 *
		 * @param key The key used to find the value.
		 * @param value List of values to compare against.
		 *
		 * <listing version="3.0">
		 * var devices:Collection = new Collection(
		 *	 {name: "iPhone 6",    brand: "Apple",   price: 549},
		 *	 {name: "Lumia 800",   brand: "Nokia",   price: 199},
		 *	 {name: "Galaxy S6",   brand: "Samsung", price: 399}
		 * );
		 * var filtered:Collection = devices.whereIn("brand", ["Apple", "Samsung"]);
		 * trace(filtered.all); // [{name: "iPhone 6", brand: "Apple", price: 549}, {name: "Galaxy S6", brand: "Samsung", price: 399}]
		 * </listing>
		 *
		 * @return New <code>Collection</code> with the filtered values.
		 *
		 * @see #where()
		 * @see #whereStrict()
		 * @see #whereInStrict()
		 */
		public function whereIn(key:String, value:Array):Collection
		{
			return whereInternal(key, value);
		}


		/**
		 * Filters the collection by the given key / value contained within the given array.
		 * Uses strict equality operator (<code>===</code>) to compare item values.
		 *
		 * @param key The key used to find the value.
		 * @param value List of values to compare against.
		 *
		 * <listing version="3.0">
		 * var devices:Collection = new Collection(
		 *	 {name: "iPhone 6",    brand: "Apple",   price: 549},
		 *	 {name: "iPhone SE",   brand: "Apple",   price: 399},
		 *	 {name: "Galaxy Gear", brand: "Samsung", price: 199}
		 * );
		 * var filtered:Collection = devices.whereInStrict("price", ["199", 399, 549]);
		 * trace(filtered.all); // [{name: "iPhone 6", brand: "Apple", price: 549}, {name: "iPhone SE", brand: "Apple", price: 399}]
		 * </listing>
		 *
		 * @return New <code>Collection</code> with the filtered values.
		 *
		 * @see #where()
		 * @see #whereStrict()
		 * @see #whereIn()
		 */
		public function whereInStrict(key:String, value:Array):Collection
		{
			return whereInternal(key, value, true);
		}


		/**
		 * Internal implementation of <code>where</code> and <code>whereStrict</code>.
		 *
		 * @param key The key used to find the value.
		 * @param value The value to compare against.
		 * @param strict <code>true</code> if strict comparison (<code>===</code>) should be used.
		 * @return New <code>Collection</code> with the filtered values.
		 */
		private function whereInternal(key:String, value:*, strict:Boolean = false):Collection
		{
			if(key === null)
			{
				throw new ArgumentError("Parameter key cannot be null.");
			}
			if(value === null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			var result:Collection = new Collection();
			for each(var item:* in this)
			{
				if(key in item)
				{
					if(value is Array)
					{
						for each(var arrValue:* in value)
						{
							if((strict && item[key] === arrValue) || (!strict && item[key] == arrValue))
							{
								result.add(item);
							}
						}
					}
					else if((strict && item[key] === value) || (!strict && item[key] == value))
					{
						result.add(item);
					}
				}
			}
			return result;
		}


		/**
		 * Similar to <code>indexOf</code> method, this method can be used to find the index for the given value.
		 * Additionally, the <code>value</code> parameter can be a <code>Function</code> that is used as a truth test.
		 *
		 * @param value The value to find or <code>Function</code> to be used as a truth test:
		 * <listing version="3.0">
		 * var companies:Collection = new Collection(
		 *    { name: "Microsoft", ceo: "Satya Nadella" },
		 *    { name: "Apple",     ceo: "Tim Cook" },
		 *    { name: "Google",    ceo: "Sundar Pichai" }
		 * );
		 * companies.search(truthTest); // 1
		 * function truthTest(company:Object):Boolean {
		 *    return company.name == "Apple";
		 * };
		 * </listing>
		 * @param strict Pass in <code>true</code> to use strict equality operator for comparison.
		 * @return A zero-based index position of the item in the array. If it is not found, the return value is -1.
		 */
		public function search(value:*, strict:Boolean = false):int
		{
			if(value === null)
			{
				throw new ArgumentError("Parameter value cannot be null.");
			}

			var i:int;
			var length:uint = this.length;
			if(value is Function)
			{
				for(i = 0; i < length; ++i)
				{
					if(value(this[i]))
					{
						return i;
					}
				}
			}
			else
			{
				for(i = 0; i < length; ++i)
				{
					if((strict && this[i] === value) || (!strict && this[i] == value))
					{
						return i;
					}
				}
			}
			return -1;
		}


		/**
		 * Returns all of the unique items in the collection.
		 *
		 * @param keyOrCallback The parameter can be one of the following:
		 *        <ul>
		 *            <li><code>null</code>: The items are used to determine uniqueness (useful for collection of numbers).</li>
		 *            <li><code>String</code>: The key whose value is used to determine uniqueness.</li>
		 *            <li><code>Function</code>: Custom callback that returns the value to use for determining uniqueness.</li>
		 *        </ul>
		 * <listing version="3.0">
		 * var devices:Collection = new Collection(
		 *	 {name: "iPhone 6",    brand: "Apple",   price: 549},
		 *	 {name: "iPhone SE",   brand: "Apple",   price: 399},
		 *	 {name: "Galaxy Gear", brand: "Samsung", price: 199}
		 * );
		 * devices.unique("brand"); // [{name: "iPhone 6", brand: "Apple", price: 549}, {name: "Galaxy Gear", brand: "Samsung", price: 199}]
		 * devices.unique(uniqueBrandPrice); // [{name: "iPhone 6", brand: "Apple", price: 549}, {name: "iPhone SE", brand: "Apple", price: 399}, {name: "Galaxy Gear", brand: "Samsung", price: 199}]
		 * function uniqueBrandPrice(device:Object):Boolean {
		 *    // Concatenated brand and price to be used for determining uniqueness
		 *    return device.brand + device.price;
		 * };
		 * </listing>
		 *
		 * @return New <code>Collection</code> with the unique values.
		 */
		public function unique(keyOrCallback:* = null):Collection
		{
			// Invalid parameter type
			if(!(keyOrCallback == null || keyOrCallback is Function || keyOrCallback is String))
			{
				throw new ArgumentError("Parameter keyOrCallback must be a String, Function or null.");
			}

			var uniques:Object = {};

			var result:Collection = new Collection();
			for each(var value:* in this)
			{
				var hash:* = value;
				if(keyOrCallback is String)
				{
					if(!(keyOrCallback in value))
					{
						continue;
					}
					hash = value[keyOrCallback];
				}
				else if(keyOrCallback is Function)
				{
					hash = keyOrCallback(value);
				}

				if(uniques[hash] === true)
				{
					continue;
				}

				uniques[hash] = true;
				result.add(value);
			}
			return result;
		}


		/**
		 * Returns <code>true</code> if the collection has no items, <code>false</code> otherwise.
		 */
		public function get isEmpty():Boolean
		{
			return length == 0;
		}


		/**
		 * Creates new <code>Collection</code> from an existing <code>Array</code>.
		 *
		 * @param value The source <code>Array</code>.
		 * @return New <code>Collection</code> with all the elements from the source <code>Array</code>.
		 */
		public static function fromArray(value:Array):Collection
		{
			var collection:Collection = new Collection();

			if(value != null)
			{
				for each(var elem:* in value)
				{
					collection.push(elem);
				}
			}

			return collection;
		}

	}
	
}
