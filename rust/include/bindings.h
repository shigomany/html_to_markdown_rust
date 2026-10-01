#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Convert an HTML buffer containing `len` UTF-8 bytes.
 *
 * # Safety
 * `input` must reference `len` readable bytes. Free the result with `htm_free_string`.
 */
char *htm_convert(const char *input, uintptr_t len);

/**
 * Convert HTML with optional JSON options.
 *
 * # Safety
 * `input` must reference `len` readable bytes; non-null JSON must be NUL-terminated.
 * Free the result with `htm_free_string`.
 */
char *htm_convert_with_options(const char *input, uintptr_t len, const char *options_json);

/**
 * Convert HTML and return JSON with Markdown and selected metadata.
 *
 * # Safety
 * `input` must reference `len` readable bytes; non-null JSON must be NUL-terminated.
 * Free the result with `htm_free_string`.
 */
char *htm_convert_with_metadata(const char *input,
                                uintptr_t len,
                                const char *options_json,
                                const char *metadata_config_json);

/**
 * Convert HTML and extract embedded images into a JSON result.
 *
 * # Safety
 * `input` must reference `len` readable bytes; non-null JSON must be NUL-terminated.
 * Free the result with `htm_free_string`.
 */
char *htm_convert_with_inline_images(const char *input,
                                     uintptr_t len,
                                     const char *options_json,
                                     const char *image_config_json);

/**
 * Release a string allocated by this library; a null pointer is accepted.
 *
 * # Safety
 * `s` must be null or a live pointer returned by this library, freed exactly once.
 */
void htm_free_string(char *s);
