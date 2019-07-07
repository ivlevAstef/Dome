package ru.com.first;

import android.content.Context;
import android.content.SharedPreferences;

public class Preferences {
    public static String getString(String key, String defValue, Context context)
    {
        SharedPreferences pref = context.getSharedPreferences("dome", Context.MODE_PRIVATE);
        if(pref != null)
            return pref.getString(key, defValue);
        return defValue;
    }
    public static void putString(String key, String value, Context context)
    {
        SharedPreferences pref = context.getSharedPreferences("dome", Context.MODE_PRIVATE);
        if(pref != null)
        {
            pref.edit().putString(key, value).apply();
        }
    }
}
