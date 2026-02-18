use base64::{engine::general_purpose::STANDARD, Engine as _};
use html_to_markdown_rs::{
    conversion_options_from_json, convert, convert_with_inline_images, convert_with_metadata,
    inline_image_config_from_json, metadata_config_from_json, InlineImageConfig, MetadataConfig,
};
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[unsafe(no_mangle)]
pub extern "C" fn htm_convert(input: *const c_char, len: usize) -> *mut c_char {
    if input.is_null() {
        return std::ptr::null_mut();
    }

    unsafe {
        let c_str = match CStr::from_ptr(input).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        };

        let html_input = if len > 0 {
            if len <= c_str.chars().count() {
                let byte_len = c_str
                    .char_indices()
                    .nth(len)
                    .map(|(pos, _)| pos)
                    .unwrap_or(c_str.len());
                &c_str[..byte_len]
            } else {
                c_str
            }
        } else {
            c_str
        };

        let markdown = convert(html_input, None);

        match markdown {
            Ok(value) => match CString::new(value) {
                Ok(c_string) => c_string.into_raw(),
                Err(_) => std::ptr::null_mut(),
            },
            Err(_) => std::ptr::null_mut(),
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn htm_convert_with_options(
    input: *const c_char,
    len: usize,
    options_json: *const c_char,
) -> *mut c_char {
    if input.is_null() {
        return std::ptr::null_mut();
    }

    unsafe {
        let c_str = match CStr::from_ptr(input).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        };

        let html_input = if len > 0 {
            if len <= c_str.chars().count() {
                let byte_len = c_str
                    .char_indices()
                    .nth(len)
                    .map(|(pos, _)| pos)
                    .unwrap_or(c_str.len());
                &c_str[..byte_len]
            } else {
                c_str
            }
        } else {
            c_str
        };

        let options = if options_json.is_null() {
            None
        } else {
            match CStr::from_ptr(options_json).to_str() {
                Ok(json_str) => match conversion_options_from_json(json_str) {
                    Ok(opts) => Some(opts),
                    Err(_) => return std::ptr::null_mut(),
                },
                Err(_) => return std::ptr::null_mut(),
            }
        };

        let markdown = convert(html_input, options);

        match markdown {
            Ok(value) => match CString::new(value) {
                Ok(c_string) => c_string.into_raw(),
                Err(_) => std::ptr::null_mut(),
            },
            Err(_) => std::ptr::null_mut(),
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn htm_convert_with_metadata(
    input: *const c_char,
    len: usize,
    options_json: *const c_char,
    metadata_config_json: *const c_char,
) -> *mut c_char {
    if input.is_null() {
        return std::ptr::null_mut();
    }

    unsafe {
        let c_str = match CStr::from_ptr(input).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        };

        let html_input = if len > 0 {
            if len <= c_str.chars().count() {
                let byte_len = c_str
                    .char_indices()
                    .nth(len)
                    .map(|(pos, _)| pos)
                    .unwrap_or(c_str.len());
                &c_str[..byte_len]
            } else {
                c_str
            }
        } else {
            c_str
        };

        let options = if options_json.is_null() {
            None
        } else {
            match CStr::from_ptr(options_json).to_str() {
                Ok(json_str) => match conversion_options_from_json(json_str) {
                    Ok(opts) => Some(opts),
                    Err(_) => return std::ptr::null_mut(),
                },
                Err(_) => return std::ptr::null_mut(),
            }
        };

        let metadata_config = if metadata_config_json.is_null() {
            MetadataConfig::default()
        } else {
            match CStr::from_ptr(metadata_config_json).to_str() {
                Ok(json_str) => match metadata_config_from_json(json_str) {
                    Ok(config) => config,
                    Err(_) => return std::ptr::null_mut(),
                },
                Err(_) => return std::ptr::null_mut(),
            }
        };

        let result = convert_with_metadata(html_input, options, metadata_config, None);

        match result {
            Ok((markdown, metadata)) => {
                let output = serde_json::json!({
                    "markdown": markdown,
                    "metadata": metadata,
                });
                match CString::new(output.to_string()) {
                    Ok(c_string) => c_string.into_raw(),
                    Err(_) => std::ptr::null_mut(),
                }
            }
            Err(_) => std::ptr::null_mut(),
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn htm_convert_with_inline_images(
    input: *const c_char,
    len: usize,
    options_json: *const c_char,
    image_config_json: *const c_char,
) -> *mut c_char {
    if input.is_null() {
        return std::ptr::null_mut();
    }

    unsafe {
        let c_str = match CStr::from_ptr(input).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        };

        let html_input = if len > 0 {
            if len <= c_str.chars().count() {
                let byte_len = c_str
                    .char_indices()
                    .nth(len)
                    .map(|(pos, _)| pos)
                    .unwrap_or(c_str.len());
                &c_str[..byte_len]
            } else {
                c_str
            }
        } else {
            c_str
        };

        let options = if options_json.is_null() {
            None
        } else {
            match CStr::from_ptr(options_json).to_str() {
                Ok(json_str) => match conversion_options_from_json(json_str) {
                    Ok(opts) => Some(opts),
                    Err(_) => return std::ptr::null_mut(),
                },
                Err(_) => return std::ptr::null_mut(),
            }
        };

        let image_config = if image_config_json.is_null() {
            InlineImageConfig::new(5 * 1024 * 1024)
        } else {
            match CStr::from_ptr(image_config_json).to_str() {
                Ok(json_str) => match inline_image_config_from_json(json_str) {
                    Ok(config) => config,
                    Err(_) => return std::ptr::null_mut(),
                },
                Err(_) => return std::ptr::null_mut(),
            }
        };

        let result = convert_with_inline_images(html_input, options, image_config, None);

        match result {
            Ok(extraction) => {
                let inline_images: Vec<serde_json::Value> = extraction
                    .inline_images
                    .iter()
                    .map(|img| {
                        serde_json::json!({
                            "data": STANDARD.encode(&img.data),
                            "format": format!("{:?}", img.format),
                            "filename": img.filename,
                            "description": img.description,
                            "dimensions": img.dimensions.map(|(w, h)| serde_json::json!({"width": w, "height": h})),
                            "source": format!("{:?}", img.source),
                            "attributes": img.attributes,
                        })
                    })
                    .collect();

                let warnings: Vec<serde_json::Value> = extraction
                    .warnings
                    .iter()
                    .map(|w| {
                        serde_json::json!({
                            "index": w.index,
                            "message": w.message,
                        })
                    })
                    .collect();

                let output = serde_json::json!({
                    "markdown": extraction.markdown,
                    "inline_images": inline_images,
                    "warnings": warnings,
                });
                match CString::new(output.to_string()) {
                    Ok(c_string) => c_string.into_raw(),
                    Err(_) => std::ptr::null_mut(),
                }
            }
            Err(_) => std::ptr::null_mut(),
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn htm_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_html_to_markdown() {
        let html = "<h1>Hello World</h1><p>This is a test.</p>";
        let c_html = CString::new(html).unwrap();
        let result = htm_convert(c_html.as_ptr(), html.len());

        assert!(!result.is_null());

        unsafe {
            let c_result = CStr::from_ptr(result).to_str().unwrap();
            assert!(c_result.contains("# Hello World"));
            assert!(c_result.contains("This is a test."));
            htm_free_string(result);
        }
    }

    #[test]
    fn test_null_input() {
        let result = htm_convert(std::ptr::null(), 0);
        assert!(result.is_null());
    }

    #[test]
    fn test_empty_string() {
        let html = "";
        let c_html = CString::new(html).unwrap();
        let result = htm_convert(c_html.as_ptr(), html.len());

        assert!(!result.is_null());

        unsafe {
            let c_result = CStr::from_ptr(result).to_str().unwrap();
            assert_eq!(c_result, "");
            htm_free_string(result);
        }
    }

    #[test]
    fn test_complex_html() {
        let html = r#"<div class="container">
            <h2>Features</h2>
            <ul>
                <li>Feature 1</li>
                <li>Feature 2</li>
            </ul>
        </div>"#;
        let c_html = CString::new(html).unwrap();
        let result = htm_convert(c_html.as_ptr(), html.len());

        assert!(!result.is_null());

        unsafe {
            let c_result = CStr::from_ptr(result).to_str().unwrap();
            assert!(c_result.contains("## Features"));
            assert!(c_result.contains("- Feature 1"));
            assert!(c_result.contains("- Feature 2"));
            htm_free_string(result);
        }
    }

    #[test]
    fn test_convert_with_options() {
        let html = "<h1>Hello</h1><p>Test</p>";
        let c_html = CString::new(html).unwrap();
        let options = r#"{"heading_style": "atx", "bullets": "*"}"#;
        let c_options = CString::new(options).unwrap();
        let result = htm_convert_with_options(c_html.as_ptr(), html.len(), c_options.as_ptr());

        assert!(!result.is_null());

        unsafe {
            let c_result = CStr::from_ptr(result).to_str().unwrap();
            assert!(c_result.contains("# Hello"));
            htm_free_string(result);
        }
    }

    #[test]
    fn test_convert_with_metadata() {
        let html = r#"<html><head><title>Test Page</title></head><body><h1>Hello</h1><p>Test</p></body></html>"#;
        let c_html = CString::new(html).unwrap();
        let options = r#"{}"#;
        let metadata_config = r#"{"extract_title": true}"#;
        let c_options = CString::new(options).unwrap();
        let c_metadata = CString::new(metadata_config).unwrap();
        let result = htm_convert_with_metadata(
            c_html.as_ptr(),
            html.len(),
            c_options.as_ptr(),
            c_metadata.as_ptr(),
        );

        assert!(!result.is_null());

        unsafe {
            let c_result = CStr::from_ptr(result).to_str().unwrap();
            let parsed: serde_json::Value = serde_json::from_str(c_result).unwrap();
            assert!(parsed["markdown"].as_str().unwrap().contains("# Hello"));
            htm_free_string(result);
        }
    }
}
