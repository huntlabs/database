
module hunt.database.query.Common;

enum QUERY_TYPE : byte
{
    SELECT,
    UPDATE,
    DELETE,
    INSERT,
    COUNT,
    SHOW_TABLES,
    DESC_TABLE
}

class ValueVariant 
{
    string key;
    Object value;
    this(string key , Object value)
    {
        this.key = key;
        this.value = value;
    }
    override string toString()
    {
        return  key ~ " = " ~ value.toString ;
    }
}


string quoteSqlString(string s) 
{
		string res = "\"";
		foreach(ch; s) {
			switch(ch) {
				case '\'': res ~= "\\\'"; break;
				case '\"': res ~= "\\\""; break;
				case '\\': res ~= "\\\\"; break;
				case '\0': res ~= "\\n"; break;
				case '\a': res ~= "\\a"; break;
				case '\b': res ~= "\\b"; break;
				case '\f': res ~= "\\f"; break;
				case '\n': res ~= "\\n"; break;
				case '\r': res ~= "\\r"; break;
				case '\t': res ~= "\\t"; break;
				case '\v': res ~= "\\v"; break;
				default:
					res ~= ch;
			}
		}
		res ~= "\"";
		//writeln("quoted " ~ s ~ " is " ~ res);
		return res;
}