package com.pspdfkit.flutter.pspdfkit.util

import kotlin.coroutines.cancellation.CancellationException

/**
 * Like [runCatching], but lets a coroutine's cancellation through instead of capturing it as a
 * failure: a cancelled call reports nothing, as a disposed RxJava subscription didn't.
 *
 * Wrap only the SDK call in it, and handle the result outside: an exception thrown while handling
 * a success shouldn't be reported as the call's failure.
 */
internal inline fun <T> runCatchingUnlessCancelled(block: () -> T): Result<T> =
    try {
        Result.success(block())
    } catch (cancellation: CancellationException) {
        throw cancellation
    } catch (error: Exception) {
        Result.failure(error)
    }
