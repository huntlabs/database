/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module hunt.database.base.impl.ConnectionPool;

import hunt.database.base.PoolOptions;
import hunt.database.base.impl.command.CommandBase;
import io.vertx.core.*;
import io.vertx.core.impl.NoStackTraceThrowable;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import java.util.function.Consumer;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class ConnectionPool {

  private final Consumer!(Handler!(AsyncResult!(Connection))) connector;
  private final int maxSize;
  private final ArrayDeque!(Promise!(Connection)) waiters = new ArrayDeque<>();
  private final Set!(PooledConnection) all = new HashSet<>();
  private final ArrayDeque!(PooledConnection) available = new ArrayDeque<>();
  private int size;
  private final int maxWaitQueueSize;
  private boolean checkInProgress;
  private boolean closed;

  ConnectionPool(Consumer!(Handler!(AsyncResult!(Connection))) connector) {
    this(connector, PoolOptions.DEFAULT_MAX_SIZE, PoolOptions.DEFAULT_MAX_WAIT_QUEUE_SIZE);
  }

  ConnectionPool(Consumer!(Handler!(AsyncResult!(Connection))) connector, int maxSize) {
    this(connector, maxSize, PoolOptions.DEFAULT_MAX_WAIT_QUEUE_SIZE);
  }

  ConnectionPool(Consumer!(Handler!(AsyncResult!(Connection))) connector, int maxSize, int maxWaitQueueSize) {
    this.maxSize = maxSize;
    this.maxWaitQueueSize = maxWaitQueueSize;
    this.connector = connector;
  }

  int available() {
    return available.size();
  }

  int size() {
    return size;
  }

  void acquire(Handler!(AsyncResult!(Connection)) holder) {
    if (closed) {
      throw new IllegalStateException("Connection pool closed");
    }
    Promise!(Connection) promise = Promise.promise();
    promise.future().setHandler(holder);
    waiters.add(promise);
    check();
  }

  void close() {
    if (closed) {
      throw new IllegalStateException("Connection pool already closed");
    }
    closed = true;
    for (PooledConnection pooled : new ArrayList<>(all)) {
      pooled.close();
    }
    Future!(Connection) failure = Future.failedFuture("Connection pool closed");
    for (Promise!(Connection) pending : waiters) {
      try {
        pending.handle(failure);
      } catch (Exception ignore) {
      }
    }
  }

  private class PooledConnection implements Connection, Connection.Holder  {

    private final Connection conn;
    private Holder holder;

    PooledConnection(Connection conn) {
      this.conn = conn;
    }

    override
    boolean isSsl() {
      return conn.isSsl();
    }

    override
    void schedule(CommandBase<?> cmd) {
      conn.schedule(cmd);
    }

    /**
     * Close the underlying connection
     */
    private void close() {
      conn.close(this);
    }

    override
    void init(Holder holder) {
      if (this.holder !is null) {
        throw new IllegalStateException();
      }
      this.holder = holder;
    }

    override
    void close(Holder holder) {
      if (holder != this.holder) {
        throw new IllegalStateException();
      }
      this.holder = null;
      release(this);
    }

    override
    void handleClosed() {
      if (all.remove(this)) {
        size--;
        if (holder is null) {
          available.remove(this);
        } else {
          holder.handleClosed();
        }
        check();
      } else {
        throw new IllegalStateException();
      }
    }

    override
    void handleNotification(int processId, String channel, String payload) {
      if (holder !is null) {
        holder.handleNotification(processId, channel, payload);
      }
    }

    override
    void handleException(Throwable err) {
      if (holder !is null) {
        holder.handleException(err);
      }
    }

    override
    int getProcessId() {
      return conn.getProcessId();
    }

    override
    int getSecretKey() {
      return conn.getSecretKey();
    }
  }

  private void release(PooledConnection proxy) {
    if (all.contains(proxy)) {
      available.add(proxy);
      check();
    }
  }

  private void check() {
    if (closed) {
      return;
    }
    if (!checkInProgress) {
      checkInProgress = true;
      try {
        while (waiters.size() > 0) {
          if (available.size() > 0) {
            PooledConnection proxy = available.poll();
            Promise!(Connection) waiter = waiters.poll();
            waiter.complete(proxy);
          } else {
            if (size < maxSize) {
              Promise!(Connection) waiter = waiters.poll();
              size++;
              connector.accept(ar -> {
                if (ar.succeeded()) {
                  Connection conn = ar.result();
                  PooledConnection proxy = new PooledConnection(conn);
                  all.add(proxy);
                  conn.init(proxy);
                  waiter.complete(proxy);
                } else {
                  size--;
                  waiter.fail(ar.cause());
                  check();
                }
              });
            } else {
              if (maxWaitQueueSize >= 0) {
                int numInProgress = size - all.size();
                int numToFail = waiters.size() - (maxWaitQueueSize + numInProgress);
                while (numToFail-- > 0) {
                  Promise!(Connection) waiter = waiters.pollLast();
                  waiter.fail(new NoStackTraceThrowable("Max waiter size reached"));
                }
              }
              break;
            }
          }
        }
      } finally {
        checkInProgress = false;
      }
    }
  }
}
