/*
 * MIT License
 *
 * Copyright (c) kuwamoto.org
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
 * http://kuwamoto.org/2007/12/17/improved-pluralizing-in-php-actionscript-and-ror/
 *
 */

package org.kuwamoto
{
	public class Inflect
	{
		private static var plural:Array = [
			[/(quiz)$/i, "$1zes"],
			[/^(ox)$/i, "$1en"],
			[/([m|l])ouse$/i, "$1ice"],
			[/(matr|vert|ind)ix|ex$/i, "$1ices"],
			[/(x|ch|ss|sh)$/i, "$1es"],
			[/([^aeiouy]|qu)y$/i, "$1ies"],
			[/(hive)$/i, "$1s"],
			[/(?:([^f])fe|([lr])f)$/i, "$1$2ves"],
			[/(shea|lea|loa|thie)f$/i, "$1ves"],
			[/sis$/i, "ses"],
			[/([ti])um$/i, "$1a"],
			[/(tomat|potat|ech|her|vet)o$/i, "$1oes"],
			[/(bu)s$/i, "$1ses"],
			[/(alias|status)$/i, "$1es"],
			[/(octop)us$/i, "$1i"],
			[/(ax|test)is$/i, "$1es"],
			[/(us)$/i, "$1es"],
			[/s$/i, "s"],
			[/$/i, "s"]
		];

		private static var irregular:Array = [
			['move', 'moves'],
			['foot', 'feet'],
			['goose', 'geese'],
			['sex', 'sexes'],
			['child', 'children'],
			['man', 'men'],
			['tooth', 'teeth'],
			['person', 'people']
		];

		private static var uncountable:Array = [
			'sheep',
			'fish',
			'deer',
			'series',
			'species',
			'money',
			'rice',
			'information',
			'equipment'
		];


		public static function pluralize(string:String):String
		{
			var pattern:RegExp;
			var result:String;

			// save some time in the case that singular and plural are the same
			if(uncountable.indexOf(string.toLowerCase()) != -1)
			{
				return string;
			}

			// check for irregular singular forms
			var item:Array;
			for each (item in irregular)
			{
				pattern = new RegExp(item[0] + "$", "i");
				result = item[1];

				if(pattern.test(string))
				{
					return string.replace(pattern, result);
				}
			}

			// check for matches using regular expressions
			for each (item in plural)
			{
				pattern = item[0];
				result = item[1];

				if(pattern.test(string))
				{
					return string.replace(pattern, result);
				}
			}

			return string;
		}

	}
}