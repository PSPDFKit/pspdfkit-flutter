/*
 * Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
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
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import com.pspdfkit.PSPDFKit;
import com.pspdfkit.annotations.AnnotationType;
import com.pspdfkit.annotations.configuration.AnnotationConfiguration;
import com.pspdfkit.document.DocumentSaveOptions;
import com.pspdfkit.document.PdfDocument;
import com.pspdfkit.document.PdfVersion;
import com.pspdfkit.document.formatters.DocumentJsonFormatter;
import com.pspdfkit.document.processor.PdfProcessor;
import com.pspdfkit.document.processor.PdfProcessorTask;
import com.pspdfkit.exceptions.PSPDFKitException;
import com.pspdfkit.flutter.pspdfkit.pdfgeneration.PdfPageAdaptor;
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider;
import com.pspdfkit.flutter.pspdfkit.util.MeasurementHelper;
import com.pspdfkit.flutter.pspdfkit.util.ProcessorHelper;
import com.pspdfkit.forms.ChoiceFormElement;
import com.pspdfkit.forms.EditableButtonFormElement;
import com.pspdfkit.forms.SignatureFormElement;
import com.pspdfkit.forms.TextFormElement;
import com.pspdfkit.instant.document.InstantPdfDocument;
import com.pspdfkit.instant.ui.InstantPdfActivityIntentBuilder;
import com.pspdfkit.listeners.SimpleDocumentListener;
import com.pspdfkit.ui.PdfActivity;
import com.pspdfkit.ui.PdfActivityIntentBuilder;
import com.pspdfkit.ui.PdfFragment;
import com.pspdfkit.ui.special_mode.controller.AnnotationTool;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
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
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;
import io.reactivex.rxjava3.disposables.Disposable;
import io.reactivex.rxjava3.schedulers.Schedulers;
import io.reactivex.rxjava3.subscribers.DisposableSubscriber;


/**
 * PSPDFKit plugin to load PDF and image documents.
 */
public class PspdfkitPlugin
        implements
        MethodCallHandler,
        PluginRegistry.RequestPermissionsResultListener,
        FlutterPlugin,
        ActivityAware, Application.ActivityLifecycleCallbacks {
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

    @Nullable
    private List<Map<String,Object>> measurementValueConfigurations;

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

    @SuppressLint("CheckResult")
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
                setLicenseKey(activity, licenseKey);
                break;
            case "setLicenseKeys":
                 String androidLicenseKey = call.argument("androidLicenseKey");
                setLicenseKey(activity, androidLicenseKey);
                break;
            case "present":
                String documentPath = call.argument("document");
                requireNotNullNotEmpty(documentPath, "Document path");
                documentPath = addFileSchemeIfMissing(documentPath);

                HashMap<String, Object> configurationMap = call.argument(
                        "configuration"
                );
                ConfigurationAdapter configurationAdapter = new ConfigurationAdapter(
                        activity,
                        configurationMap
                );

                measurementValueConfigurations = (List<Map<String, Object>>)
                        (configurationMap != null ? configurationMap.get("measurementValueConfigurations") : null);

                activity.getApplication().registerActivityLifecycleCallbacks(this);

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
                final  List<Map<String,Object>> measurementValueConfigurationsInstant = call.argument("measurementValueConfigurations");

                FlutterInstantPdfActivity.setLoadedDocumentResult(result);
                FlutterInstantPdfActivity.setMeasurementValueConfigurations(measurementValueConfigurationsInstant);

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
                    boolean listen = Boolean.TRUE.equals(call.argument("listen"));
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
            case "addMeasurementValueConfiguration" : {
                try {
                    Map<String, Object> configuration = call.argument("measurementValueConfiguration");
                    if (configuration == null) {
                        result.error("PSPDFKitMeasurementException", "Invalid measurement configuration", null);
                        return;
                    }
                    if (getCurrentActivity().getPdfFragment() == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null);
                        return;
                    }
                    MeasurementHelper.addMeasurementConfiguration(getCurrentActivity().getPdfFragment(), configuration);
                } catch (Exception e) {
                    result.error("PSPDFKitMeasurementException", e.getMessage(), null);
                }
                break;
            }
            case "getMeasurementValueConfiguration" :{
                try {
                    if (getCurrentActivity().getPdfFragment() == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null);
                        return;
                    }
                    List<Map<String, Object>> measurementConfigurations = MeasurementHelper.getMeasurementConfigurations(getCurrentActivity().getPdfFragment());
                    result.success(measurementConfigurations);
                } catch (Exception e) {
                    result.error("PSPDFKitMeasurementException", e.getMessage(), null);
                }
                break;
            }
             case  "modifyMeasurementValueConfiguration" : {
                try {
                    Map<String, Object> args = call.argument("payload");
                    if (args == null) {
                        result.error("PSPDFKitMeasurementException", "Invalid measurement configuration", null);
                        return;
                    }
                    if (getCurrentActivity().getPdfFragment() == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null);
                        return;
                    }
                    MeasurementHelper.modifyMeasurementConfiguration(getCurrentActivity().getPdfFragment(), args);
                } catch (Exception e) {
                    result.error("PSPDFKitMeasurementException", e.getMessage(), null);
                }
                break;
            }
            case "removeMeasurementValueConfiguration" : {
                try {
                    Map<String, Object> configuration = call.argument("payload");
                    if (configuration == null) {
                        result.error("PSPDFKitMeasurementException", "Invalid measurement configuration", null);
                        return;
                    }
                    if (getCurrentActivity().getPdfFragment() == null) {
                        result.error("PSPDFKitMeasurementException", "PdfFragment is null", null);
                        return;
                    }
                    MeasurementHelper.removeMeasurementConfiguration(getCurrentActivity().getPdfFragment(), configuration);
                } catch (Exception e) {
                    result.error("PSPDFKitMeasurementException", e.getMessage(), null);
                }
                break;
            }
            case "setAnnotationPresetConfigurations": {
                try {
                    Map<String, Object> annotationConfigurations = call.argument("annotationConfigurations");
                    if (annotationConfigurations == null) {
                        result.error("InvalidArgument", "Annotation configurations must be a valid map", null);
                        return;
                    }
                    Map<AnnotationType, AnnotationConfiguration> configurations =
                            AnnotationConfigurationAdaptor
                                    .convertAnnotationConfigurations(getInstantActivity(), annotationConfigurations);

                    PdfFragment pdfFragment = getCurrentActivity().getPdfFragment();
                    if (pdfFragment == null) {
                        result.error("InvalidState", "PdfFragment is null", null);
                        return;
                    }
                    for (Map.Entry<AnnotationType, AnnotationConfiguration> entry : configurations.entrySet()) {
                        pdfFragment.getAnnotationConfiguration().put(entry.getKey(), entry.getValue());
                    }
                    result.success(true);
                } catch (Exception e) {
                    result.error("AnnotationException", e.getMessage(), null);
                }
                break;
            }
            case "processAnnotations": {
                String outputFilePath = call.argument("destinationPath");
                String annotationTypeString = call.argument("type");
                String processingModeString = call.argument("processingMode");

                // Check if the output path is valid.
                if (outputFilePath == null || outputFilePath.isEmpty()) {
                    result.error("InvalidArgument", "Output path must be a valid string", null);
                    return;
                }

                // Check if the annotation type is valid.
                if (annotationTypeString == null || annotationTypeString.isEmpty()) {
                    result.error("InvalidArgument", "Annotation type must be a valid string", null);
                    return;
                }

                // Check if the processing mode is valid.
                if (processingModeString == null || processingModeString.isEmpty()) {
                    result.error("InvalidArgument", "Processing mode must be a valid string", null);
                    return;
                }

                // Get the annotation type and processing mode.
                AnnotationType annotationType = ProcessorHelper.annotationTypeFromString(annotationTypeString);
                PdfProcessorTask.AnnotationProcessingMode processingMode = ProcessorHelper.processModeFromString(processingModeString);
                File outputPath = new File(outputFilePath);

                if (Objects.requireNonNull(outputPath.getParentFile()).exists() || outputPath.getParentFile().mkdirs()) {
                    Log.d(LOG_TAG, "Output path is valid");
                } else {
                    result.error("InvalidArgument", "Output path "+ outputPath.getAbsolutePath()+" is invalid", null);
                    return;
                }

                document = requireDocumentNotNull(getInstantActivity(), "Pspdfkit.processAnnotations()");
                PdfProcessorTask task;

                // Check if we need to process all annotations or only annotations of a specific type.
                if (annotationType == AnnotationType.NONE){
                  task  = PdfProcessorTask.fromDocument(document).changeAllAnnotations(processingMode);
                }else{
                    task = PdfProcessorTask.fromDocument(document).changeAnnotationsOfType(annotationType, processingMode);
                }
                PdfProcessor.processDocumentAsync(task,outputPath)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribeWith(new DisposableSubscriber<PdfProcessor.ProcessorProgress>() {
                            @Override
                            public void onComplete() {
                                result.success(true);
                            }
                            @Override
                            public void onError(Throwable t) {
                                result.error("AnnotationException", t.getMessage(), null);
                            }
                            @Override
                            public void onNext(PdfProcessor.ProcessorProgress processorProgress) {
                                // Notify the progress.
                            }
                        });
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void setLicenseKey(@NonNull final FragmentActivity activity, @Nullable final String licenseKey) {
        try {
            PSPDFKit.initialize(
                    activity,
                    licenseKey,
                    new ArrayList<>(),
                    HYBRID_TECHNOLOGY
            );
        } catch (PSPDFKitException e) {
            throw new IllegalStateException("Error while setting license key", e);
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
            @NonNull String[] permissions,
            @NonNull int[] grantResults
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

    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(@NonNull Activity activity) {

    }

    @Override
    public void onActivityResumed(@NonNull Activity activity) {
        if (activity instanceof FlutterPdfActivity) {
            PdfFragment pdfFragment = ((FlutterPdfActivity) activity).getPdfFragment();
            if (pdfFragment == null) {
                return;
            }
            pdfFragment.addDocumentListener(new SimpleDocumentListener(){
                @Override
                public void onDocumentLoaded(@NonNull PdfDocument document) {
                    super.onDocumentLoaded(document);
                    if (measurementValueConfigurations != null) {
                        for (Map<String, Object> configuration : measurementValueConfigurations) {
                            MeasurementHelper.addMeasurementConfiguration(pdfFragment, configuration);
                        }
                    }
                }
            });
        }
    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {

    }

    @Override
    public void onActivityStopped(@NonNull Activity activity) {

    }

    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

    }

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {

    }
}
