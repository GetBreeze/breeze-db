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

package collections
{
	import breezedb.collections.Collection;

	import breezetest.Assert;
	
	public class TestCollection
	{
		private var _numberCollection:Collection;
		private var _objectCollection:Collection;


		public function setup():void
		{
			_numberCollection = new Collection(-3, -2, -1, 0, 1, 2, 3, 4, 5);
			_objectCollection = new Collection(
					{name: "iPhone 6",    brand: "Apple",   type: "phone", price: 549},
					{name: "iPhone SE",   brand: "Apple",   type: "phone", price: 399},
					{name: "Apple Watch", brand: "Apple",   type: "watch", price: 299},
					{name: "Galaxy S6",   brand: "Samsung", type: "phone", price: 399},
					{name: "Galaxy Gear", brand: "Samsung", type: "watch", price: 199}
			);
		}


		public function testAdd():void
		{
			var emptyCollection:Collection = new Collection();

			Assert.equals(0, emptyCollection.length);

			emptyCollection.add("Element");

			Assert.equals(1, emptyCollection.length);

			Assert.arrayEquals(["Element"], emptyCollection.all);
		}
		

		public function testAll():void
		{
			var emptyCollection:Collection = new Collection();
			var emptyAll:Array = emptyCollection.all;

			Assert.isNotNull(emptyAll);
			Assert.equals(0, emptyAll.length);
			Assert.arrayEquals([], emptyAll);

			var all:Array = _numberCollection.all;

			Assert.isNotNull(all);
			Assert.equals(9, all.length);
			Assert.arrayEquals([-3, -2, -1, 0, 1, 2, 3, 4, 5], all);
		}


		public function testAvg():void
		{
			var avgNums:Number = _numberCollection.avg();

			Assert.equals(1, avgNums);

			var avgMissingKey:Number = _numberCollection.avg("missingKey");

			Assert.equals(0, avgMissingKey);

			var avgEmpty:Number = new Collection().avg();

			Assert.equals(0, avgEmpty);

			var avgKey:Number = _objectCollection.avg("price");

			Assert.equals(369, avgKey);

			var avgCallback:Number = _objectCollection.avg(function(el:*):Number
			{
				return el.price;
			});

			Assert.equals(369, avgCallback);

			var avgCallbackMissingKey:Number = _objectCollection.avg(function(el:*):Number
			{
				return el.missingKey;
			});

			Assert.equals(0, avgCallbackMissingKey);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_objectCollection.avg(["price"]);
			}, ArgumentError);
		}


		public function testMax():void
		{
			var maxNums:Number = _numberCollection.max();

			Assert.equals(5, maxNums);

			var maxMissingKey:Number = _numberCollection.max("missingKey");

			Assert.equals(0, maxMissingKey);

			var maxEmpty:Number = new Collection().max();

			Assert.equals(0, maxEmpty);

			var maxKey:Number = _objectCollection.max("price");

			Assert.equals(549, maxKey);

			var maxCallback:Number = _objectCollection.max(function(el:*):Number
			{
				return el.price;
			});

			Assert.equals(549, maxCallback);

			var maxCallbackMissingKey:Number = _objectCollection.max(function(el:*):Number
			{
				return el.missingKey;
			});

			Assert.equals(0, maxCallbackMissingKey);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_objectCollection.max(["price"]);
			}, ArgumentError);
		}


		public function testMin():void
		{
			var minNums:Number = _numberCollection.min();

			Assert.equals(-3, minNums);

			var minMissingKey:Number = _numberCollection.min("missingKey");

			Assert.equals(0, minMissingKey);

			var minEmpty:Number = new Collection().min();

			Assert.equals(0, minEmpty);

			var minKey:Number = _objectCollection.min("price");

			Assert.equals(199, minKey);

			var minCallback:Number = _objectCollection.min(function(el:*):Number
			{
				return el.price;
			});

			Assert.equals(199, minCallback);

			var minCallbackMissingKey:Number = _objectCollection.min(function(el:*):Number
			{
				return el.missingKey;
			});

			Assert.equals(0, minCallbackMissingKey);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_objectCollection.min(["price"]);
			}, ArgumentError);
		}
		
		
		public function testSum():void
		{
			var sumNums:Number = _numberCollection.sum();

			Assert.equals(9, sumNums);

			var sumMissingKey:Number = _numberCollection.sum("missingKey");

			Assert.equals(0, sumMissingKey);

			var sumEmpty:Number = new Collection().sum();

			Assert.equals(0, sumEmpty);

			var sumKey:Number = _objectCollection.sum("price");

			Assert.equals(1845, sumKey);

			var sumCallback:Number = _objectCollection.sum(function(el:*):Number
			{
				return el.price;
			});

			Assert.equals(1845, sumCallback);

			var sumCallbackMissingKey:Number = _objectCollection.sum(function(el:*):Number
			{
				return el.missingKey;
			});

			Assert.equals(0, sumCallbackMissingKey);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_objectCollection.sum(["price"]);
			}, ArgumentError);
		}


		public function testReduce():void
		{
			var initial:int = 0;
			var empty:Collection = new Collection();

			Assert.equals(initial, empty.reduce(reduceToSum, initial));
			Assert.equals(9, _numberCollection.reduce(reduceToSum, initial));
			Assert.throwsError(function():void
			{
				// Invalid callback
				empty.reduce(null);
			}, ArgumentError);

			function reduceToSum(carry:*, item:*):*
			{
				return carry + item;
			}
		}
		
		
		public function testFirst():void
		{
			var empty:Collection = new Collection();
			Assert.isNull(empty.first());

			// First object in the collection
			var iPhone6:Object = {name: "iPhone 6", brand: "Apple", type: "phone", price: 549};
			var device:Object = _objectCollection.first();
			Assert.isNotNull(device);
			Assert.equals(iPhone6.name, device.name);
			Assert.equals(iPhone6.brand, device.brand);
			Assert.equals(iPhone6.type, device.type);
			Assert.equals(iPhone6.price, device.price);

			// First object with type "phone" and "price" equal to 399
			var iPhoneSE:Object = {name: "iPhone SE", brand: "Apple", type: "phone", price: 399};
			device = _objectCollection.first(function(item:Object):Boolean
			{
				return item.type == "phone" && item.price == 399;
			});
			Assert.isNotNull(device);
			Assert.equals(iPhoneSE.name, device.name);
			Assert.equals(iPhoneSE.brand, device.brand);
			Assert.equals(iPhoneSE.type, device.type);
			Assert.equals(iPhoneSE.price, device.price);

			Assert.equals(-3, _numberCollection.first());
			Assert.equals(1, _numberCollection.first(function(item:Number):Boolean
			{
				return item > 0;
			}));
		}


		public function testLast():void
		{
			var empty:Collection = new Collection();

			Assert.isNull(empty.last());

			// Last object in the collection
			var device:Object = {name: "Galaxy Gear", brand: "Samsung", type: "watch", price: 199};
			var lastDevice:Object = _objectCollection.last();

			Assert.isNotNull(lastDevice);
			Assert.equals(device.name, lastDevice.name);
			Assert.equals(device.brand, lastDevice.brand);
			Assert.equals(device.type, lastDevice.type);
			Assert.equals(device.price, lastDevice.price);

			// Last object of brand "Apple"
			device = {name: "Apple Watch", brand: "Apple", type: "watch", price: 299};
			lastDevice = _objectCollection.last(function(item:Object):Boolean
			{
				return item.brand == "Apple";
			});

			Assert.isNotNull(lastDevice);
			Assert.equals(device.name, lastDevice.name);
			Assert.equals(device.brand, lastDevice.brand);
			Assert.equals(device.type, lastDevice.type);
			Assert.equals(device.price, lastDevice.price);

			Assert.equals(5, _numberCollection.last());
			Assert.equals(-1, _numberCollection.last(function(item:Number):Boolean
			{
				return item < 0;
			}));
		}
		
		
		public function testIsEmpty():void
		{
			var empty:Collection = new Collection();

			Assert.isTrue(empty.isEmpty);

			empty.add(1);

			Assert.isFalse(empty.isEmpty);

			Assert.isFalse(_objectCollection.isEmpty);
			Assert.isFalse(_numberCollection.isEmpty);
		}
		
		
		public function testContains():void
		{
			var empty:Collection = new Collection();

			Assert.isFalse(empty.contains(1));

			Assert.isTrue(_numberCollection.contains(-1));
			Assert.isTrue(_numberCollection.contains(0));
			Assert.isFalse(_numberCollection.contains(-4));
			Assert.isFalse(_numberCollection.contains(0.1));
			Assert.isFalse(_numberCollection.contains(0, "missingKey"));

			// Iteration over keys
			Assert.isTrue(_objectCollection.contains("iPhone 6", "name"));
			Assert.isFalse(_objectCollection.contains("iPhone 6"));
			Assert.isFalse(_objectCollection.contains("iPhone 7", "name"));
			Assert.isTrue(_objectCollection.contains("phone", "type"));
			Assert.isFalse(_objectCollection.contains("tablet", "type"));

			Assert.throwsError(function():void
			{
				// Invalid argument
				empty.contains(null);
			}, ArgumentError);
		}


		public function testHas():void
		{
			var empty:Collection = new Collection();

			Assert.isFalse(empty.has("missingKey"));

			Assert.isTrue(_objectCollection.has("name"));
			Assert.isFalse(_objectCollection.has("year"));
			Assert.isFalse(_numberCollection.has("name"));

			Assert.throwsError(function():void
			{
				// Invalid argument
				empty.has(null);
			}, ArgumentError);
		}


		public function testGet():void
		{
			var empty:Collection = new Collection();

			Assert.isNull(empty.get("missingKey"));
			Assert.equals("defaultValue", empty.get("missingKey", "defaultValue"));

			var deviceToPrice:Collection = new Collection(
				{"iPhone 6": 549},
				{"iPhone SE": 399},
				{"Apple Watch": 299},
				{"Galaxy S6": 399},
				{"Galaxy Gear": 199}
			);

			Assert.equals(399, deviceToPrice.get("iPhone SE"));

			Assert.equals(-1, _numberCollection.get("index", function():Number
			{
				return -1;
			}));
		}
		
	}
	
}
