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
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;
import android.util.Log;

import com.pspdfkit.PSPDFKit;
import com.pspdfkit.ui.PdfActivity;

import java.util.HashMap;
import java.util.concurrent.atomic.AtomicReference;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty;

/**
 * PSPDFKit plugin to load PDF and image documents.
 */
public class PspdfkitPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    private static final String LOG_TAG = "PSPDFKitPlugin";
    private static final String FILE_SCHEME = "file:///";
    private final Context context;
    private final Registrar registrar;
    /** Atomic reference that prevents sending twice the permission result and throw exception. */
    private AtomicReference<Result> permissionRequestResult;

    public PspdfkitPlugin(Registrar registrar) {
        this.context = registrar.activeContext();
        this.registrar = registrar;
        this.permissionRequestResult = new AtomicReference<>();
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "pspdfkit");
        PspdfkitPlugin pspdfkitPlugin = new PspdfkitPlugin(registrar);
        channel.setMethodCallHandler(pspdfkitPlugin);
        registrar.addRequestPermissionsResultListener(pspdfkitPlugin);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String permission;

        switch (call.method) {
            case "frameworkVersion":
                result.success("Android " + PSPDFKit.VERSION);
                break;
            case "setLicenseKey":
                String licenseKey = call.argument("licenseKey");
                requireNotNullNotEmpty(licenseKey, "License key");
                PSPDFKit.initialize(context, licenseKey);
                break;
            case "present":
                String documentPath = call.argument("document");
                requireNotNullNotEmpty(documentPath, "Document path");

                HashMap<String, Object> configurationMap = call.argument("configuration");
                ConfigurationAdapter configurationAdapter = new ConfigurationAdapter(context, configurationMap);
                if (Uri.parse(documentPath).getScheme() == null) {
                    if (documentPath.startsWith("/")) {
                        documentPath = documentPath.substring(1);
                    }
                    documentPath = FILE_SCHEME + documentPath;
                }
                boolean imageDocument = isImageDocument(documentPath);
                if (imageDocument) {
                    PdfActivity.showImage(context, Uri.parse(documentPath), configurationAdapter.build());
                } else {
                    PdfActivity.showDocument(context, Uri.parse(documentPath), configurationAdapter.getPassword(), configurationAdapter.build());
                }
                break;
            case "checkPermission":
                permission = call.argument("permission");
                result.success(checkPermission(permission));
                break;
            case "requestPermission":
                permission = call.argument("permission");
                this.permissionRequestResult.set(result);
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

    private void requestPermission(String permission) {
        Activity activity = registrar.activity();
        permission = getManifestPermission(permission);
        if (permission == null) {
            return;
        }
        Log.i(LOG_TAG, "Requesting permission " + permission);
        String[] perm = {permission};
        ActivityCompat.requestPermissions(activity, perm, 0);
    }

    private boolean checkPermission(String permission) {
        Activity activity = registrar.activity();
        permission = getManifestPermission(permission);
        if (permission == null) {
            return false;
        }
        Log.i(LOG_TAG, "Checking permission " + permission);
        return PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(activity, permission);
    }

    private String getManifestPermission(String permission) {
        String res;
        if ("WRITE_EXTERNAL_STORAGE".equals(permission)) {
            res = Manifest.permission.WRITE_EXTERNAL_STORAGE;
        } else {
            Log.e(LOG_TAG, "Not implemented permission " + permission);
            res = null;
        }
        return res;
    }

    private void openSettings() {
        Activity activity = registrar.activity();
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:" + activity.getPackageName()));
        intent.addCategory(Intent.CATEGORY_DEFAULT);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(intent);
    }

    private boolean isImageDocument(@NonNull String documentPath) {
        String extension = "";
        int lastDot = documentPath.lastIndexOf('.');
        if (lastDot != -1) {
            extension = documentPath.substring(lastDot + 1).toLowerCase();
        }
        return extension.equals("png") || extension.equals("jpg") || extension.equals("jpeg");
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (permissions.length == 0) return false;

        int status = 0;
        String permission = permissions[0];
        if (requestCode == 0 && grantResults.length > 0) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(registrar.activity(), permission)) {
                // Permission denied.
                status = 1;
            } else {
                if (ActivityCompat.checkSelfPermission(registrar.context(), permission) == PackageManager.PERMISSION_GRANTED) {
                    // Permission allowed.
                    status = 2;
                } else {
                    // Set to never ask again.
                    Log.i(LOG_TAG, "Set to never ask again " + permission);
                    status = 3;
                }
            }
        }
        Log.i(LOG_TAG, "Requesting permission status: " + status);

        Result result = permissionRequestResult.getAndSet(null);
        if (result != null) {
            result.success(status);
        }
        return status == 2;
    }
}
