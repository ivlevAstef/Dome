package ru.com.first;

import android.content.Context;
import android.provider.Settings.Secure;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import okhttp3.Request;
import okhttp3.WebSocket;
import okio.ByteString;

public class SocketConnection extends Socket.OnEventResponseListener {
    private String server = null;
    //private SSLSocket socket;
    private Context context;
    private Socket socket;
    private boolean disconnected = true;

    public SocketConnection(String server, Context context)
    {
        this.server = server;
        this.context = context;
        try {

            socket = Socket.Builder.with("ws://"+server+":5000").build().connect();
            disconnected = false;
            socket.onEventResponse("Some event", this);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean disconnected() {
        return false;
    }

    @Override
    public void onMessage(String event, String data) {
        if(data != null)
        {
            try
            {
                JSONObject object = new JSONObject(data);
                if(object != null && object.getString("e") == "mobile" && object.getString("id") != null && context != null)
                    Preferences.putString("id", object.getString("id"), context);
            } catch (Exception e)
            {
                e.printStackTrace();
            }
        }
    }

    public void sendPhoneData() {
        if(socket == null || this.context == null)
            return;
        String myid = Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);

        String code = Preferences.getString("code", null, context);
        if(code == null) {
            code = String.valueOf((int) Math.floor((Math.random() * 9999)));
            Preferences.putString("code", code, context);
        }

        socket.send("handshake", "{\"e\":\"mobile\",\"imei\":\""+myid+"\",\"system\":\"android\",\"genkeycode\":\""+code+"\"}");
    }
}
