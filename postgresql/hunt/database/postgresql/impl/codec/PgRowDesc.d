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
module hunt.database.postgresql.impl.codec.PgRowDesc;

import hunt.database.base.impl.RowDesc;

import java.util.Collections;
import java.util.stream.Collectors;
import java.util.stream.Stream;

class PgRowDesc : RowDesc {

  final PgColumnDesc[] columns;

  PgRowDesc(PgColumnDesc[] columns) {
    super(Collections.unmodifiableList(Stream.of(columns)
      .map(d -> d.name)
      .collect(Collectors.toList())));
    this.columns = columns;
  }
}
