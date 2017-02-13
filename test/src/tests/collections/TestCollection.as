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

package tests.collections
{
	import breezedb.collections.Collection;

	import breezetest.Assert;
	
	public class TestCollection
	{
		private var _numberCollection:Collection;
		private var _objectCollection:Collection;
		private var _emptyCollection:Collection;


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
			_emptyCollection = new Collection();
		}


		public function testAdd():void
		{
			Assert.equals(0, _emptyCollection.length);

			_emptyCollection.add("Element");

			Assert.equals(1, _emptyCollection.length);

			Assert.arrayEquals(["Element"], _emptyCollection.all);
		}
		

		public function testAll():void
		{
			var emptyAll:Array = _emptyCollection.all;

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

			var avgEmpty:Number = _emptyCollection.avg();

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

			var maxEmpty:Number = _emptyCollection.max();

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

			var minEmpty:Number = _emptyCollection.min();

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

			var sumEmpty:Number = _emptyCollection.sum();

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

			Assert.equals(initial, _emptyCollection.reduce(reduceToSum, initial));
			Assert.equals(9, _numberCollection.reduce(reduceToSum, initial));
			Assert.throwsError(function():void
			{
				// Invalid callback
				_emptyCollection.reduce(null);
			}, ArgumentError);

			function reduceToSum(carry:*, item:*):*
			{
				return carry + item;
			}
		}
		
		
		public function testFirst():void
		{
			Assert.isNull(_emptyCollection.first());

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
			Assert.isNull(_emptyCollection.last());

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
			Assert.isTrue(_emptyCollection.isEmpty);

			_emptyCollection.add(1);

			Assert.isFalse(_emptyCollection.isEmpty);

			Assert.isFalse(_objectCollection.isEmpty);
			Assert.isFalse(_numberCollection.isEmpty);
		}
		
		
		public function testContains():void
		{
			Assert.isFalse(_emptyCollection.contains(1));

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
				_emptyCollection.contains(null);
			}, ArgumentError);
		}


		public function testHas():void
		{
			Assert.isFalse(_emptyCollection.has("missingKey"));

			Assert.isTrue(_objectCollection.has("name"));
			Assert.isFalse(_objectCollection.has("year"));
			Assert.isFalse(_numberCollection.has("name"));

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.has(null);
			}, ArgumentError);
		}


		public function testGet():void
		{
			Assert.isNull(_emptyCollection.get("missingKey"));
			Assert.equals("defaultValue", _emptyCollection.get("missingKey", "defaultValue"));

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

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.get(null);
			}, ArgumentError);
		}


		public function testPluck():void
		{
			Assert.isNotNull(_emptyCollection.pluck("missingKey"));
			Assert.arrayEquals([], _emptyCollection.pluck("missingKey").all);

			Assert.isNotNull(_numberCollection.pluck("missingKey"));
			Assert.arrayEquals([], _numberCollection.pluck("missingKey").all);

			var deviceNames:Collection = _objectCollection.pluck("name");
			Assert.isNotNull(deviceNames);
			Assert.arrayEquals(
					["iPhone 6", "iPhone SE", "Apple Watch", "Galaxy S6", "Galaxy Gear"],
					deviceNames.all
			);

			var plucked:Collection = _objectCollection.pluck("price", "name");

			Assert.isNotNull(plucked);
			Assert.notSame(_objectCollection, plucked);
			Assert.equals(5, plucked.all.length);

			var deviceToPrice:Collection = new Collection(
					{"iPhone 6": 549},
					{"iPhone SE": 399},
					{"Apple Watch": 299},
					{"Galaxy S6": 399},
					{"Galaxy Gear": 199}
			);
			for each(var deviceName:String in deviceNames)
			{
				Assert.isNotNull(plucked.get(deviceName));
				Assert.equals(plucked.get(deviceName), deviceToPrice.get(deviceName));
			}

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.pluck(null);
			}, ArgumentError);
		}


		public function testPrepend():void
		{
			Assert.isNull(_emptyCollection.first());

			_emptyCollection.prepend("prepend");

			Assert.equals("prepend", _emptyCollection.first());
			Assert.equals("prepend", _emptyCollection[0]);

			_emptyCollection.prepend("prepend2");

			Assert.equals("prepend2", _emptyCollection.first());
			Assert.equals("prepend2", _emptyCollection[0]);
			Assert.equals("prepend", _emptyCollection.last());

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.prepend(null);
			}, ArgumentError);
		}


		public function testPull():void
		{
			Assert.isNull(_emptyCollection.pull("missingKey"));
			Assert.isNull(_numberCollection.pull("missingKey"));

			var deviceToPrice:Collection = new Collection(
					{"iPhone 6": 549},
					{"iPhone SE": 399},
					{"Apple Watch": 299},
					{"Galaxy S6": 399},
					{"Galaxy Gear": 199}
			);

			Assert.equals(5, deviceToPrice.length);
			Assert.isTrue(deviceToPrice.contains(299, "Apple Watch"));

			var pulled:Object = deviceToPrice.pull("Apple Watch");

			Assert.isNotNull(pulled);
			Assert.isTrue("Apple Watch" in pulled);
			Assert.equals(299, pulled["Apple Watch"]);
			Assert.equals(4, deviceToPrice.length);
			Assert.isFalse(deviceToPrice.contains(299, "Apple Watch"));

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.pull(null);
			}, ArgumentError);
		}


		public function testWhere():void
		{
			var filtered:Collection = _emptyCollection.where("empty", "empty");

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _emptyCollection);
			Assert.isTrue(filtered.isEmpty);

			filtered = _objectCollection.where("brand", "Samsung");

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.equals(2, filtered.length);
			Assert.equals("Galaxy S6", filtered.first().name);
			Assert.equals("Galaxy Gear", filtered.last().name);

			// Non-strict filtering of int price values using String
			filtered = _objectCollection.where("price", "399");

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.equals(2, filtered.length);
			Assert.equals("iPhone SE", filtered.first().name);
			Assert.equals("Galaxy S6", filtered.last().name);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.where(null, "");
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.where("", null);
			}, ArgumentError);
		}


		public function testWhereStrict():void
		{
			var filtered:Collection = _emptyCollection.whereStrict("empty", "empty");

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _emptyCollection);
			Assert.isTrue(filtered.isEmpty);

			filtered = _objectCollection.whereStrict("brand", "Samsung");

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.equals(2, filtered.length);
			Assert.equals("Galaxy S6", filtered.first().name);
			Assert.equals("Galaxy Gear", filtered.last().name);

			// Strict filtering of int price values using String (i.e. no match)
			filtered = _objectCollection.whereStrict("price", "399");

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.isTrue(filtered.isEmpty);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.whereStrict(null, "");
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.whereStrict("", null);
			}, ArgumentError);
		}


		public function testWhereIn():void
		{
			var filtered:Collection = _emptyCollection.whereIn("empty", ["empty"]);

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _emptyCollection);
			Assert.isTrue(filtered.isEmpty);

			filtered = _objectCollection.whereIn("brand", ["Samsung", "Apple"]);

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.equals(5, filtered.length);
			Assert.equals("iPhone 6", filtered.first().name);
			Assert.equals("iPhone SE", filtered[1].name);
			Assert.equals("Apple Watch", filtered[2].name);
			Assert.equals("Galaxy S6", filtered[3].name);
			Assert.equals("Galaxy Gear", filtered.last().name);

			// Strict filtering of int price values using String
			filtered = _objectCollection.whereIn("price", ["199", 299]);

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.equals(2, filtered.length);
			Assert.equals("Apple Watch", filtered.first().name);
			Assert.equals("Galaxy Gear", filtered.last().name);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.whereIn(null, []);
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.whereIn("", null);
			}, ArgumentError);
		}


		public function testWhereInStrict():void
		{
			var filtered:Collection = _emptyCollection.whereInStrict("empty", ["empty"]);

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _emptyCollection);
			Assert.isTrue(filtered.isEmpty);

			filtered = _objectCollection.whereInStrict("brand", ["Samsung", "Apple"]);

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.equals(5, filtered.length);
			Assert.equals("iPhone 6", filtered.first().name);
			Assert.equals("iPhone SE", filtered[1].name);
			Assert.equals("Apple Watch", filtered[2].name);
			Assert.equals("Galaxy S6", filtered[3].name);
			Assert.equals("Galaxy Gear", filtered.last().name);

			// Strict filtering of int price values using String (i.e. no match)
			filtered = _objectCollection.whereInStrict("price", ["399", 299]);

			Assert.isNotNull(filtered);
			Assert.notSame(filtered, _objectCollection);
			Assert.equals(1, filtered.length);
			Assert.equals("Apple Watch", filtered.first().name);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.whereInStrict(null, []);
			}, ArgumentError);

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.whereInStrict("", null);
			}, ArgumentError);
		}


		public function testSearch():void
		{
			Assert.equals(-1, _emptyCollection.search("missing"));

			Assert.equals(2, _objectCollection.search(findAppleWatch));
			Assert.equals(-1, _objectCollection.search(findUnknownDevice));

			Assert.equals(3, _numberCollection.search(0));
			Assert.equals(3, _numberCollection.search("0"));
			Assert.equals(-1, _numberCollection.search("0", true));
			Assert.equals(7, _numberCollection.search(findGreaterThan3));

			Assert.throwsError(function():void
			{
				// Invalid argument
				_emptyCollection.search(null);
			}, ArgumentError);

			function findAppleWatch(device:Object):Boolean
			{
				return device.name == "Apple Watch";
			}

			function findUnknownDevice(device:Object):Boolean
			{
				return device.name == "Unknown";
			}

			function findGreaterThan3(num:int):Boolean
			{
				return num > 3;
			}
		}


		public function testUnique():void
		{
			var emptyUnique:Collection = _emptyCollection.unique();

			Assert.isNotNull(emptyUnique);
			Assert.notSame(emptyUnique, _emptyCollection);
			Assert.isTrue(emptyUnique.isEmpty);

			var duplicateNums:Collection = new Collection(1, 3, 4, 1, 3, 1, 3, 4, 2, 2, 1, 2, 3, 4, 5);
			var uniqueNums:Collection = duplicateNums.unique();

			Assert.isNotNull(uniqueNums);
			Assert.notSame(uniqueNums, duplicateNums);
			Assert.equals(15, duplicateNums.length);
			Assert.equals(5, uniqueNums.length);
			Assert.arrayEquals([1, 3, 4, 2, 5], uniqueNums.all);

			var uniqueBrand:Collection = _objectCollection.unique("brand");

			Assert.isNotNull(uniqueBrand);
			Assert.notSame(uniqueBrand, _objectCollection);
			Assert.equals(2, uniqueBrand.length);
			Assert.equals("iPhone 6", uniqueBrand.first().name);
			Assert.equals("Galaxy S6", uniqueBrand.last().name);

			var uniqueBrandType:Collection = _objectCollection.unique(function(device:Object):String
			{
				return device.brand + device.type;
			});

			Assert.isNotNull(uniqueBrandType);
			Assert.notSame(uniqueBrandType, _objectCollection);
			Assert.equals(4, uniqueBrandType.length);
			Assert.equals("iPhone 6", uniqueBrandType[0].name);
			Assert.equals("Apple Watch", uniqueBrandType[1].name);
			Assert.equals("Galaxy S6", uniqueBrandType[2].name);
			Assert.equals("Galaxy Gear", uniqueBrandType[3].name);
		}
		
	}
	
}
