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

#ifdef __cplusplus
}
#endif
