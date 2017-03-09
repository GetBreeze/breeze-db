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

package tests.migrations
{
	import breezedb.IBreezeDatabase;
	import breezedb.migrations.BreezeMigration;
	import breezedb.schemas.TableBlueprint;
	
	public class Migration_Create_Table_Photos extends BreezeMigration
	{
		
		public function Migration_Create_Table_Photos()
		{
			super();
		}
		

		override public function run(db:IBreezeDatabase):void
		{
			db.schema.createTable("photos", function (table:TableBlueprint):void
			{
				table.increments("id");
				table.string("title").defaultNull();
				table.integer("views").defaultTo(0);
				table.integer("downloads").defaultTo(0);
				table.integer("likes").defaultTo(0);
				table.date("creation_date");
			},
			function(error:Error):void
			{
				done(error == null);
			});
		}
	}
	
}
