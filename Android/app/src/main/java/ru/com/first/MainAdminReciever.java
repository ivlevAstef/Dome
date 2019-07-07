package ru.com.first;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;

public class MainAdminReciever extends DeviceAdminReceiver {
    @Override
    public void onDisabled(Context context, Intent intent) {
    }

    @Override
    public void onEnabled(Context context, Intent intent) {
    }

    @Override
    public CharSequence onDisableRequested(Context context, Intent intent) {
        return "";
    }

}
