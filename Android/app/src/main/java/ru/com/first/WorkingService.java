package ru.com.first;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.os.IBinder;
import android.os.SystemClock;
import android.view.View;

import java.lang.reflect.Method;
import java.util.Date;

public class WorkingService extends Service {

    @Override
    public IBinder onBind(Intent arg0) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // TODO Auto-generated method stub
        return START_STICKY;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        // TODO Auto-generated method stub
        Intent restartService = new Intent(getApplicationContext(),
                this.getClass());
        restartService.setPackage(getPackageName());
        PendingIntent restartServicePI = PendingIntent.getService(
                getApplicationContext(), 1, restartService,
                PendingIntent.FLAG_ONE_SHOT);

        AlarmManager alarmService = (AlarmManager)getApplicationContext().getSystemService(Context.ALARM_SERVICE);
        alarmService.set(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime() +100, restartServicePI);

    }

    @Override
    public void onCreate() {
        // TODO Auto-generated method stub
        super.onCreate();

        startWorkingThread();
    }

    private void startWorkingThread() {
        new Thread(new Runnable() {
            public void run() {
                PhoneBlockUtils.unblockPhone(WorkingService.this);

                SocketConnection connection = null;
                if(PhoneBlockUtils.getServer() != null) {
                    connection = new SocketConnection(PhoneBlockUtils.getServer(), WorkingService.this);
                    connection.sendPhoneData();
                }

                Date now = new Date();
                while(true) {

                    if(connection == null && PhoneBlockUtils.getServer() != null) {
                        connection = new SocketConnection(PhoneBlockUtils.getServer(), WorkingService.this);
                        connection.sendPhoneData();
                    }

                    if(needToBlockNow(now, connection))
                        PhoneBlockUtils.blockPhone(WorkingService.this);
                    else
                        PhoneBlockUtils.unblockPhone(WorkingService.this);

                    now = new Date();
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                        PhoneBlockUtils.blockPhone(WorkingService.this);
                    }
                }

            }
        }).start();
    }

    private boolean needToBlockNow(Date now, SocketConnection connection) {
        if(PhoneBlockUtils.getServer() == null || connection == null)
            return false;
        if(connection.disconnected())
            return true;
        if(now.getMinutes() % 2 == 0) //for testing 1 min interval
            return true;
        return false;
    }

}
