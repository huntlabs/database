/*
 * Database - Database abstraction layer for D programing language.
 *
 * Copyright (C) 2017  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module database.pool;

import database.option;
import database.factory;
import std.container.array;
import core.sync.rwmutex;

import database.driver.postgresql;
import database.driver.mysql;
import database.driver.sqlite;

class Pool
{
    Connection _conn;
    Array!Connection _conns;
    DatabaseOption _options;
    ReadWriteMutex _mutex;
    int _poolLength;
    Dialect dialect;
    Factory _factory;

    this(DatabaseOption options, Factory factory)
    {
        this._options = options;
        this._factory = factory;

        _mutex = new ReadWriteMutex();
        dialect = initDialect();

        int i = 0;
        while(i < _options.minimumConnection)
        {
            _conns.insertBack(initConnection);
            i++;
        }
        _poolLength = i;
    }

    ~this()
    {
        _mutex.destroy();
    }

    private Dialect initDialect()
    {
        version (USE_POSTGRESQL){
            return new PostgresqlDialect;
        }else version (USE_MYSQL){
            return new MysqlDialect;
        }else version(USE_SQLITE){
            return new SqliteDialect;
        }else
            throw new DatabaseException("Don't support database driver: "~ _options.url.scheme);
    
    }

    private Connection initConnection()
    {
        version (USE_POSTGRESQL)
        {
            return new PostgresqlConnection(_options.url);
        }
        else version (USE_MYSQL)
        {
            return new MysqlConnection(_options.url);
        }
        else version(USE_SQLITE){
            _options.setMaximumConnection = 1;
            _options.setMinimumConnection = 1;
            return new SQLiteConnection(_options.url);
        }
        else
            throw new DatabaseException("Don't support database driver: "~ _options.url.scheme);
    }

    Connection getConnection()
    {
        _mutex.writer.lock();
        scope(exit) {
            if(_conns.length)
                _conns.linearRemove(_conns[0..1]);
            _mutex.writer.unlock();
        }
        Connection conn;
        if(!_conns.length)
        {
            conn = initConnection();
            _conns.insertBack(conn);
            _poolLength++;
        }
        else
            conn = _conns.front;
        version(USE_MYSQL){conn.ping();}
        return conn;
    }

    void release(Connection conn)
    {
        _mutex.writer.lock();
        scope(exit)_mutex.writer.unlock();
        _conns.insertBack(conn);
    }    

    void close()
    {
        _mutex.writer.lock();
        scope(exit)_mutex.writer.unlock();
        foreach(c;_conns){
            c.close();
        }    
    }
}
