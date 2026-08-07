#import <stdbool.h>
#import <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

bool nutrient_attach_view_controller(int64_t viewId, void *viewController);

/// Gets the PSPDFViewController registered for a given view ID.
/// This retrieves the view controller from PspdfPlatformView's static registry,
/// allowing Dart adapters to access the native PSPDFViewController via FFI.
///
/// @param viewId The platform view ID.
/// @return The PSPDFViewController pointer, or NULL if not registered.
void* nutrient_get_view_controller(int64_t viewId);

/// Creates a PSPDFInstantViewController for a given server URL and JWT using
/// the default Instant configuration.
///
/// @param serverUrl Null-terminated UTF-8 string of the Document Engine server URL.
/// @param jwt       Null-terminated UTF-8 string of the JWT for authentication.
/// @return A retained PSPDFInstantViewController pointer (as PSPDFViewController*),
///         or NULL if creation fails. Caller must release via ARC or CFRelease.
void* nutrient_create_instant_view_controller(const char* serverUrl, const char* jwt);

/// Creates a PSPDFInstantViewController with a custom PSPDFConfiguration derived
/// from [configJson].
///
/// @param serverUrl  Null-terminated UTF-8 string of the Document Engine server URL.
/// @param jwt        Null-terminated UTF-8 string of the JWT for authentication.
/// @param configJson Null-terminated UTF-8 JSON string produced by IOSConfigurationBuilder.
///                   Pass NULL to use the default Instant configuration.
/// @return A retained PSPDFInstantViewController pointer (as PSPDFViewController*),
///         or NULL if creation fails. Caller must release via ARC or CFRelease.
void* nutrient_create_instant_view_controller_with_config(
    const char* serverUrl,
    const char* jwt,
    const char* configJson
);

/// Triggers a manual annotation sync on the Instant document associated with the
/// given PSPDFInstantViewController.
///
/// @param viewController A PSPDFInstantViewController pointer obtained from
///                       nutrient_create_instant_view_controller.
void nutrient_instant_sync_annotations(void* viewController);

/// Controls whether the Instant view controller listens for server changes
/// when it is visible.
///
/// @param viewController A PSPDFInstantViewController pointer.
/// @param listen         true to enable server listening, false to disable.
void nutrient_instant_set_listen_for_server_changes(void* viewController, bool listen);

/// Sets the delay (in seconds) before local annotation changes are
/// automatically synced to the server, on the `PSPDFInstantDocumentDescriptor`
/// associated with the given Instant view controller.
///
/// The delay lives on the document descriptor (not the view controller
/// itself); this helper resolves it from the associated object retained
/// alongside the view controller in nutrient_create_instant_view_controller(_with_config).
/// No-op if the view controller has no associated descriptor.
///
/// @param viewController A PSPDFInstantViewController pointer obtained from
///                       nutrient_create_instant_view_controller.
/// @param delay          Delay in seconds. Pass a negative constant matching
///                       `PSPDFInstantSyncingLocalChangesDisabled` to disable
///                       automatic syncing of local changes.
void nutrient_instant_set_delay_for_syncing_local_changes(void* viewController, double delay);

/// Page-tap callback signature. Called on the main thread (UIKit gesture
/// dispatch) when a tap gesture installed by [nutrient_install_page_tap]
/// fires its `Ended` state and the tap was NOT consumed by an annotation.
///
/// @param pageView   The PSPDFPageView pointer the tap landed on.
/// @param x          x of the tap in PSPDFPageView coordinate space (UIKit
///                   logical points).
/// @param y          y of the tap in PSPDFPageView coordinate space.
/// @param pageIndex  The page index the tap occurred on.
typedef void (*nutrient_page_tap_callback)(void* pageView, double x, double y, int64_t pageIndex);

/// Installs a UITapGestureRecognizer on the given PSPDFPageView that calls
/// [callback] every time the user taps an empty area of the page (an area
/// not handled by an existing annotation). PSPDFKit's gesture recognizers
/// (annotation tap, text-selection long press) keep priority — our
/// recognizer is configured `cancelsTouchesInView = NO` and uses
/// `requireGestureRecognizerToFail:` against existing recognizers so that
/// if PSPDFKit handles the tap, we don't double-fire. Recognizer is
/// associated with the page view via objc_setAssociatedObject so it lives
/// as long as the page view does.
///
/// Calling this twice for the same pageView is a no-op (the helper checks
/// the associated object).
///
/// @param pageView   A PSPDFPageView pointer (from the
///                   pdfViewController:didConfigurePageView:forPageAtIndex:
///                   delegate).
/// @param pageIndex  The page index, surfaced back via the callback.
/// @param callback   A C function pointer to invoke on tap. To bridge to
///                   Dart safely (callback runs on the main thread, not
///                   the Dart isolate thread), use
///                   `NativeCallable.listener` on the Dart side.
void nutrient_install_page_tap(void* pageView, int64_t pageIndex, nutrient_page_tap_callback callback);

/// Parses a JSON UTF-8 string containing an AI-assistant config object
/// (keys: serverUrl, jwt, sessionId, userId) and applies it to the given
/// PSPDFConfigurationBuilder via KVC. Safe to call with a NULL pointer or
/// an empty/invalid JSON string — all failure paths are no-ops.
///
/// Intended for the standalone-document (plain PSPDFViewController) path.
/// The Instant path applies AI config through the full config dict inside
/// nutrient_create_instant_view_controller_with_config.
///
/// @param configurationBuilder  A PSPDFConfigurationBuilder* obtained from
///                              the block passed to configurationWithBuilder:.
/// @param jsonUtf8              Null-terminated UTF-8 JSON string of the AI
///                              assistant sub-dict (NOT the full config dict).
void nutrient_apply_ai_assistant_configuration(void* configurationBuilder,
                                               const char* jsonUtf8);

/// Appends `aiAssistantButtonItem` to the left bar button items of the given
/// PSPDFViewController's navigation item. Call this on the main thread after
/// the VC has been created and its AI assistant configuration has been applied.
/// No-op when no aiAssistantConfiguration was set on the VC's configuration.
///
/// @param viewController  A PSPDFViewController* for the standalone-document path.
void nutrient_add_ai_assistant_button(void* viewController);

/// Parses a JSON UTF-8 string containing a signature-creation config object
/// (keys: creationModes, colorOptions, iosSignatureAspectRatio, fonts — see
/// SignatureCreationConfiguration.toMap() in the platform-interface package)
/// and applies it to the given PSPDFConfigurationBuilder by constructing a
/// PSPDFSignatureCreationConfiguration and assigning it to
/// `signatureCreationConfiguration`. Safe to call with a NULL pointer or an
/// empty/invalid JSON string — all failure paths are no-ops and leave the
/// builder's existing (default) signatureCreationConfiguration untouched.
///
/// Building the configuration requires constructing UIColor/UIFont instances
/// from hex strings / font names, which isn't reachable from pure Dart FFI
/// (neither class has a designated-initializer wrapper in the generated
/// bindings), so this lives in native glue rather than
/// IOSConfigurationBuilder.applyToBuilder.
///
/// @param configurationBuilder  A __bridge PSPDFConfigurationBuilder* obtained
///                              from the ObjC block passed to
///                              PSPDFConfiguration.configurationWithBuilder:.
/// @param jsonUtf8              Null-terminated UTF-8 JSON string of the
///                              signature-creation sub-dict (NOT the full
///                              config dict).
void nutrient_apply_signature_creation_configuration(void *configurationBuilder,
                                                      const char *jsonUtf8);

/// Tap callback signature for a custom main-toolbar item. Called on the main
/// thread (UIKit target-action) with the tapped item's index — its position in
/// the array most recently passed to [nutrient_set_main_toolbar_items].
///
/// An index (rather than the id string) is used so the value stays valid when
/// the Dart side bridges the call asynchronously via `NativeCallable.listener`;
/// a C string would dangle by the time the listener runs.
///
/// @param itemIndex  Zero-based index of the tapped item.
typedef void (*nutrient_toolbar_tap_callback)(int64_t itemIndex);

/// Replaces the custom main-toolbar (navigation-bar) buttons on the given
/// PSPDFViewController with one button per entry in [itemsJson].
///
/// [itemsJson] is a UTF-8 JSON array of objects: `{"id": string, "title":
/// string?, "disabled": bool?}`. Buttons added by a previous call are removed
/// first, so passing an empty array (or NULL) clears them. Each button's tap
/// invokes [callback] with that entry's zero-based index.
///
/// Must be called on the main thread. Built-in items are not affected — this
/// only manages the custom buttons it adds.
///
/// @param viewController  A PSPDFViewController*.
/// @param itemsJson       Null-terminated UTF-8 JSON array, or NULL to clear.
/// @param callback        C function pointer invoked on tap. Bridge to Dart
///                        with `NativeCallable.listener`.
void nutrient_set_main_toolbar_items(void* viewController,
                                     const char* itemsJson,
                                     nutrient_toolbar_tap_callback callback);

/// Registers automatic file-conflict resolution on [viewController] for the
/// strategy identified by [resolutionRawValue].
///
/// [resolutionRawValue] is the raw `PSPDFFileConflictResolution` value —
/// Close=0, Save=1, Reload=2 (see `PSPDFFileConflictResolution.h`). There is no
/// value for "default behavior" (show the alert): callers should simply not
/// call this function (or should call [nutrient_unregister_file_conflict_resolution])
/// when `IOSFileConflictResolution.defaultBehavior` is configured, leaving the
/// SDK's built-in alert UI in place.
///
/// Safe to call multiple times for the same [viewController] — a previous
/// registration is replaced. Must be called on the main thread. No-op if
/// [viewController] is NULL or is not a `PDFViewController` instance.
///
/// @param viewController    A PSPDFViewController* (as `void*`).
/// @param resolutionRawValue Raw `PSPDFFileConflictResolution` value (0/1/2).
void nutrient_register_file_conflict_resolution(void* viewController,
                                                 int64_t resolutionRawValue);

/// Tears down the automatic file-conflict resolution observer registered by
/// [nutrient_register_file_conflict_resolution] for [viewController], if any.
///
/// Call this when the hosting view is disposed to avoid leaking the
/// notification observer. Safe to call even when nothing was registered, and
/// safe to call with a NULL [viewController] (no-op).
///
/// @param viewController  A PSPDFViewController* (as `void*`).
void nutrient_unregister_file_conflict_resolution(void* viewController);

#ifdef __cplusplus
}
#endif
