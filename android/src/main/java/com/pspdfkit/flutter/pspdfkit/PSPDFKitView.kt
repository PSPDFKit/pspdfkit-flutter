package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import android.net.Uri
import android.view.View
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView
import androidx.fragment.app.commit
import com.pspdfkit.document.formatters.DocumentJsonFormatter
import com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider
import com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty
import com.pspdfkit.flutter.pspdfkit.util.addFileSchemeIfMissing
import com.pspdfkit.flutter.pspdfkit.util.areValidIndexes
import com.pspdfkit.flutter.pspdfkit.util.isImageDocument
import com.pspdfkit.forms.ChoiceFormElement
import com.pspdfkit.forms.EditableButtonFormElement
import com.pspdfkit.forms.SignatureFormElement
import com.pspdfkit.forms.TextFormElement
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.PdfUiFragmentBuilder
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.json.JSONObject
import java.io.ByteArrayOutputStream

internal class PSPDFKitView(
    context: Context,
    id: Int,
    messenger: BinaryMessenger,
    documentPath: String? = null,
    configurationMap: HashMap<String, Any>? = null
) : PlatformView, MethodCallHandler {
    private var fragmentContainerView: FragmentContainerView? = FragmentContainerView(context)
    private val methodChannel: MethodChannel
    private val pdfUiFragment: PdfUiFragment

    init {
        fragmentContainerView?.id = View.generateViewId()
        methodChannel = MethodChannel(messenger, "com.pspdfkit.widget.$id")
        methodChannel.setMethodCallHandler(this)
        val configurationAdapter = ConfigurationAdapter(context, configurationMap)
        val password = configurationAdapter.password
        val pdfConfiguration = configurationAdapter.build()

        //noinspection pspdfkit-experimental
        pdfUiFragment = if (documentPath == null) {
            PdfUiFragmentBuilder.emptyFragment(context).configuration(pdfConfiguration).build()
        } else {
            val uri = Uri.parse(addFileSchemeIfMissing(documentPath))
            val isImageDocument = isImageDocument(documentPath)
            if (isImageDocument) {
                PdfUiFragmentBuilder.fromImageUri(context, uri).configuration(pdfConfiguration)
                    .build()
            } else {
                PdfUiFragmentBuilder.fromUri(context, uri)
                    .configuration(pdfConfiguration)
                    .passwords(password)
                    .build()
            }
        }

        fragmentContainerView?.let {
            it.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(view: View?) {
                    (context as FragmentActivity).supportFragmentManager.commit {
                        add(it.id, pdfUiFragment)
                        setReorderingAllowed(true)
                    }
                }

                override fun onViewDetachedFromWindow(view: View?) {
                    (context as FragmentActivity).supportFragmentManager.commit {
                        remove(pdfUiFragment)
                        setReorderingAllowed(true)
                    }
                }
            })
        }
    }

    override fun getView(): View {
        return fragmentContainerView
            ?: throw IllegalStateException("Fragment container view can't be null.")
    }

    override fun dispose() {
        fragmentContainerView = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Return if the fragment or the document
        // are not ready.
        if (!pdfUiFragment.isAdded) {
            return
        }
        val document = pdfUiFragment.document ?: return

        when (call.method) {
            "applyInstantJson" -> {
                val annotationsJson: String? = call.argument("annotationsJson")
                val documentJsonDataProvider = DocumentJsonDataProvider(
                    requireNotNullNotEmpty(
                        annotationsJson,
                        "annotationsJson"
                    )
                )
                // noinspection checkResult
                DocumentJsonFormatter.importDocumentJsonAsync(document, documentJsonDataProvider)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { result.success(true) }
                    ) { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while importing document Instant JSON",
                            throwable.message
                        )
                    }
            }
            "exportInstantJson" -> {
                val outputStream = ByteArrayOutputStream()
                // noinspection checkResult
                DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { result.success(outputStream.toString(java.nio.charset.StandardCharsets.UTF_8.name())) }
                    ) { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while exporting document Instant JSON",
                            throwable.message
                        )
                    }
            }
            "setFormFieldValue" -> {
                val value: String = requireNotNullNotEmpty(
                    call.argument("value"),
                    "Value"
                )
                val fullyQualifiedName = requireNotNullNotEmpty(
                    call.argument("fullyQualifiedName"),
                    "Fully qualified name"
                )
                // noinspection checkResult
                document.formProvider
                    .getFormElementWithNameAsync(fullyQualifiedName)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { formElement ->
                            if (formElement is TextFormElement) {
                                formElement.setText(value)
                                result.success(true)
                            } else if (formElement is EditableButtonFormElement) {
                                when (value) {
                                    "selected" -> {
                                        formElement.select()
                                        result.success(true)
                                    }
                                    "deselected" -> {
                                        formElement.deselect()
                                        result.success(true)
                                    }
                                    else -> {
                                        result.success(false)
                                    }
                                }
                            } else if (formElement is ChoiceFormElement) {
                                val selectedIndexes: List<Int> = java.util.ArrayList<Int>()
                                if (areValidIndexes(value, selectedIndexes.toMutableList())) {
                                    formElement.selectedIndexes = selectedIndexes
                                    result.success(true)
                                } else {
                                    result.error(
                                        LOG_TAG,
                                        "\"value\" argument needs a list of " +
                                            "integers to set selected indexes for a choice " +
                                            "form element (e.g.: \"1, 3, 5\").",
                                        null
                                    )
                                }
                            } else if (formElement is SignatureFormElement) {
                                result.error(
                                    "Signature form elements are not supported.",
                                    null,
                                    null
                                )
                            } else {
                                result.success(false)
                            }
                        },
                        { throwable ->
                            result.error(
                                LOG_TAG,
                                String.format(
                                    "Error while searching for a form element with name %s",
                                    fullyQualifiedName
                                ),
                                throwable.message
                            )
                        }
                    ) // Form element for the given name not found.
                    { result.success(false) }
            }
            "getFormFieldValue" -> {
                val fullyQualifiedName = requireNotNullNotEmpty(
                    call.argument("fullyQualifiedName"),
                    "Fully qualified name"
                )
                // noinspection checkResult
                document.formProvider
                    .getFormElementWithNameAsync(fullyQualifiedName)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { formElement ->
                            when (formElement) {
                                is TextFormElement -> {
                                    val text: String = formElement.text ?: ""
                                    result.success(text)
                                }
                                is EditableButtonFormElement -> {
                                    val isSelected: Boolean =
                                        formElement.isSelected
                                    result.success(if (isSelected) "selected" else "deselected")
                                }
                                is ChoiceFormElement -> {
                                    val selectedIndexes: List<Int> =
                                        formElement.selectedIndexes
                                    val stringBuilder = StringBuilder()
                                    val iterator = selectedIndexes.iterator()
                                    while (iterator.hasNext()) {
                                        stringBuilder.append(iterator.next())
                                        if (iterator.hasNext()) {
                                            stringBuilder.append(",")
                                        }
                                    }
                                    result.success(stringBuilder.toString())
                                }
                                is SignatureFormElement -> {
                                    result.error(
                                        "Signature form elements are not supported.",
                                        null,
                                        null
                                    )
                                }
                                else -> {
                                    result.success(false)
                                }
                            }
                        },
                        { throwable ->
                            result.error(
                                LOG_TAG,
                                String.format(
                                    "Error while searching for a form element with name %s",
                                    fullyQualifiedName
                                ),
                                throwable.message
                            )
                        }
                    ) // Form element for the given name not found.
                    {
                        result.error(
                            LOG_TAG,
                            String.format(
                                "Form element not found with name %s",
                                fullyQualifiedName
                            ),
                            null
                        )
                    }
            }
            "addAnnotation" -> {
                val jsonAnnotation = requireNotNull(call.argument("jsonAnnotation"))

                val jsonString: String = when (jsonAnnotation) {
                    is HashMap<*, *> -> {
                        JSONObject(jsonAnnotation).toString()
                    }
                    is String -> {
                        jsonAnnotation
                    }
                    else -> {
                        result.error(
                            LOG_TAG,
                            "Invalid JSON Annotation.", jsonAnnotation
                        )
                        return
                    }
                }
                // noinspection checkResult
                document.annotationProvider.createAnnotationFromInstantJsonAsync(jsonString)
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { result.success(true) }
                    ) { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while creating annotation from Instant JSON",
                            throwable.message
                        )
                    }
            }
            "getAnnotations" -> {
                val pageIndex: Int = requireNotNull(call.argument("pageIndex"))
                val type: String = requireNotNull(call.argument("type"))

                val annotationJsonList = ArrayList<String>()
                // noinspection checkResult
                document.annotationProvider.getAllAnnotationsOfTypeAsync(
                    AnnotationTypeAdapter.fromString(
                        type
                    ),
                    pageIndex, 1
                )
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { annotation ->
                            annotationJsonList.add(annotation.toInstantJson())
                        },
                        { throwable ->
                            result.error(
                                LOG_TAG,
                                "Error while retrieving annotation of type $type",
                                throwable.message
                            )
                        },
                        { result.success(annotationJsonList) }
                    )
            }
            "getAllUnsavedAnnotations" -> {
                val outputStream = ByteArrayOutputStream()
                // noinspection checkResult
                DocumentJsonFormatter.exportDocumentJsonAsync(document, outputStream)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe({
                        val jsonString: String = outputStream.toString()
                        result.success(jsonString)
                    }, { throwable ->
                        result.error(
                            LOG_TAG,
                            "Error while getting unsaved JSON annotations.",
                            throwable.message
                        )
                    })
            }
            "save" -> {
                // noinspection checkResult
                document.saveIfModifiedAsync()
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(result::success)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val LOG_TAG = "PSPDFKitPlugin"
    }
}

class PSPDFKitViewFactory(
    private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?

        return PSPDFKitView(
            context,
            viewId,
            messenger,
            creationParams?.get("document") as String?,
            creationParams?.get("configuration") as HashMap<String, Any>?
        )
    }
}
