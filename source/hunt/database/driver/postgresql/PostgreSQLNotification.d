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
module hunt.database.driver.postgresql.PostgreSQLNotification;

// import io.vertx.codegen.annotations.DataObject;
// import io.vertx.core.json.JsonObject;


import hunt.database.base.Common;

alias PgNotificationHandler = EventHandler!(PgNotification);

/**
 * A notification emited by Postgres.
 */
class PgNotification {

    private int processId;
    private string channel;
    private string payload;

    this() {
    }

    // this(JsonObject json) {
    //     PgNotificationConverter.fromJson(json, this);
    // }

    /**
     * @return the notification process id
     */
    int getProcessId() {
        return processId;
    }

    /**
     * Set the process id.
     *
     * @return a reference to this, so the API can be used fluently
     */
    PgNotification setProcessId(int processId) {
        this.processId = processId;
        return this;
    }

    /**
     * @return the notification channel value
     */
    string getChannel() {
        return channel;
    }

    /**
     * Set the channel value.
     *
     * @return a reference to this, so the API can be used fluently
     */
    PgNotification setChannel(string channel) {
        this.channel = channel;
        return this;
    }

    /**
     * @return the notification payload value
     */
    string getPayload() {
        return payload;
    }

    /**
     * Set the payload value.
     *
     * @return a reference to this, so the API can be used fluently
     */
    PgNotification setPayload(string payload) {
        this.payload = payload;
        return this;
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     PgNotificationConverter.toJson(this, json);
    //     return json;
    // }
}
