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

module hunt.database.base.impl.RowDesc;

import hunt.collection.List;
import hunt.Exceptions;

import std.algorithm;
import std.conv;
import std.range;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */

class RowDesc {

	private string[] _columnNames;

	this(string[] columnNames) {
		this._columnNames = columnNames;
	}

	int columnIndex(string columnName) {
		if (columnName.empty) {
			throw new NullPointerException("Column name must not be null");
		}
		return cast(int)_columnNames.countUntil(columnName);
	}

	string[] columnNames() {
		return _columnNames;
	}

	override string toString() {
		return "RowDesc{" ~ "columns=" ~ _columnNames.to!string() ~ "}";
	}
}
