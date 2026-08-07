package com.nutrient.nutrient_flutter_android

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.reactivex.rxjava3.exceptions.UndeliverableException
import io.reactivex.rxjava3.functions.Consumer
import io.reactivex.rxjava3.plugins.RxJavaPlugins
import java.io.InterruptedIOException
import java.util.concurrent.atomic.AtomicBoolean

/** NutrientFlutterPlugin */
class NutrientFlutterPlugin : FlutterPlugin {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        installRxUndeliverableHandler()

        // Register empty fragment container view (for JNI-based fragment management)
        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory(
                "nutrient_fragment_container",
                FragmentContainerViewFactory(flutterPluginBinding.binaryMessenger)
            )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        uninstallRxUndeliverableHandler()
    }

    companion object {
        private val rxHandlerInstalled = AtomicBoolean(false)

        // The handler we installed, kept so onDetachedFromEngine can detect
        // whether someone else has since replaced it.
        @Volatile
        private var installedHandler: Consumer<in Throwable>? = null

        // The handler that was set when we installed ours, so we can restore it
        // (or forward to it from inside our handler).
        @Volatile
        private var previousHandler: Consumer<in Throwable>? = null

        /**
         * Installs a global `RxJavaPlugins` error handler that swallows the
         * `UndeliverableException` → … → `InterruptedException` chain that the
         * Nutrient Android SDK throws when its internal blocking RxJava calls
         * (e.g. `Completable.blockingAwait`) are disposed mid-await — for example
         * when a Flutter platform view is replaced during a `NutrientInstantView`
         * document switch. The default Rx handler routes those to
         * `Thread.uncaughtExceptionHandler`, crashing the process.
         *
         * The check is intentionally narrow: only swallows when the top-level
         * throwable is an `UndeliverableException` AND the cause chain contains
         * an interrupt. Any other error — including a legitimate Rx error from
         * the host application whose cause chain happens to include an
         * interrupt — is forwarded unchanged.
         *
         * See: https://github.com/ReactiveX/RxJava/wiki/What's-different-in-2.0#error-handling
         */
        private fun installRxUndeliverableHandler() {
            if (!rxHandlerInstalled.compareAndSet(false, true)) return

            previousHandler = RxJavaPlugins.getErrorHandler()
            val handler = Consumer<Throwable> { throwable ->
                if (throwable is UndeliverableException && isInterruptedInChain(throwable)) {
                    // Subscription was cancelled mid-blocking-call. Safe to ignore — the consumer
                    // is gone and there's nothing to deliver the error to.
                    return@Consumer
                }
                forwardToPreviousHandler(throwable)
            }
            installedHandler = handler
            RxJavaPlugins.setErrorHandler(handler)
        }

        /**
         * Restores the previously installed `RxJavaPlugins` error handler, but
         * only if our handler is still active. If the host app installed its
         * own handler after ours, leave that intact.
         */
        private fun uninstallRxUndeliverableHandler() {
            if (!rxHandlerInstalled.compareAndSet(true, false)) return
            if (RxJavaPlugins.getErrorHandler() === installedHandler) {
                RxJavaPlugins.setErrorHandler(previousHandler)
            }
            installedHandler = null
            previousHandler = null
        }

        private fun forwardToPreviousHandler(throwable: Throwable) {
            val previous = previousHandler
            if (previous != null) {
                previous.accept(throwable)
            } else {
                // Fall back to default behaviour so app-level handlers / crash reporters still see it.
                Thread.currentThread().uncaughtExceptionHandler?.uncaughtException(
                    Thread.currentThread(), throwable
                )
            }
        }

        /**
         * Walks the causal chain looking for an interrupt. The SDK wraps
         * `InterruptedException` inside `RuntimeException`, which is then wrapped
         * by `UndeliverableException`, so a single `.cause` unwrap isn't enough.
         */
        private fun isInterruptedInChain(throwable: Throwable): Boolean {
            var current: Throwable? = throwable
            val seen = mutableSetOf<Throwable>()
            while (current != null && seen.add(current)) {
                if (current is InterruptedException || current is InterruptedIOException) {
                    return true
                }
                current = current.cause
            }
            return false
        }
    }
}


