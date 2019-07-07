package ru.com.first;

import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.net.ConnectivityManager;

import java.lang.reflect.Method;

public class PhoneBlockUtils {
    private String phoneBlockingServer = null;

    private DevicePolicyManager devicePolicyManager;
    private ComponentName deviceAdminReceiver;

    private ConnectivityManager dataManager;
    private Method dataMtd;

    private boolean currentBlockedState;

    private Context currentContext;

    private static PhoneBlockUtils singleton = null;

    public static void initManagers(Context context)
    {
        if(singleton == null)
            singleton = new PhoneBlockUtils();
        singleton.init(context);
    }

    private void init(Context context) {
        currentContext = context;

        devicePolicyManager = (DevicePolicyManager) context.getSystemService(Context.DEVICE_POLICY_SERVICE);
        deviceAdminReceiver = new ComponentName(context, MainAdminReciever.class);
        dataManager  = (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
        try {
            dataMtd = ConnectivityManager.class.getDeclaredMethod("setMobileDataEnabled", boolean.class);
            dataMtd.setAccessible(true);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        }

        currentBlockedState = false;
    }

    public static String getServer()
    {
        return singleton == null ? null : singleton.phoneBlockingServer;
    }

    public static void setServer(String server, Context context)
    {
        if(singleton == null) {
            singleton = new PhoneBlockUtils();
            singleton.init(context);
        }
        singleton.phoneBlockingServer = server;
    }

    public static boolean isPhoneBlocked()
    {
        return singleton == null ? false : singleton.currentBlockedState;
    }

    public static void blockPhone(Context context)
    {
        if(singleton == null) {
            singleton = new PhoneBlockUtils();
            singleton.init(context);
        }
        singleton.currentBlockedState = true;
        singleton.blockCamera();
        singleton.blockData();
    }

    public static void unblockPhone(Context context)
    {
        if(singleton == null) {
            singleton = new PhoneBlockUtils();
            singleton.init(context);
        }
        singleton.currentBlockedState = false;
        singleton.unblockCamera();
        singleton.unblockData();
    }

    private void blockCamera() {
        try {
            if (devicePolicyManager.isAdminActive(deviceAdminReceiver)) {
                devicePolicyManager.setCameraDisabled(deviceAdminReceiver, true);
            }
        }
        catch( Exception e) {
            e.printStackTrace();
        }
    }

    private void unblockCamera() {
        try {
            if (devicePolicyManager.isAdminActive(deviceAdminReceiver)) {
                devicePolicyManager.setCameraDisabled(deviceAdminReceiver, false);
            }
        }
        catch( Exception e) {
            e.printStackTrace();
        }
    }

    private void blockData() {
        try{
            if(dataMtd != null)
                dataMtd.invoke(dataManager, true);
        }catch(Exception ex){
            String a = ex.getMessage();
        }
    }

    private void unblockData() {
        try{
            if(dataMtd != null)
                dataMtd.invoke(dataManager, true);
        }catch(Exception ex){
            String a = ex.getMessage();
        }
    }

    public static void clear() {
        singleton = null;
    }

}
