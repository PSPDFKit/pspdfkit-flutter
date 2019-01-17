/*
 *   Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SimplePermissionsPlugin
 */
public class SimplePermissionsPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    private Registrar registrar;
    private Result result;

    private static String MOTION_SENSOR = "MOTION_SENSOR";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "simple_permissions");
        SimplePermissionsPlugin simplePermissionsPlugin = new SimplePermissionsPlugin(registrar);
        channel.setMethodCallHandler(simplePermissionsPlugin);
        registrar.addRequestPermissionsResultListener(simplePermissionsPlugin);
    }

    private SimplePermissionsPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String method = call.method;
        String permission;
        switch (method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "getPermissionStatus":
                permission = call.argument("permission");
                if (MOTION_SENSOR.equalsIgnoreCase(permission)) {
                    result.success(3);
                    break;
                }
                int value = checkPermission(permission) ? 3 : 2;
                result.success(value);
                break;
            case "checkPermission":
                permission = call.argument("permission");
                if (MOTION_SENSOR.equalsIgnoreCase(permission)) {
                    result.success(true);
                    break;
                }
                result.success(checkPermission(permission));
                break;
            case "requestPermission":
                permission = call.argument("permission");
                if (MOTION_SENSOR.equalsIgnoreCase(permission)) {
                    result.success(3);
                    break;
                }
                this.result = result;
                requestPermission(permission);
                break;
            case "openSettings":
                openSettings();
                result.success(true);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void openSettings() {
        Activity activity = registrar.activity();
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:" + activity.getPackageName()));
        intent.addCategory(Intent.CATEGORY_DEFAULT);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(intent);
    }

    private String getManifestPermission(String permission) {
        String res;
        switch (permission) {
            case "RECORD_AUDIO":
                res = Manifest.permission.RECORD_AUDIO;
                break;
            case "CALL_PHONE":
                res = Manifest.permission.CALL_PHONE;
                break;
            case "CAMERA":
                res = Manifest.permission.CAMERA;
                break;
            case "WRITE_EXTERNAL_STORAGE":
                res = Manifest.permission.WRITE_EXTERNAL_STORAGE;
                break;
            case "READ_EXTERNAL_STORAGE":
                res = Manifest.permission.READ_EXTERNAL_STORAGE;
                break;
            case "READ_PHONE_STATE":
                res = Manifest.permission.READ_PHONE_STATE;
                break;
            case "ACCESS_FINE_LOCATION":
                res = Manifest.permission.ACCESS_FINE_LOCATION;
                break;
            case "ACCESS_COARSE_LOCATION":
                res = Manifest.permission.ACCESS_COARSE_LOCATION;
                break;
            case "WHEN_IN_USE_LOCATION":
                res = Manifest.permission.ACCESS_FINE_LOCATION;
                break;
            case "ALWAYS_LOCATION":
                res = Manifest.permission.ACCESS_FINE_LOCATION;
                break;
            case "READ_CONTACTS":
                res = Manifest.permission.READ_CONTACTS;
                break;
            case "SEND_SMS":
                res = Manifest.permission.SEND_SMS;
                break;
            case "READ_SMS":
                res = Manifest.permission.READ_SMS;
                break;
            case "VIBRATE":
                res = Manifest.permission.VIBRATE;
                break;
            case "WRITE_CONTACTS":
                res = Manifest.permission.WRITE_CONTACTS;
                break;
            default:
                res = "ERROR";
                break;
        }
        return res;
    }

    private void requestPermission(String permission) {
        Activity activity = registrar.activity();
        permission = getManifestPermission(permission);
        Log.i("SimplePermission", "Requesting permission : " + permission);
        String[] perm = {permission};
        ActivityCompat.requestPermissions(activity, perm, 0);
    }

    private boolean checkPermission(String permission) {
        Activity activity = registrar.activity();
        permission = getManifestPermission(permission);
        Log.i("SimplePermission", "Checking permission : " + permission);
        return PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(activity, permission);
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        int status = 0;
        String permission = permissions[0];
        if (requestCode == 0 && grantResults.length > 0) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(registrar.activity(), permission)) {
                //denied
                status = 2;
            } else {
                if (ActivityCompat.checkSelfPermission(registrar.context(), permission) == PackageManager.PERMISSION_GRANTED) {
                    //allowed
                    status = 3;
                } else {
                    //set to never ask again
                    Log.e("SimplePermission", "set to never ask again" + permission);
                    status = 4;
                }
            }
        }
        Log.i("SimplePermission", "Requesting permission status : " + status);
        Result result = this.result;
        this.result = null;
        if(result != null) {
            result.success(status);
        }
        return status == 3;
    }
}
