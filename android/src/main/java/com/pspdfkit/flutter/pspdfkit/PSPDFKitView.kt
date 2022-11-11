package com.pspdfkit.flutter.pspdfkit

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.*
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
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
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import com.pspdfkit.ui.drawable.PdfDrawable
import com.pspdfkit.ui.drawable.PdfDrawableProvider
import androidx.annotation.UiThread
import androidx.core.graphics.toRectF
import com.pspdfkit.annotations.AnnotationProvider
import com.pspdfkit.document.PdfBox
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessorTask
import java.io.File
import java.io.IOException
import com.pspdfkit.document.search.TextSearch
import com.pspdfkit.ui.search.PdfSearchViewInline
import com.pspdfkit.ui.search.PdfSearchViewModular
import com.pspdfkit.listeners.OnVisibilityChangedListener
import com.pspdfkit.ui.PSPDFKitViews
import com.pspdfkit.document.formatters.XfdfFormatter
import com.pspdfkit.document.providers.ContentResolverDataProvider
import com.pspdfkit.annotations.AnnotationProvider.OnAnnotationUpdatedListener
import com.pspdfkit.annotations.Annotation
import com.pspdfkit.annotations.AnnotationType
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.listeners.SimpleDocumentListener
import com.pspdfkit.ui.special_mode.controller.AnnotationCreationController
import com.pspdfkit.ui.special_mode.controller.AnnotationEditingController
import com.pspdfkit.ui.special_mode.manager.AnnotationManager
import io.flutter.plugin.common.EventChannel.StreamHandler
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap
import android.content.MutableContextWrapper

internal class PSPDFKitView(
    val context: Context,
    id: Int,
    messenger: BinaryMessenger,
    documentPath: String? = null,
    configurationMap: HashMap<String, Any>? = null
) : PlatformView, MethodCallHandler {
    private var currentEvents: EventChannel.EventSink? = null
    private var fragmentContainerView: FragmentContainerView? = FragmentContainerView(context)
    private val methodChannel: MethodChannel
    private val eventChannel: EventChannel

    private val pdfUiFragment: PdfUiFragment?

    override fun getView(): View {
        return fragmentContainerView
            ?: throw IllegalStateException("Fragment container view can't be null.")
    }


    init {
        fragmentContainerView?.id = View.generateViewId()
        methodChannel = MethodChannel(messenger, "com.pspdfkit.widget.$id")

        eventChannel = EventChannel(messenger, "com.pspdfkit.widget/enter_annotation")

        eventChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                currentEvents = events
            }

            override fun onCancel(arguments: Any?) {
                currentEvents = null
            }

        })

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
                    .pdfFragmentTag(documentPath)
                    .build()
            }
        }

        Handler().postDelayed({

            /*if (pdfUiFragment != null) {
                setEvents()
            } else {
                Handler().postDelayed({
                    if (pdfUiFragment != null) {
                        setEvents()
                    }
                }, 2000)
            }*/
        }, 2000)



        fragmentContainerView?.let {
            it.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(view: View?) {
                    getFragmentActivity(context).supportFragmentManager.commit {
                        add(it.id, pdfUiFragment)
                        setReorderingAllowed(true)
                    }
                }

                override fun onViewDetachedFromWindow(view: View?) {
                    getFragmentActivity(context).supportFragmentManager.commit {
                        remove(pdfUiFragment)
                        setReorderingAllowed(true)
                    }
                }
            })
        }
    }

    // Get Fragment Activity from context
    private fun getFragmentActivity(context: Context): FragmentActivity {
        return when (context) {
            is FragmentActivity -> {
                context
            }
            is MutableContextWrapper -> {
                getFragmentActivity(context.baseContext)
            }
            else -> {
                throw IllegalStateException("Context is not a FragmentActivity")
            }
        }
    }

    private fun setEvents() {
        pdfUiFragment?.pdfFragment?.addOnAnnotationCreationModeChangeListener(object : AnnotationManager.OnAnnotationCreationModeChangeListener {
            override fun onEnterAnnotationCreationMode(p0: AnnotationCreationController) {
                currentEvents?.success(true)
            }

            override fun onChangeAnnotationCreationMode(p0: AnnotationCreationController) {

            }

            override fun onExitAnnotationCreationMode(p0: AnnotationCreationController) {
                currentEvents?.success(false)
            }

        });

        pdfUiFragment?.pdfFragment?.addOnAnnotationEditingModeChangeListener(object : AnnotationManager.OnAnnotationEditingModeChangeListener {
            override fun onEnterAnnotationEditingMode(p0: AnnotationEditingController) {
                currentEvents?.success(true)
            }

            override fun onChangeAnnotationEditingMode(p0: AnnotationEditingController) {

            }

            override fun onExitAnnotationEditingMode(p0: AnnotationEditingController) {
                currentEvents?.success(false)
            }
        });


        /*  pdfUiFragment.pdfFragment?.addDocumentListener(object : SimpleDocumentListener() {
                  @SuppressLint("CheckResult")
                  override fun onPageChanged(document: PdfDocument, pageIndex: Int) {
                      super.onPageChanged(document, pageIndex)

                      val annotationJsonList = ArrayList<String>()

                      document.annotationProvider.getAllAnnotationsOfTypeAsync(
                          EnumSet.allOf(AnnotationType::class.java),
                          pageIndex, 1
                      )
                          .subscribeOn(Schedulers.computation())
                          .observeOn(AndroidSchedulers.mainThread())
                          .subscribe(
                              { annotation ->
                                  annotationJsonList.add(annotation.toInstantJson())
                              },
                              { throwable ->
                              },
                              {

                                  Log.i(LOG_TAG, "*********** annotations size "+annotationJsonList.size)
  //                            result.success(annotationJsonList)

                              }
                          )


                  }

                  override fun onDocumentLoaded(document: PdfDocument) {

                     /* document.annotationProvider.addOnAnnotationUpdatedListener(object : OnAnnotationUpdatedListener {
                          override fun onAnnotationCreated(annotation: Annotation) {

                          }

                          override fun onAnnotationUpdated(annotation: Annotation) {

                          }

                          override fun onAnnotationRemoved(annotation: Annotation) {

                          }

                          override fun onAnnotationZOrderChanged(pageIndex: Int, oldOrder: MutableList<Annotation>, newOrder: MutableList<Annotation>) {

                          }
                      })*/


                  }
              })*/


        /* pdfUiFragment.requirePdfFragment().addOnAnnotationUpdatedListener(object : AnnotationProvider.OnAnnotationUpdatedListener {
                 override fun onAnnotationCreated(annotation: Annotation) {
                     Log.i(LOG_TAG, "The annotation was created.")
                 }

                 override fun onAnnotationUpdated(annotation: Annotation) {
                     Log.i(LOG_TAG, "The annotation was updated.")
                 }

                 override fun onAnnotationRemoved(annotation: Annotation) {
                     Log.i(LOG_TAG, "The annotation was removed.")
                 }
                 override fun onAnnotationZOrderChanged(pageIndex: Int, oldOrder: MutableList<Annotation>, newOrder: MutableList<Annotation>) {
                     Log.i(LOG_TAG, "The annotation was onAnnotationZOrderChanged.")
                 }
             })*/
    }

    override fun dispose() {
        fragmentContainerView = null
    }

    @SuppressLint("CheckResult")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

//        Log.i(LOG_TAG, "*********** onMethodCall " + call.method)
        // Return if the fragment or the document
        // are not ready.
        if (pdfUiFragment != null && !pdfUiFragment.isAdded) {
            result.error(
                LOG_TAG,
                "-",
                "pdf.error"
            )
            return
        }
        val document = pdfUiFragment?.document
        if (document == null) {
            result.error(
                LOG_TAG,
                "-",
                "pdf.error"
            )
            return
        }

        when (call.method) {
            "applyWatermark" -> {

                val watermarkName: String? = call.argument("name")
                val watermarkColor: String? = call.argument("color")
                val watermarkSize: String? = call.argument("size")
                val watermarkOpacity: String? = call.argument("opacity")

                val pdfDrawableProvider: PdfDrawableProvider = object : PdfDrawableProvider() {
                    override fun getDrawablesForPage(
                        context: Context,
                        pdfDocument: com.pspdfkit.document.PdfDocument,
                        pageNumber: Int
                    ): MutableList<PdfDrawable> {
                        val pageBox: RectF = pdfDocument.getPageBox(pageNumber, PdfBox.CROP_BOX)
                        val mutableList = mutableListOf<PdfDrawable>()
                        with(mutableList) {
                            add(WatermarkDrawable(watermarkName, watermarkColor, watermarkSize?.toInt(), watermarkOpacity?.toDouble(), pageBox))
                        }
                        return mutableList;
                    }
                }

                pdfUiFragment?.requirePdfFragment()?.addDrawableProvider(pdfDrawableProvider)

                pdfUiFragment?.pspdfKitViews?.thumbnailBarView?.addDrawableProvider(pdfDrawableProvider)
                pdfUiFragment?.pspdfKitViews?.thumbnailGridView?.addDrawableProvider(pdfDrawableProvider)

                pdfUiFragment?.pspdfKitViews?.outlineView?.addDrawableProvider(pdfDrawableProvider)

                // workaround to draw the watermark on the first page
                pdfUiFragment?.requirePdfFragment()?.apply {
                    val rect = RectF()
                    val currentPage = pageIndex
                    getVisiblePdfRect(rect, currentPage)
                    zoomTo(rect, currentPage, 0)
                }
            }

            "importXfdf" -> {
                val xfdfPath: String? = call.argument("xfdfPath")
                val xfdfUri: Uri = Uri.fromFile(File(xfdfPath))
                XfdfFormatter.parseXfdfAsync(document, ContentResolverDataProvider(xfdfUri))
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { annotations ->

                            for (annotation in annotations) {
                                pdfUiFragment?.requirePdfFragment()?.addAnnotationToPage(annotation, false)
                            }

                            result.success(true)
                        }
                    ) { throwable ->

                        Log.i(LOG_TAG, "*********** ERROR ")
                        result.error(
                            LOG_TAG,
                            "Error while importing document XFDF",
                            throwable.message
                        )
                    }
            }

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

            "getAllAnnotations" -> {
                val annotationJsonList = ArrayList<String>()
                // noinspection checkResult
                document.annotationProvider.getAllAnnotationsOfTypeAsync(
                    EnumSet.allOf(AnnotationType::class.java)
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
                                "Error while retrieving annotations",
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
            "processAnnotations" -> {

                val type: String = requireNotNull(call.argument("type"))
                val processingMode: String = requireNotNull(call.argument("processingMode"))
                val destinationPath: String = requireNotNull(call.argument("destinationPath"))

                val outputFile = try {
                    File(destinationPath).canonicalFile
                } catch (exception: IOException) {
                    throw IllegalStateException("Couldn't create file.", exception)
                }

                val task = PdfProcessorTask.fromDocument(document).changeAllAnnotations(PdfProcessorTask.AnnotationProcessingMode.FLATTEN)

                val result = PdfProcessor.processDocumentAsync(task, outputFile)
                    // Ignore PdfProcessor progress.
                    .ignoreElements()
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        {
                            result.success(true)
                        },
                        { throwable ->
                            result.error(
                                LOG_TAG,
                                "Error while getting unsaved JSON annotations.",
                                throwable.message
                            )
                        }
                    )


            }
            "save" -> {
                // noinspection checkResult
                document.saveIfModifiedAsync()
                    .subscribeOn(Schedulers.computation())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(result::success)
            }

            "addPageChangeListener" -> {


                Log.i(LOG_TAG, "*********** addPageChangeListener ")

                pdfUiFragment?.requirePdfFragment()?.addDocumentListener(object : SimpleDocumentListener() {

                    override fun onPageChanged(document: PdfDocument, pageIndex: Int) {
                        super.onPageChanged(document, pageIndex)

                        Log.i(LOG_TAG, "*********** onPageChanged ")

                        Handler(Looper.getMainLooper()).post {
                            result.success(pageIndex)
                        }

                    }
                })
            }

            "search" -> {

                val term: String = call.argument("term") ?: ""

                /* val textSearch = TextSearch(document, pdfUiFragment.getConfiguration().getConfiguration())
                // val searchResults : List<SearchResult> = textSearch.performSearch(term)

                 val searchSubscription = textSearch.performSearchAsync(term)
                     .subscribeOn(Schedulers.computation())
                     .observeOn(AndroidSchedulers.mainThread())
                     .subscribe { nextResult ->

                        Log.i(LOG_TAG, "*********** nextResult "+nextResult.toString())
                         // This will be called once for every `SearchResult` object.
                         // Put your search result handling here.
                     }*/

                pdfUiFragment?.pspdfKitViews?.addOnVisibilityChangedListener(object : OnVisibilityChangedListener {
                    override fun onShow(view: View) {
                        if (view is PdfSearchViewInline) {
                            view.setInputFieldText(term, true)
                        } else if (view is PdfSearchViewModular) {
                            view.setInputFieldText(term, true)
                        }
                        pdfUiFragment?.pspdfKitViews?.removeOnVisibilityChangedListener(this)
                    }

                    override fun onHide(view: View) {
                    }
                })




                pdfUiFragment?.pspdfKitViews?.showView(PSPDFKitViews.Type.VIEW_SEARCH)


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
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?

        return PSPDFKitView(
            context!!,
            viewId,
            messenger,
            creationParams?.get("document") as String?,
            creationParams?.get("configuration") as HashMap<String, Any>?
        )
    }
}
