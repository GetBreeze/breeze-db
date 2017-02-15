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

package breezedb.schemas
{

	/**
	 * Interface providing API to add constraints on a column.
	 */
	public interface IColumnConstraint
	{
		/**
		 * Adds a <code>NOT NULL</code> constraint on the column.
		 *
		 * @return Reference to <code>IColumnConstraint</code> allowing to chain additional constraints.
		 */
		function notNull():IColumnConstraint;


		/**
		 * Adds a <code>DEFAULT [value]</code> constraint on the column.
		 *
		 * @return Reference to <code>IColumnConstraint</code> allowing to chain additional constraints.
		 */
		function defaultTo(value:*):IColumnConstraint;


		/**
		 * Adds a <code>DEFAULT NULL</code> constraint on the column.
		 *
		 * @return Reference to <code>IColumnConstraint</code> allowing to chain additional constraints.
		 */
		function defaultNull():IColumnConstraint;


		/**
		 * Adds a <code>UNIQUE</code> constraint on the column, ensuring that the column contains a unique value.
		 *
		 * @return Reference to <code>IColumnConstraint</code> allowing to chain additional constraints.
		 */
		function unique():IColumnConstraint;


		/**
		 * Designates the column as primary key.
		 *
		 * @return Reference to <code>IColumnConstraint</code> allowing to chain additional constraints.
		 */
		function primary():IColumnConstraint;
		
	}
	
}
