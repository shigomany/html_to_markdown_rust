#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

char *htm_convert(const char *input, uintptr_t len);

char *htm_convert_with_options(const char *input, uintptr_t len, const char *options_json);

char *htm_convert_with_metadata(const char *input,
                                uintptr_t len,
                                const char *options_json,
                                const char *metadata_config_json);

char *htm_convert_with_inline_images(const char *input,
                                     uintptr_t len,
                                     const char *options_json,
                                     const char *image_config_json);

void htm_free_string(char *s);
