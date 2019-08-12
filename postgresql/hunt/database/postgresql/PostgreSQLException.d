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

module hunt.database.postgresql.PostgreSQLException.PostgreSQLException;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PgException : RuntimeException {

  private final String severity;
  private final String code;
  private final String detail;

  PgException(String message, String severity, String code, String detail) {
    super(message);
    this.severity = severity;
    this.code = code;
    this.detail = detail;
  }

  String getSeverity() {
    return severity;
  }

  String getCode() {
    return code;
  }

  /**
   * @return the detail error message
   */
  String getDetail() {
    return detail;
  }
}
