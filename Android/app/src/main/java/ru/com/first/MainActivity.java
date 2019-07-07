package ru.com.first;

import android.Manifest;
import android.app.AlertDialog;
import android.app.admin.DeviceAdminReceiver;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.SparseArray;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.vision.CameraSource;
import com.google.android.gms.vision.Detector;
import com.google.android.gms.vision.barcode.Barcode;
import com.google.android.gms.vision.barcode.BarcodeDetector;

import org.w3c.dom.Text;

import java.io.IOException;
import java.lang.reflect.Method;
import java.util.StringTokenizer;

public class MainActivity extends AppCompatActivity {
    private boolean running = true;
    private int ENABLE_ADMIN_REQUEST_CODE = 666;
    View blocked;
    View unblocked;
    View qrcode;
    View usercode;
    private BarcodeDetector detector;
    private SurfaceView cameraView;
    private TextView barcodeHint;
    private CameraSource cameraSource;
    private boolean gotit;
    public static final int MY_PERMISSIONS_REQUEST_CAMERA = 555;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        DevicePolicyManager devicePolicyManager = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
        ComponentName deviceAdminReceiver = new ComponentName(this, MainAdminReciever.class);
        blocked = findViewById(R.id.blocked);
        unblocked = findViewById(R.id.unblocked);
        qrcode = findViewById(R.id.qrcode);
        usercode = findViewById(R.id.usercode);
        cameraView = (SurfaceView) findViewById(R.id.cameraView);
        barcodeHint = (TextView) findViewById(R.id.barcodeHint);


        if (devicePolicyManager.isAdminActive(deviceAdminReceiver)) {
            devicePolicyManager.setCameraDisabled(deviceAdminReceiver, true);
        } else {
            Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdminReceiver);
            startActivityForResult(intent, ENABLE_ADMIN_REQUEST_CODE);
            devicePolicyManager.setCameraDisabled(deviceAdminReceiver, true);
        }
        startService(new Intent(this, WorkingService.class));

        running = true;
        startQRcode();

        new Thread(new Runnable() {
            @Override
            public void run() {
                while(running) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (PhoneBlockUtils.getServer() == null) {
                                //nothing
                            } else {
                                if (PhoneBlockUtils.isPhoneBlocked()) {
                                    setBlockedView();
                                } else {
                                    setUnblockedView();
                                }
                            }
                            String id = Preferences.getString("id", null, MainActivity.this);
                            if (id != null) {
                                TextView blocked_id = (TextView) MainActivity.this.findViewById(R.id.blocked_id);
                                TextView unblocked_id = (TextView) MainActivity.this.findViewById(R.id.unblocked_id);
                                blocked_id.setText(id);
                                unblocked_id.setText(id);
                            }
                        }
                    });
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }).start();
    }

    private void startQRcode() {
        setQRcodeView();
        PhoneBlockUtils.unblockPhone(this);
        PhoneBlockUtils.clear();
        SurfaceView measureView = (SurfaceView)findViewById(R.id.cameraView);
        final int width = measureView.getMeasuredWidth() < 100 ? 600 : measureView.getMeasuredWidth();
        final int height = measureView.getMeasuredHeight() < 100 ? 600 : measureView.getMeasuredHeight();
        detector = new BarcodeDetector.Builder(this).setBarcodeFormats(Barcode.QR_CODE).build();
        cameraSource = new CameraSource.Builder(this, detector).setRequestedPreviewSize(width, height).setAutoFocusEnabled(true).build();

        cameraView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                if (checkCameraPermission()) {

                    if(cameraSource == null)
                        cameraSource = new CameraSource.Builder(MainActivity.this, detector).setRequestedPreviewSize(width, height).setAutoFocusEnabled(true).build();
                    try {
                        PhoneBlockUtils.unblockPhone(MainActivity.this);
                        cameraSource.start(cameraView.getHolder());
                    }
                    catch (Exception ec)
                    {
                        ec.printStackTrace();
                        try {
                            PhoneBlockUtils.unblockPhone(MainActivity.this);
                            cameraSource.start(cameraView.getHolder());
                        }
                        catch (Exception ec2) {
                            ec2.printStackTrace();
                        }

                    }
                }
            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

            }

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                cameraSource.stop();
            }
        });


        detector.setProcessor(new Detector.Processor<Barcode>() {
            @Override
            public void release() {

            }

            @Override
            public void receiveDetections(Detector.Detections<Barcode> detections) {
                final SparseArray<Barcode> barcodes = detections.getDetectedItems();
                if (barcodes.size() != 0 && !gotit) {
                    barcodeHint.post(new Runnable() {
                        @Override
                        public void run() {
                            String url = barcodes.valueAt(0).displayValue;
                            if( cameraSource != null)
                                cameraSource.stop();
                            PhoneBlockUtils.setServer(url, MainActivity.this);
                        }
                    });
                }
            }
        });
    }
    public boolean checkCameraPermission() {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {

            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.CAMERA)) {
                //показываем диалог
                new AlertDialog.Builder(this)
                        .setTitle(R.string.title_camera_permission)
                        .setMessage(R.string.text_camera_permission)
                        .setPositiveButton(R.string.action_ok, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                //Юзер одобрил
                                ActivityCompat.requestPermissions(MainActivity.this,
                                        new String[]{Manifest.permission.CAMERA},
                                        MY_PERMISSIONS_REQUEST_CAMERA);
                            }
                        })
                        .create()
                        .show();


            } else {
                //запрашиваем пермишен, уже не показывая диалогов с пояснениями
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.CAMERA},
                        MY_PERMISSIONS_REQUEST_CAMERA);
            }
            return false;
        } else {
            return true;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_CAMERA: {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // пермишен получен можем работать с locationManager
                    if (ContextCompat.checkSelfPermission(this,
                            Manifest.permission.CAMERA)
                            == PackageManager.PERMISSION_GRANTED) {

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    if (ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                                        cameraSource.start(cameraView.getHolder());
                                    }
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            }
                        });


                    }

                } else {
                }
                return;
            }

        }
    }



    @Override
    protected void onDestroy() {
        super.onDestroy();
        running = false;
    }

    private void startBlocking() {
        running = true;
        new Thread(new Runnable() {
            public void run() {
                try {
                    Thread.sleep(300);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                while(running) {
                    runOnUiThread(new Runnable() {
                        public void run() {
                            if(PhoneBlockUtils.isPhoneBlocked())
                                setBlockedView();
                            else
                                setUnblockedView();

                        }
                    });
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }).start();
    }

    private void setQRcodeView()
    {
        blocked.setVisibility(View.GONE);
        unblocked.setVisibility(View.GONE);
        qrcode.setVisibility(View.VISIBLE);
        usercode.setVisibility(View.GONE);
    }

    private void setUserCodeView()
    {
        blocked.setVisibility(View.GONE);
        unblocked.setVisibility(View.GONE);
        qrcode.setVisibility(View.GONE);
        usercode.setVisibility(View.VISIBLE);
    }

    private void setBlockedView()
    {
        blocked.setVisibility(View.VISIBLE);
        unblocked.setVisibility(View.GONE);
        qrcode.setVisibility(View.GONE);
        usercode.setVisibility(View.GONE);
    }

    private void setUnblockedView()
    {
        blocked.setVisibility(View.GONE);
        unblocked.setVisibility(View.VISIBLE);
        qrcode.setVisibility(View.GONE);
        usercode.setVisibility(View.GONE);
    }

}
