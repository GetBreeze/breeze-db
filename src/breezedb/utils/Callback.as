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
	 * @private
	 */
	public class Callback
	{

		public static function call(fn:Function, args:Array):Boolean
		{
			if(fn == null)
			{
				return false;
			}

			var numArgs:int = fn.length;
			for(var i:int = args.length; i < numArgs; ++i)
			{
				args[i] = null;
			}

			// There are less than 3 arguments most of the time,
			// so we call the method directly to avoid the 'slice' allocations

			switch(numArgs)
			{
				case 0:
					fn();
					break;
				case 1:
					fn(args[0]);
					break;
				case 2:
					fn(args[0], args[1]);
					break;
				case 3:
					fn(args[0], args[1], args[2]);
					break;
				default:
					fn.apply(null, args.slice(0, numArgs));
					break;
			}

			return true;
		}

	}

}
