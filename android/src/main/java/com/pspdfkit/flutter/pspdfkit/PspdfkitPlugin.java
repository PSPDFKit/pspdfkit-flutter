package com.pspdfkit.flutter.pspdfkit;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;

import android.widget.Toast;

import com.pspdfkit.PSPDFKit;
import com.pspdfkit.configuration.activity.PdfActivityConfiguration;
import com.pspdfkit.ui.PdfActivity;

import java.io.File;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.support.v4.app.ActivityCompat.requestPermissions;
import static android.support.v4.content.ContextCompat.checkSelfPermission;

/**
 * Pspdfkit Plugin.
 */
public class PspdfkitPlugin implements MethodCallHandler {

    private static final String TAG = "PspdfkitPlugin";
    private static final String[] PERMISSIONS_OPEN_DOCUMENT = {Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE};
    private final Context context;

    public PspdfkitPlugin(Context context) {
        this.context = context;


        // Request runtime permissions on Android Marshmallow and upwards.
        arePermissionGranted();
    }

    private boolean arePermissionGranted() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions((Activity) context, PERMISSIONS_OPEN_DOCUMENT, 999);
                return false;
            }
        }
        return true;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "pspdfkit");
        channel.setMethodCallHandler(new PspdfkitPlugin(registrar.activeContext()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "frameworkVersion":
                result.success("Android " + PSPDFKit.VERSION);
                break;
            case "openExternalDocument":
                if (arePermissionGranted()) {
                    String documentName = call.argument("document");
                    final Uri localDocument = Uri.fromFile(new File(Environment.getExternalStorageDirectory(), documentName));
                    PdfActivity.showDocument(context, localDocument, new PdfActivityConfiguration.Builder(context).build());
                } else {
                    Toast.makeText(context, "PSPDFKit Flutter plugin needs extra permissions to open an external correctly.", Toast.LENGTH_LONG).show();
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
