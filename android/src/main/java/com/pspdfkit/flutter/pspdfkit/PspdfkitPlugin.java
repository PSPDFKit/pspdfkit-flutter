/*
 *   Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
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

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.pspdfkit.PSPDFKit;
import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.document.formatters.DocumentJsonFormatter;
import com.pspdfkit.document.providers.InputStreamDataProvider;
import com.pspdfkit.forms.ChoiceFormElement;
import com.pspdfkit.forms.EditableButtonFormElement;
import com.pspdfkit.forms.SignatureFormElement;
import com.pspdfkit.forms.TextFormElement;
import com.pspdfkit.ui.PdfActivityIntentBuilder;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

import static com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireDocumentNotNull;
import static com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty;

/**
 * PSPDFKit plugin to load PDF and image documents.
 */
public class PspdfkitPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    @NonNull private static final EventDispatcher eventDispatcher = EventDispatcher.getInstance();
    private static final String LOG_TAG = "PSPDFKitPlugin";
    private static final String FILE_SCHEME = "file:///";
    @NonNull private final Context context;
    @NonNull private final Registrar registrar;
    /** Atomic reference that prevents sending twice the permission result and throwing exception. */
    @NonNull private final AtomicReference<Result> permissionRequestResult;

    private PspdfkitPlugin(Registrar registrar) {
        this.context = registrar.activeContext();
        this.registrar = registrar;
        this.permissionRequestResult = new AtomicReference<>();
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.pspdfkit.global");
        PspdfkitPlugin pspdfkitPlugin = new PspdfkitPlugin(registrar);
        channel.setMethodCallHandler(pspdfkitPlugin);
        eventDispatcher.setChannel(channel);
        registrar.addRequestPermissionsResultListener(pspdfkitPlugin);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String fullyQualifiedName;
        PdfDocument document;

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

                documentPath = addFileSchemeIfMissing(documentPath);

                FlutterPdfActivity.setLoadedDocumentResult(result);
                boolean imageDocument = isImageDocument(documentPath);
                if (imageDocument) {
                    Intent intent = PdfActivityIntentBuilder.fromImageUri(context, Uri.parse(documentPath))
                            .activityClass(FlutterPdfActivity.class)
                            .configuration(configurationAdapter.build())
                            .build();
                    context.startActivity(intent);

                } else {
                    Intent intent = PdfActivityIntentBuilder.fromUri(context, Uri.parse(documentPath))
                            .activityClass(FlutterPdfActivity.class)
                            .configuration(configurationAdapter.build())
                            .passwords(configurationAdapter.getPassword())
                            .build();
                    context.startActivity(intent);
                }
                break;
            case "checkPermission":
                final String permissionToCheck;
                permissionToCheck = call.argument("permission");
                result.success(checkPermission(permissionToCheck));
                break;
            case "requestPermission":
                final String permissionToRequest;
                permissionToRequest = call.argument("permission");
                permissionRequestResult.set(result);
                requestPermission(permissionToRequest);
                break;
            case "openSettings":
                openSettings();
                result.success(true);
                break;
            case "applyInstantJson":
                String annotationsJson = call.argument("annotationsJson");

                requireNotNullNotEmpty(annotationsJson, "annotationsJson");
                document = requireDocumentNotNull(FlutterPdfActivity.getCurrentActivity(), "Pspdfkit.applyInstantJson(String)");

                DocumentJsonDataProvider documentJsonDataProvider = new DocumentJsonDataProvider(annotationsJson);
                //noinspection ResultOfMethodCallIgnored
                DocumentJsonFormatter.importDocumentJsonAsync(document, documentJsonDataProvider)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                                () -> result.success(true),
                                throwable -> result.error(LOG_TAG,
                                        "Error while importing document Instant JSON",
                                        throwable.getMessage()));
                break;
            case "exportInstantJson":
                document = requireDocumentNotNull(FlutterPdfActivity.getCurrentActivity(), "Pspdfkit.exportInstantJson()");

                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                //noinspection ResultOfMethodCallIgnored
                DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                                () -> result.success(outputStream.toString(StandardCharsets.UTF_8.name())),
                                throwable -> result.error(LOG_TAG,
                                        "Error while exporting document Instant JSON",
                                        throwable.getMessage()));
                break;
            case "setFormFieldValue":
                String value = call.argument("value");
                fullyQualifiedName = call.argument("fullyQualifiedName");

                requireNotNullNotEmpty(value, "Value");
                requireNotNullNotEmpty(fullyQualifiedName, "Fully qualified name");
                document = requireDocumentNotNull(FlutterPdfActivity.getCurrentActivity(), "Pspdfkit.setFormFieldValue(String)");

                //noinspection ResultOfMethodCallIgnored
                document.getFormProvider()
                        .getFormElementWithNameAsync(fullyQualifiedName)
                        .subscribeOn(Schedulers.computation())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                                formElement -> {
                                    if (formElement instanceof TextFormElement) {
                                        ((TextFormElement) formElement).setText(value);
                                        result.success(true);
                                    } else if (formElement instanceof EditableButtonFormElement) {
                                        if (value.equals("selected")) {
                                            ((EditableButtonFormElement) formElement).select();
                                            result.success(true);
                                        } else if (value.equals("deselected")) {
                                            ((EditableButtonFormElement) formElement).deselect();
                                            result.success(true);
                                        } else {
                                            result.success(false);
                                        }
                                    } else if (formElement instanceof ChoiceFormElement) {
                                        List<Integer> selectedIndexes = new ArrayList<>();
                                        if (areValidIndexes(value, selectedIndexes)) {
                                            ((ChoiceFormElement) formElement).setSelectedIndexes(selectedIndexes);
                                            result.success(true);
                                        } else {
                                            result.error(LOG_TAG, "\"value\" argument needs a list of " +
                                                    "integers to set selected indexes for a choice " +
                                                    "form element (e.g.: \"1, 3, 5\").", null);
                                        }
                                    } else if (formElement instanceof SignatureFormElement) {
                                        result.error("Signature form elements are not supported.", null, null);
                                    } else {
                                        result.success(false);
                                    }
                                },
                                throwable -> result.error(LOG_TAG,
                                        String.format("Error while searching for a form element with name %s", fullyQualifiedName),
                                        throwable.getMessage()),
                                // Form element for the given name not found.
                                () -> result.success(false)
                        );
                break;
            case "getFormFieldValue":
                fullyQualifiedName = call.argument("fullyQualifiedName");

                requireNotNullNotEmpty(fullyQualifiedName, "Fully qualified name");
                document = requireDocumentNotNull(FlutterPdfActivity.getCurrentActivity(), "Pspdfkit.getFormFieldValue()");

                //noinspection ResultOfMethodCallIgnored
                document.getFormProvider()
                        .getFormElementWithNameAsync(fullyQualifiedName)
                        .subscribeOn(Schedulers.computation())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                                formElement -> {
                                    if (formElement instanceof TextFormElement) {
                                        String text = ((TextFormElement) formElement).getText();
                                        result.success(text);
                                    } else if (formElement instanceof EditableButtonFormElement) {
                                        boolean isSelected = ((EditableButtonFormElement) formElement).isSelected();
                                        result.success(isSelected ? "selected" : "deselected");
                                    } else if (formElement instanceof ChoiceFormElement) {
                                        List<Integer> selectedIndexes = ((ChoiceFormElement) formElement).getSelectedIndexes();
                                        StringBuilder stringBuilder = new StringBuilder();
                                        Iterator<Integer> iterator = selectedIndexes.iterator();
                                        while (iterator.hasNext()) {
                                            stringBuilder.append(iterator.next());
                                            if (iterator.hasNext()) {
                                                stringBuilder.append(",");
                                            }
                                        }
                                        result.success(stringBuilder.toString());
                                    } else if (formElement instanceof SignatureFormElement) {
                                        result.error("Signature form elements are not supported.", null, null);
                                    } else {
                                        result.success(false);
                                    }
                                },
                                throwable -> result.error(LOG_TAG,
                                        String.format("Error while searching for a form element with name %s", fullyQualifiedName),
                                        throwable.getMessage()),
                                // Form element for the given name not found.
                                () -> result.error(LOG_TAG,
                                        String.format("Form element not found with name %s", fullyQualifiedName),
                                        null)
                        );
                break;
            case "save":
                document = requireDocumentNotNull(FlutterPdfActivity.getCurrentActivity(), "Pspdfkit.save()");

                //noinspection ResultOfMethodCallIgnored
                document.saveIfModifiedAsync()
                        .subscribeOn(Schedulers.computation())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(result::success);

                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean areValidIndexes(String value, List<Integer> selectedIndexes) {
        String[] indexes = value.split(",");
        try {
            for (String index : indexes) {
                if (index.trim().isEmpty()) continue;
                selectedIndexes.add(Integer.parseInt(index.trim()));
            }
        } catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    private String addFileSchemeIfMissing(String documentPath) {
        if (Uri.parse(documentPath).getScheme() == null) {
            if (documentPath.startsWith("/")) {
                documentPath = documentPath.substring(1);
            }
            documentPath = FILE_SCHEME + documentPath;
        }
        return documentPath;
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

    /** A small in-memory data provider for loading the Document instant JSON from a string. */
    private static class DocumentJsonDataProvider extends InputStreamDataProvider {
        @NonNull private final byte[] annotationsJsonBytes;
        @NonNull private final UUID uuid;

        DocumentJsonDataProvider(@NonNull final String annotationsJson) {
            this.annotationsJsonBytes = annotationsJson.getBytes(StandardCharsets.UTF_8);
            this.uuid = UUID.nameUUIDFromBytes(annotationsJsonBytes);
        }
        @NonNull
        @Override
        protected InputStream openInputStream() {
            return new ByteArrayInputStream(annotationsJsonBytes);
        }

        @Override
        public long getSize() {
            return annotationsJsonBytes.length;
        }

        @NonNull
        @Override
        public String getUid() {
            return String.format("document-instant-json-%s", uuid.toString());
        }

        @Nullable
        @Override
        public String getTitle() {
            return null;
        }
    }
}
