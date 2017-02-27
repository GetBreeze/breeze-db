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

package breezedb.queries
{
	/**
	 * Interface providing API to execute raw queries.
	 */
	public interface IRawQuery
	{
		/**
		 * Executes a query on the associated database. It is treated as a raw query, thus the result
		 * is returned as a generic <code>BreezeSQLResult</code> object.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.query("SELECT * FROM photos WHERE id > :id", { id: 2 }, onRawQueryCompleted);
		 *
		 * function onRawQueryCompleted(error:Error, result:BreezeSQLResult):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace(result.data); // For SELECT queries
		 *       trace(result.rowsAffected); // For UPDATE, DELETE queries
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function query(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference;


		/**
		 * Executes a <code>SELECT</code> query on the associated database. The result is cast to a
		 * <code>Collection</code> object.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.select("SELECT id, title, views FROM photos", onSelectCompleted);
		 *
		 * function onSelectCompleted(error:Error, results:Collection):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace(results);
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function select(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference;


		/**
		 * Executes an <code>INSERT</code> query on the associated database.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.insert(
		 *    "INSERT INTO photos (title, views, downloads) VALUES (:title, :views, :downloads),
		 *    { title: "Mountains", views: 35, downloads: 10 },
		 *    onInsertCompleted
		 * );
		 *
		 * function onInsertCompleted(error:Error):void
		 * {
		 *    if(error == null)
		 *    {
		 *       // Insert was successful
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function insert(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference;


		/**
		 * Executes an <code>UPDATE</code> query on the associated database. The result is cast to
		 * an <code>int</code> that provides information about the number of rows affect by the query.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.update("UPDATE photos SET title = :title WHERE id = :id", { title: "Trees", id: 2 }, onUpdateCompleted);
		 *
		 * function onUpdateCompleted(error:Error, rowsAffected:int):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace("Updated", rowsAffected, "row(s)");
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function update(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference;


		/**
		 * Executes a <code>DELETE</code> query on the associated database. The result is cast to
		 * an <code>int</code> that provides information about the number of rows affect by the query.
		 *
		 * @param rawQuery SQL query to execute.
		 * @param params Optional query parameters, i.e. key-value <code>Object</code>. If query parameters
		 *        are not used, this parameter can specify a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.remove("DELETE FROM photos WHERE title = :title", { title: "Camp Fire" }, onDeleteCompleted);
		 *
		 * function onDeleteCompleted(error:Error, rowsAffected:int):void
		 * {
		 *    if(error == null)
		 *    {
		 *       trace("Deleted", rowsAffected, "row(s)");
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function remove(rawQuery:String, params:* = null, callback:Function = null):BreezeQueryReference;


		/**
		 * Executes multiple raw queries on the associated database. All queries are executed, regardless
		 * of any errors that occur in earlier queries.
		 *
		 * <p>The result is cast to a list of <code>BreezeQueryResult</code> and the results are in
		 * the same order as the executed queries. Each result contains an error and result objects.</p>
		 *
		 * @param rawQueries List of SQL queries to execute. It can be either a raw query (<code>String</code>)
		 *        or delayed <code>BreezeQueryRunner</code> (super class of <code>BreezeQueryBuilder</code>).
		 *        <strong>Note all <code>BreezeQueryRunner</code> objects must use the same database connection.</strong>
		 * @param params Optional query parameters, i.e. <code>Array</code> of key-value <code>Objects</code>
		 *        or <code>null</code>. If query parameters are not used, this parameter can specify
		 *        a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * var query1:BreezeQueryBuilder = BreezeDb.db.table("photos").where("id", 1).update({ title: "Hills" }, BreezeDb.DELAY);
		 * var query2:BreezeQueryRunner = BreezeDb.db.table("photos").where("id", 2).fetch(BreezeDb.DELAY);
		 * 
		 * BreezeDb.db.multiQuery(
		 *    [
		 *     query1,
		 *     query2,
		 *     "SELECT id, title FROM photos WHERE title = :title"
		 *    ],
		 *    [null, null, { title: "Hills" }],
		 *    onMultiQueryCompleted
		 * );
		 *
		 * function onMultiQueryCompleted(results:Vector.&lt;BreezeQueryResult&gt;):void
		 * {
		 *    for each(var result:BreezeQueryResult in results)
		 *    {
		 *       if(result.error == null)
		 *       {
		 *          trace(result.data);
		 *       }
		 *    }
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function multiQuery(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference;


		/**
		 * Executes multiple raw queries on the associated database. If a query fails, the queries that follow
		 * will <strong>not</strong> be executed. Successful queries are <strong>not</strong> rolled back.
		 *
		 * <p>The first callback parameter is an <code>Error</code> object that references the error that
		 * caused the execution to stop. Additionally, a list of <code>BreezeQueryResult</code> is provided
		 * and the results are in the same order as the executed queries. Each result contains an error
		 * and result objects.</p>
		 *
		 * @param rawQueries List of SQL queries to execute. It can be either a raw query (<code>String</code>)
		 *        or delayed <code>BreezeQueryRunner</code> (super class of <code>BreezeQueryBuilder</code>).
		 *        <strong>Note all <code>BreezeQueryRunner</code> objects must use the same database connection.</strong>
		 * @param params Optional query parameters, i.e. <code>Array</code> of key-value <code>Objects</code>
		 *        or <code>null</code>. If query parameters are not used, this parameter can specify
		 *        a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.multiQueryFailOnError(
		 *    [
		 *     "SELECT * FROM photos WHEREz", // syntax error, the second query will not be executed
		 *     "SELECT id, title FROM photos WHERE title = :title"
		 *    ],
		 *    [null, { title: "Hills" }],
		 *    onMultiQueryCompleted
		 * );
		 *
		 * function onMultiQueryCompleted(error:Error, results:Vector.&lt;BreezeQueryResult&gt;):void
		 * {
		 *    trace(error); // SQLError
		 *    trace(results.length); // 1
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function multiQueryFailOnError(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference;


		/**
		 * Executes multiple raw queries on the associated database. If a query fails, the queries that follow
		 * will <strong>not</strong> be executed and the database is rolled back to the state before executing
		 * the queries.
		 *
		 * <p>The first callback parameter is an <code>Error</code> object that references the error that
		 * caused the execution to stop. Additionally, a list of <code>BreezeQueryResult</code> is provided
		 * and the results are in the same order as the executed queries. Each result contains an error
		 * and result objects.</p>
		 *
		 * @param rawQueries List of SQL queries to execute. It can be either a raw query (<code>String</code>)
		 *        or delayed <code>BreezeQueryRunner</code> (super class of <code>BreezeQueryBuilder</code>).
		 *        <strong>Note all <code>BreezeQueryRunner</code> objects must use the same database connection.</strong>
		 * @param params Optional query parameters, i.e. <code>Array</code> of key-value <code>Objects</code>
		 *        or <code>null</code>. If query parameters are not used, this parameter can specify
		 *        a callback <code>Function</code>.
		 * @param callback Function that is triggered when the query is completed.
		 *
		 * <listing version="3.0">
		 * BreezeDb.db.multiQueryTransaction(
		 *    [
		 *     "UPDATE photos SET title = :title",
		 *     "SELECT title FROM photos WHEREz id > 2" // syntax error, the previous UPDATE will be rolled back
		 *    ],
		 *    [{ title: "Hills" }],
		 *    onMultiQueryCompleted
		 * );
		 *
		 * function onMultiQueryCompleted(error:Error, results:Vector.&lt;BreezeQueryResult&gt;):void
		 * {
		 *    trace(error); // SQLError
		 * };
		 * </listing>
		 *
		 * @return <code>BreezeQueryReference</code> object that allows cancelling the request callback.
		 */
		function multiQueryTransaction(rawQueries:Array, params:* = null, callback:Function = null):BreezeQueryReference;
	}
	
}
