module database.utils;

import database;


public T safeConvert(F,T)(F value)
{
    try
    {
        return to!T(value);
    }
    catch
    {
        return T.init;
    }
}

