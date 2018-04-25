module database.driver.sqlite.dialect;

import database;

class SqliteDialect : Dialect
{
	string closeQuote() { return `"`; }
	string openQuote()  { return `"`; }

	Variant fromSqlValue(DlangDataType type,Variant value)
	{
		if(typeid(type) == typeid(dBoolType)){
			if(*value.peek!string == "1")
				return Variant(true);
			else
				return Variant(false);
		}else if(typeid(type) == typeid(dFloatType))
			return Variant(safeConvert!(string,float)(*value.peek!string));
		else if(typeid(type) == typeid(dDoubleType))
			return Variant(safeConvert!(string,double)(*value.peek!string));
		else if(typeid(type) == typeid(dIntType))
			return Variant(safeConvert!(string,int)(*value.peek!string));
		else if(typeid(type) == typeid(dLongType))
			return Variant(safeConvert!(string,long)(*value.peek!string));
		else
			return value;
	}

	string toSqlValueImpl(DlangDataType type,Variant value)
	{
		if(typeid(type) == typeid(dBoolType))
			return value.get!(bool) ? "1" : "0";
		else if(typeid(type) == typeid(dFloatType))
			//return isNaN(*value.peek!float) ? "0" : *value.peek!string;
			return (*value.peek!float).to!string;
		else if(typeid(type) == typeid(dDoubleType))
			//return isNaN(*value.peek!double) ? "0" : *value.peek!string;
			return (*value.peek!double).to!string;
		else if(typeid(type) == typeid(dIntType))
			return value.toString;
		else
			return openQuote ~ value.toString ~ closeQuote;
	}
}

string[] SQLITE_RESERVED_WORDS = 
[
"ABORT",
	"ACTION",
	"ADD",
	"AFTER",
	"ALL",
	"ALTER",
	"ANALYZE",
	"AND",
	"AS",
	"ASC",
	"ATTACH",
	"AUTOINCREMENT",
	"BEFORE",
	"BEGIN",
	"BETWEEN",
	"BY",
	"CASCADE",
	"CASE",
	"CAST",
	"CHECK",
	"COLLATE",
	"COLUMN",
	"COMMIT",
	"CONFLICT",
	"CONSTRAINT",
	"CREATE",
	"CROSS",
	"CURRENT_DATE",
	"CURRENT_TIME",
	"CURRENT_TIMESTAMP",
	"DATABASE",
	"DEFAULT",
	"DEFERRABLE",
	"DEFERRED",
	"DELETE",
	"DESC",
	"DETACH",
	"DISTINCT",
	"DROP",
	"EACH",
	"ELSE",
	"END",
	"ESCAPE",
	"EXCEPT",
	"EXCLUSIVE",
	"EXISTS",
	"EXPLAIN",
	"FAIL",
	"FOR",
	"FOREIGN",
	"FROM",
	"FULL",
	"GLOB",
	"GROUP",
	"HAVING",
	"IF",
	"IGNORE",
	"IMMEDIATE",
	"IN",
	"INDEX",
	"INDEXED",
	"INITIALLY",
	"INNER",
	"INSERT",
	"INSTEAD",
	"INTERSECT",
	"INTO",
	"IS",
	"ISNULL",
	"JOIN",
	"KEY",
	"LEFT",
	"LIKE",
	"LIMIT",
	"MATCH",
	"NATURAL",
	"NO",
	"NOT",
	"NOTNULL",
	"NULL",
	"OF",
	"OFFSET",
	"ON",
	"OR",
	"ORDER",
	"OUTER",
	"PLAN",
	"PRAGMA",
	"PRIMARY",
	"QUERY",
	"RAISE",
	"REFERENCES",
	"REGEXP",
	"REINDEX",
	"RELEASE",
	"RENAME",
	"REPLACE",
	"RESTRICT",
	"RIGHT",
	"ROLLBACK",
	"ROW",
	"SAVEPOINT",
	"SELECT",
	"SET",
	"TABLE",
	"TEMP",
	"TEMPORARY",
	"THEN",
	"TO",
	"TRANSACTION",
	"TRIGGER",
	"UNION",
	"UNIQUE",
	"UPDATE",
	"USING",
	"VACUUM",
	"VALUES",
	"VIEW",
	"VIRTUAL",
	"WHEN",
	"WHERE",
	];
