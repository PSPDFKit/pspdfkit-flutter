/*
 *   Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit;

import android.content.Context;
import android.net.Uri;

import com.pspdfkit.PSPDFKit;
import com.pspdfkit.ui.PdfActivity;

import java.util.HashMap;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty;

/**
 * Pspdfkit Plugin.
 */
public class PspdfkitPlugin implements MethodCallHandler {
    private static final String FILE_SCHEME = "file:///";
    private final Context context;

    public PspdfkitPlugin(Context context) {
        this.context = context;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "pspdfkit");
        channel.setMethodCallHandler(new PspdfkitPlugin(registrar.activeContext()));
        // Include simple permissions plugin to deal with reading 
        // and writing permissions.
        SimplePermissionsPlugin.registerWith(registrar);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
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
                ConfigurationAdapter configurationAdapter;
                configurationAdapter = new ConfigurationAdapter(context, configurationMap);


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
                    PdfActivity.showDocument(context, Uri.parse(documentPath), configurationAdapter.build());
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean isImageDocument(@NonNull String documentPath) {
        String extension = "";
        int lastDot = documentPath.lastIndexOf('.');
        if (lastDot != -1) {
            extension = documentPath.substring(lastDot + 1).toLowerCase();
        }
        return extension.equals("png") || extension.equals("jpg") || extension.equals("jpeg");
    }
}
