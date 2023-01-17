/*
 * Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit;

import static com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireDocumentNotNull;
import static com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty;
import static com.pspdfkit.flutter.pspdfkit.util.Utilities.addFileSchemeIfMissing;
import static com.pspdfkit.flutter.pspdfkit.util.Utilities.areValidIndexes;
import static com.pspdfkit.flutter.pspdfkit.util.Utilities.isImageDocument;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import com.pspdfkit.PSPDFKit;
import com.pspdfkit.configuration.PdfConfiguration;
import com.pspdfkit.configuration.activity.PdfActivityConfiguration;
import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.document.formatters.DocumentJsonFormatter;
import com.pspdfkit.exceptions.PSPDFKitException;
import com.pspdfkit.flutter.pspdfkit.pdfgeneration.PdfPageAdaptor;
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider;
import com.pspdfkit.forms.ChoiceFormElement;
import com.pspdfkit.forms.EditableButtonFormElement;
import com.pspdfkit.forms.SignatureFormElement;
import com.pspdfkit.forms.TextFormElement;
import com.pspdfkit.instant.document.InstantPdfDocument;
import com.pspdfkit.instant.ui.InstantPdfActivityIntentBuilder;
import com.pspdfkit.ui.PdfActivity;
import com.pspdfkit.ui.PdfActivityIntentBuilder;
import com.pspdfkit.ui.special_mode.controller.AnnotationTool;

import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

/**
 * PSPDFKit plugin to load PDF and image documents.
 */
public class PspdfkitPlugin
        implements
        MethodCallHandler,
        PluginRegistry.RequestPermissionsResultListener,
        FlutterPlugin,
        ActivityAware {
    @NonNull
    private static final EventDispatcher eventDispatcher = EventDispatcher.getInstance();
    private static final String LOG_TAG = "PSPDFKitPlugin";

    /**
     * Hybrid technology where the application is supposed to be working on.
     */
    private static final String HYBRID_TECHNOLOGY = "Flutter";

    /**
     * Atomic reference that prevents sending twice the permission result and throwing exception.
     */
    @NonNull
    private final AtomicReference<Result> permissionRequestResult;

    @Nullable
    private ActivityPluginBinding activityPluginBinding;

    public PspdfkitPlugin() {
        this.permissionRequestResult = new AtomicReference<>();
    }

    /**
     * Holds the disposables.
     */
    private Disposable disposable;

    /**
     * This {@code FlutterPlugin} has been associated with a {@link FlutterEngine} instance.
     *
     * <p>Relevant resources that this {@code FlutterPlugin} may need are provided via the {@code
     * binding}. The {@code binding} may be cached and referenced until {@link
     * #onDetachedFromEngine(FlutterPluginBinding)} is invoked and returns.
     */
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        final MethodChannel channel = new MethodChannel(
                binding.getBinaryMessenger(),
                "com.pspdfkit.global"
        );
        channel.setMethodCallHandler(this);
        eventDispatcher.setChannel(channel);

        // Register the view factory for the PSPDFKit widget provided by `PSPDFKitViewFactory`.
        binding
                .getPlatformViewRegistry()
                .registerViewFactory(
                        "com.pspdfkit.widget",
                        new PSPDFKitViewFactory(binding.getBinaryMessenger())
                );
    }

    /**
     * This {@code FlutterPlugin} has been removed from a {@link FlutterEngine} instance.
     *
     * <p>The {@code binding} passed to this method is the same instance that was passed in {@link
     * #onAttachedToEngine(FlutterPluginBinding)}. It is provided again in this method as a
     * convenience. The {@code binding} may be referenced during the execution of this method, but it
     * must not be cached or referenced after this method returns.
     *
     * <p>{@code FlutterPlugin}s should release all resources in this method.
     */
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        eventDispatcher.setChannel(null);
        if (disposable != null) {
            disposable.dispose();
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String fullyQualifiedName;
        PdfDocument document;

        if (activityPluginBinding == null) {
            throw new IllegalStateException(
                    "There is no activity attached. Make sure " +
                            "`onAttachedToActivity` is called before handling any method calls received " +
                            "from Flutter"
            );
        }

        final FragmentActivity activity = (FragmentActivity) activityPluginBinding.getActivity();

        switch (call.method) {
            case "frameworkVersion":
                result.success("Android " + PSPDFKit.VERSION);
                break;
            case "setLicenseKey":
                String licenseKey = call.argument("licenseKey");
                requireNotNullNotEmpty(licenseKey, "License key");
                try {
                    PSPDFKit.initialize(
                            activity,
                            licenseKey,
                            new ArrayList<>(),
                            HYBRID_TECHNOLOGY
                    );
                } catch (PSPDFKitException e) {
                    result.error("PSPDFKitException", e.getMessage(), null);
                }
                break;
            case "setLicenseKeys":
                String androidLicenseKey = call.argument("androidLicenseKey");
                requireNotNullNotEmpty(androidLicenseKey, "Android License key");
                try {
                    PSPDFKit.initialize(
                            activity,
                            androidLicenseKey,
                            new ArrayList<>(),
                            HYBRID_TECHNOLOGY
                    );
                } catch (PSPDFKitException e) {
                    result.error("PSPDFKitException", e.getMessage(), null);
                }
                break;
            case "present":
                String documentPath = call.argument("document");
                requireNotNullNotEmpty(documentPath, "Document path");

                HashMap<String, Object> configurationMap = call.argument(
                        "configuration"
                );
                ConfigurationAdapter configurationAdapter = new ConfigurationAdapter(
                        activity,
                        configurationMap
                );

                documentPath = addFileSchemeIfMissing(documentPath);

                FlutterPdfActivity.setLoadedDocumentResult(result);
                boolean imageDocument = isImageDocument(documentPath);
                Intent intent;
                if (imageDocument) {
                    intent =
                            PdfActivityIntentBuilder
                                    .fromImageUri(activity, Uri.parse(documentPath))
                                    .activityClass(FlutterPdfActivity.class)
                                    .configuration(configurationAdapter.build())
                                    .build();
                } else {
                    intent =
                            PdfActivityIntentBuilder
                                    .fromUri(activity, Uri.parse(documentPath))
                                    .activityClass(FlutterPdfActivity.class)
                                    .configuration(configurationAdapter.build())
                                    .passwords(configurationAdapter.getPassword())
                                    .build();
                }

                activity.startActivity(intent);
                break;
            case "presentInstant":
                String documentUrl = call.argument("serverUrl");
                String jwt = call.argument("jwt");

                requireNotNullNotEmpty(documentUrl, "Document path");
                requireNotNullNotEmpty(jwt, "JWT");

                HashMap<String, Object> configurationMapInstant = call.argument(
                        "configuration"
                );

                ConfigurationAdapter configurationAdapterInstant = new ConfigurationAdapter(
                        activity,
                        configurationMapInstant
                );

                FlutterInstantPdfActivity.setLoadedDocumentResult(result);
                final List<AnnotationTool> annotationTools = configurationAdapterInstant.build().getConfiguration().getEnabledAnnotationTools();

                annotationTools.add(AnnotationTool.INSTANT_COMMENT_MARKER);

                Intent intentInstant =
                        InstantPdfActivityIntentBuilder
                                .fromInstantDocument(activity, documentUrl, jwt)
                                .activityClass(FlutterInstantPdfActivity.class)
                                .configuration(configurationAdapterInstant.build())
                                .build();

                activity.startActivity(intentInstant);

                break;
            case "checkPermission":
                final String permissionToCheck;
                permissionToCheck = call.argument("permission");
                result.success(checkPermission(activity, permissionToCheck));
                break;
            case "requestPermission":
                final String permissionToRequest;
                permissionToRequest = call.argument("permission");
                permissionRequestResult.set(result);
                requestPermission(activity, permissionToRequest);
                break;
            case "openSettings":
                openSettings(activity);
                result.success(true);
                break;
            case "applyInstantJson":
                String annotationsJson = call.argument("annotationsJson");

                requireNotNullNotEmpty(annotationsJson, "annotationsJson");
                document =
                        requireDocumentNotNull(
                                getCurrentActivity(),
                                "Pspdfkit.applyInstantJson(String)"
                        );

                DocumentJsonDataProvider documentJsonDataProvider = new DocumentJsonDataProvider(
                        annotationsJson
                );
                //noinspection ResultOfMethodCallIgnored
                DocumentJsonFormatter
                        .importDocumentJsonAsync(document, documentJsonDataProvider)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                                () -> result.success(true),
                                throwable ->
                                        result.error(
                                                LOG_TAG,
                                                "Error while importing document Instant JSON",
                                                throwable.getMessage()
                                        )
                        );
                break;
            case "exportInstantJson":
                document =
                        requireDocumentNotNull(
                                getCurrentActivity(),
                                "Pspdfkit.exportInstantJson()"
                        );

                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                //noinspection ResultOfMethodCallIgnored
                DocumentJsonFormatter
                        .exportDocumentJsonAsync(document, outputStream)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                                () ->
                                        result.success(
                                                outputStream.toString(StandardCharsets.UTF_8.name())
                                        ),
                                throwable ->
                                        result.error(
                                                LOG_TAG,
                                                "Error while exporting document Instant JSON",
                                                throwable.getMessage()
                                        )
                        );
                break;
            case "setFormFieldValue":
                String value = call.argument("value");
                fullyQualifiedName = call.argument("fullyQualifiedName");

                requireNotNullNotEmpty(value, "Value");
                requireNotNullNotEmpty(fullyQualifiedName, "Fully qualified name");
                document =
                        requireDocumentNotNull(
                                getCurrentActivity(),
                                "Pspdfkit.setFormFieldValue(String)"
                        );

                //noinspection ResultOfMethodCallIgnored
                document
                        .getFormProvider()
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
                                            ((ChoiceFormElement) formElement).setSelectedIndexes(
                                                    selectedIndexes
                                            );
                                            result.success(true);
                                        } else {
                                            result.error(
                                                    LOG_TAG,
                                                    "\"value\" argument needs a list of " +
                                                            "integers to set selected indexes for a choice " +
                                                            "form element (e.g.: \"1, 3, 5\").",
                                                    null
                                            );
                                        }
                                    } else if (formElement instanceof SignatureFormElement) {
                                        result.error(
                                                "Signature form elements are not supported.",
                                                null,
                                                null
                                        );
                                    } else {
                                        result.success(false);
                                    }
                                },
                                throwable ->
                                        result.error(
                                                LOG_TAG,
                                                String.format(
                                                        "Error while searching for a form element with name %s",
                                                        fullyQualifiedName
                                                ),
                                                throwable.getMessage()
                                        ),
                                // Form element for the given name not found.
                                () -> result.success(false)
                        );
                break;
            case "getFormFieldValue":
                fullyQualifiedName = call.argument("fullyQualifiedName");

                requireNotNullNotEmpty(fullyQualifiedName, "Fully qualified name");
                document =
                        requireDocumentNotNull(
                                getCurrentActivity(),
                                "Pspdfkit.getFormFieldValue()"
                        );

                //noinspection ResultOfMethodCallIgnored
                document
                        .getFormProvider()
                        .getFormElementWithNameAsync(fullyQualifiedName)
                        .subscribeOn(Schedulers.computation())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                                formElement -> {
                                    if (formElement instanceof TextFormElement) {
                                        String text = ((TextFormElement) formElement).getText();
                                        result.success(text);
                                    } else if (formElement instanceof EditableButtonFormElement) {
                                        boolean isSelected =
                                                ((EditableButtonFormElement) formElement).isSelected();
                                        result.success(isSelected ? "selected" : "deselected");
                                    } else if (formElement instanceof ChoiceFormElement) {
                                        List<Integer> selectedIndexes =
                                                ((ChoiceFormElement) formElement).getSelectedIndexes();
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
                                        result.error(
                                                "Signature form elements are not supported.",
                                                null,
                                                null
                                        );
                                    } else {
                                        result.success(false);
                                    }
                                },
                                throwable ->
                                        result.error(
                                                LOG_TAG,
                                                String.format(
                                                        "Error while searching for a form element with name %s",
                                                        fullyQualifiedName
                                                ),
                                                throwable.getMessage()
                                        ),
                                // Form element for the given name not found.
                                () ->
                                        result.error(
                                                LOG_TAG,
                                                String.format(
                                                        "Form element not found with name %s",
                                                        fullyQualifiedName
                                                ),
                                                null
                                        )
                        );
                break;
            case "save":
                document =
                        requireDocumentNotNull(
                                getCurrentActivity(),
                                "Pspdfkit.save()"
                        );

                //noinspection ResultOfMethodCallIgnored
                document
                        .saveIfModifiedAsync()
                        .subscribeOn(Schedulers.computation())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(result::success);

                break;
            case "getTemporaryDirectory":
                result.success(getTemporaryDirectory(activity));
                break;
            case "generatePDF": {
                final PdfPageAdaptor adaptor = new PdfPageAdaptor(activityPluginBinding.getActivity());
                final PspdfkitPdfGenerator processor = new PspdfkitPdfGenerator(adaptor);
                final List<HashMap<String, Object>> pages = call.argument("pages");
                final String outputFilePath = call.argument("outputFilePath");
                if (pages == null || pages.isEmpty()) {
                    result.error("InvalidArgument", "Pages argument is null or empty", null);
                    return;
                }
                requireNotNullNotEmpty(outputFilePath, "Output file path");
                processor.generatePdf(pages, outputFilePath, result);
                break;
            }
            case "generatePdfFromHtmlString": {
                String html = call.argument("html");
                String outputFilePath = call.argument("outputPath");
                HashMap<String, Object> options = call.argument("options");
                requireNotNullNotEmpty(html, "Html");
                requireNotNullNotEmpty(outputFilePath, "Output path");

                PspdfkitHTMLConverter.generateFromHtmlString(
                        activity,
                        html,
                        outputFilePath,
                        options,
                        result
                );
                break;
            }
            case "generatePdfFromHtmlUri": {
                String uriString = call.argument("htmlUri");
                String outputFilePath = call.argument("outputPath");
                HashMap<String, Object> options = call.argument("options");

                requireNotNullNotEmpty(outputFilePath, "Output file path");
                requireNotNullNotEmpty(uriString, "Uri");
                PspdfkitHTMLConverter.generateFromHtmlUri(
                        activity,
                        uriString,
                        outputFilePath,
                        options,
                        result
                );
                break;
            }
            case "setDelayForSyncingLocalChanges": {
                Double delay = call.argument("delay");
                if (delay == null || delay < 0) {
                    result.error("InvalidArgument", "Delay must be a positive number", null);
                    return;
                }
                
                try {
                    document = requireDocumentNotNull(getInstantActivity(), "Pspdfkit.setDelayForSyncingLocalChanges()");
                    ((InstantPdfDocument) document).setDelayForSyncingLocalChanges(delay.longValue());
                    result.success(true);
                } catch (Exception e) {
                    result.error("InstantException", e.getMessage(), null);
                }
                break;
            }
            case "setListenToServerChanges": {
                try {
                    boolean listen = call.argument("listen");
                    document = requireDocumentNotNull(getInstantActivity(), "Pspdfkit.setListenToServerChanges()");
                    ((InstantPdfDocument) document).setListenToServerChanges(listen);
                    result.success(true);
                } catch (Exception e) {
                    result.error("InstantException", e.getMessage(), null);
                }
                break;
            }
            case "syncAnnotations": {
                try {
                    document = requireDocumentNotNull(getInstantActivity(), "Pspdfkit.syncAnnotations()");
                    disposable = ((InstantPdfDocument) document).syncAnnotationsAsync()
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe(result::success,
                                    throwable -> result.error("InstantException", throwable.getMessage(), null));
                } catch (Exception e) {
                    result.error("InstantException", e.getMessage(), null);
                }
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    @NonNull
    private String getTemporaryDirectory(
            @NonNull final FragmentActivity activity
    ) {
        return activity.getCacheDir().getPath();
    }

    // Try tp get Current PdfActivity, this can be either [FlutterPdfActivity] or [FlutterInstantPdfActivity]
    private PdfActivity getCurrentActivity() {
        PdfActivity pdfActivity = FlutterPdfActivity.getCurrentActivity();
        if (pdfActivity == null) {
            pdfActivity = FlutterInstantPdfActivity.getCurrentActivity();
        }
        return pdfActivity;
    }

    private FlutterInstantPdfActivity getInstantActivity() {
        FlutterInstantPdfActivity instantPdfActivity = FlutterInstantPdfActivity.getCurrentActivity();
        if (instantPdfActivity == null) {
            throw new IllegalStateException("No instant activity found");
        }
        return instantPdfActivity;
    }

    private void requestPermission(
            @NonNull final FragmentActivity activity,
            String permission
    ) {
        permission = getManifestPermission(permission);
        if (permission == null) {
            return;
        }
        Log.i(LOG_TAG, "Requesting permission " + permission);
        String[] perm = {permission};
        ActivityCompat.requestPermissions(activity, perm, 0);
    }

    private boolean checkPermission(
            @NonNull final FragmentActivity activity,
            String permission
    ) {
        permission = getManifestPermission(permission);
        if (permission == null) {
            return false;
        }
        Log.i(LOG_TAG, "Checking permission " + permission);
        return (
                PackageManager.PERMISSION_GRANTED ==
                        ContextCompat.checkSelfPermission(activity, permission)
        );
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

    private void openSettings(@NonNull final FragmentActivity activity) {
        Intent intent = new Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:" + activity.getPackageName())
        );
        intent.addCategory(Intent.CATEGORY_DEFAULT);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(intent);
    }

    @Override
    public boolean onRequestPermissionsResult(
            int requestCode,
            String[] permissions,
            int[] grantResults
    ) {
        if (activityPluginBinding == null) {
            throw new IllegalStateException(
                    "There is no activity attached. Make sure " +
                            "`onAttachedToActivity` is called before handling any method calls received " +
                            "from Flutter"
            );
        }

        final FragmentActivity activity = (FragmentActivity) activityPluginBinding.getActivity();

        if (permissions.length == 0) return false;

        int status = 0;
        String permission = permissions[0];
        if (requestCode == 0 && grantResults.length > 0) {
            if (
                    ActivityCompat.shouldShowRequestPermissionRationale(
                            activity,
                            permission
                    )
            ) {
                // Permission denied.
                status = 1;
            } else {
                if (
                        ActivityCompat.checkSelfPermission(activity, permission) ==
                                PackageManager.PERMISSION_GRANTED
                ) {
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

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        binding.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        detachActivityPluginBinding();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(
            @NonNull ActivityPluginBinding binding
    ) {
        activityPluginBinding = binding;
        binding.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        detachActivityPluginBinding();
    }

    private void detachActivityPluginBinding() {
        if (activityPluginBinding != null) {
            activityPluginBinding.removeRequestPermissionsResultListener(this);
            activityPluginBinding = null;
        }
    }
}
