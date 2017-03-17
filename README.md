# BreezeDb [![Build Status](https://travis-ci.org/GetBreeze/breeze-db.svg?branch=master)](https://travis-ci.org/GetBreeze/breeze-db)

BreezeDb is a SQLite database helper and ORM loosely based on the [Laravel database](https://laravel.com/docs/5.3/database) and [Eloquent ORM](https://laravel.com/docs/5.3/eloquent).

## Features

### Database

BreezeDb greatly simplifies the process of setting up, managing and interacting with SQLite database in Adobe AIR. It supports multiple database connections and keeps your app responsive by executing all operations asynchronously.

### Migrations

Migrations are used to create and edit database structure between app versions. They are atomic and run within a transaction, thus if one migration fails then all preceding migrations in the same session will be rolled back. After a migration is completed successfully, it will never run again.

### Collection

The `Collection` class provides a wrapper for working with arrays of data. It is built upon the standard `Array` class but adds a handful of new methods.

### Query Builder

Query builder provides a convenient, fluent interface for creating and running database queries, including multi-row inserts, aggregates and joins. The builder uses automatic parameter binding to protect against SQL injection attacks.

### ORM

The ORM support in BreezeDb enables seamless mapping of each database table to an ActionScript class (model). Models are capable of querying data as well as inserting new records using strongly typed objects.