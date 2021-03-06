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

module hunt.database.driver.postgresql.impl.codec.PgPreparedStatement;

import hunt.database.driver.postgresql.impl.codec.Bind;
import hunt.database.driver.postgresql.impl.codec.DataFormat;
import hunt.database.driver.postgresql.impl.codec.PgColumnDesc;
import hunt.database.driver.postgresql.impl.codec.PgParamDesc;
import hunt.database.driver.postgresql.impl.codec.PgRowDesc;

import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.ParamDesc;

import hunt.collection.List;

import std.algorithm;
import std.array;
import std.variant;

class PgPreparedStatement : PreparedStatement {

    private enum PgColumnDesc[] EMPTY_COLUMNS = [];

    string _sql;
    Bind bind;
    PgParamDesc _paramDesc;
    PgRowDesc _rowDesc;

    this(string sql, long statement, PgParamDesc paramDesc, PgRowDesc rowDesc) {

        // Fix to use binary when possible
        if (rowDesc !is null) {
            rowDesc = new PgRowDesc(rowDesc.columns
                .map!(c => new PgColumnDesc(
                    c.name,
                    c.relationId,
                    c.relationAttributeNo,
                    c.dataType,
                    c.length,
                    c.typeModifier,
                    c.dataType.supportsBinary ? DataFormat.BINARY : DataFormat.TEXT)
                ).array());
        }

        this._paramDesc = paramDesc;
        this._rowDesc = rowDesc;
        this._sql = sql;
        this.bind = new Bind(statement, paramDesc !is null ? paramDesc.paramDataTypes() : null, 
            rowDesc !is null ? rowDesc.columns : EMPTY_COLUMNS);
    }

    override
    ParamDesc paramDesc() {
        return _paramDesc;
    }

    override
    PgRowDesc rowDesc() {
        return _rowDesc;
    }

    override
    string sql() {
        return _sql;
    }

    override
    string prepare(List!(Variant) values) {
        return paramDesc.prepare(values);
    }
}
