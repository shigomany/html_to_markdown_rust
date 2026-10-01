use base64::{Engine as _, engine::general_purpose::STANDARD};
use html_to_markdown_rs::{
    ConversionOptions, HtmlMetadata, InlineImageConfig, InlineImageConfigUpdate, NewlineStyle,
    NodeContext, PreprocessingOptions, PreprocessingPreset, VisitResult, WarningKind, convert,
    visitor::HtmlVisitor,
};
use serde::{Deserialize, de::DeserializeOwned};
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::sync::{Arc, Mutex};

// The C ABI stays stable while the 3.x engine uses a unified ConversionResult.
unsafe fn input_html<'a>(input: *const c_char, len: usize) -> Result<&'a str, ()> {
    if input.is_null() || len > isize::MAX as usize {
        return Err(());
    }
    // Dart supplies the UTF-8 byte count, including any embedded NUL bytes.
    let bytes = unsafe { std::slice::from_raw_parts(input.cast::<u8>(), len) };
    std::str::from_utf8(bytes).map_err(|_| ())
}

unsafe fn json_config<T: DeserializeOwned + Default>(input: *const c_char) -> Result<T, ()> {
    if input.is_null() {
        return Ok(T::default());
    }
    let json = unsafe { CStr::from_ptr(input) }.to_str().map_err(|_| ())?;
    serde_json::from_str(json).map_err(|_| ())
}

#[derive(Debug)]
struct UnwrapLinks;

impl HtmlVisitor for UnwrapLinks {
    fn visit_link(
        &mut self,
        _ctx: &NodeContext<'_>,
        _href: &str,
        text: &str,
        _title: Option<&str>,
    ) -> VisitResult {
        VisitResult::Custom(text.to_owned())
    }
}

unsafe fn conversion_options(input: *const c_char) -> Result<ConversionOptions, ()> {
    if input.is_null() {
        return Ok(ConversionOptions {
            list_indent_width: 4,
            bullets: "-".to_owned(),
            newline_style: NewlineStyle::Backslash,
            preprocessing: PreprocessingOptions {
                enabled: false,
                preset: PreprocessingPreset::Minimal,
                remove_navigation: false,
                remove_forms: false,
            },
            ..ConversionOptions::default()
        });
    }
    let mut value: serde_json::Value = unsafe { json_config(input)? };
    let object = value.as_object_mut().ok_or(())?;
    // skip_links belongs to the Dart facade; the Rust visitor preserves link text.
    let skip_links = match object.remove("skip_links") {
        Some(value) => value.as_bool().ok_or(())?,
        None => false,
    };
    let mut options: ConversionOptions = serde_json::from_value(value).map_err(|_| ())?;
    if skip_links {
        options.visitor = Some(Arc::new(Mutex::new(UnwrapLinks)));
    }
    Ok(options)
}

fn ffi_string(action: impl FnOnce() -> Result<String, ()>) -> *mut c_char {
    catch_unwind(AssertUnwindSafe(action))
        .ok()
        .and_then(Result::ok)
        .and_then(|value| CString::new(value).ok())
        .map_or(std::ptr::null_mut(), CString::into_raw)
}

/// Convert an HTML buffer containing `len` UTF-8 bytes.
///
/// # Safety
/// `input` must reference `len` readable bytes. Free the result with `htm_free_string`.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn htm_convert(input: *const c_char, len: usize) -> *mut c_char {
    unsafe { htm_convert_with_options(input, len, std::ptr::null()) }
}

/// Convert HTML with optional JSON options.
///
/// # Safety
/// `input` must reference `len` readable bytes; non-null JSON must be NUL-terminated.
/// Free the result with `htm_free_string`.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn htm_convert_with_options(
    input: *const c_char,
    len: usize,
    options_json: *const c_char,
) -> *mut c_char {
    ffi_string(|| {
        let html = unsafe { input_html(input, len)? };
        let mut options = unsafe { conversion_options(options_json)? };
        options.extract_metadata = false;
        convert(html, options)
            .map(|result| result.content.unwrap_or_default())
            .map_err(|_| ())
    })
}

#[derive(Deserialize)]
#[serde(default, deny_unknown_fields)]
struct MetadataSelection {
    extract_title: bool,
    extract_description: bool,
    extract_keywords: bool,
    extract_headers: bool,
    extract_links: bool,
    extract_images: bool,
    extract_structured_data: bool,
    max_structured_data_size: usize,
}

impl Default for MetadataSelection {
    fn default() -> Self {
        Self {
            extract_title: true,
            extract_description: true,
            extract_keywords: true,
            extract_headers: true,
            extract_links: true,
            extract_images: true,
            extract_structured_data: true,
            max_structured_data_size: 1_000_000,
        }
    }
}

impl MetadataSelection {
    fn filter(&self, metadata: &mut HtmlMetadata) {
        if !self.extract_title {
            metadata.document.title = None;
        }
        if !self.extract_description {
            metadata.document.description = None;
        }
        if !self.extract_keywords {
            metadata.document.keywords.clear();
        }
        if !self.extract_headers {
            metadata.headers.clear();
        }
        if !self.extract_links {
            metadata.links.clear();
        }
        if !self.extract_images {
            metadata.images.clear();
        }
        let mut remaining = self.max_structured_data_size;
        metadata.structured_data.retain(|entry| {
            if !self.extract_structured_data || entry.raw_json.len() > remaining {
                return false;
            }
            remaining -= entry.raw_json.len();
            true
        });
    }
}

/// Convert HTML and return JSON with Markdown and selected metadata.
///
/// # Safety
/// `input` must reference `len` readable bytes; non-null JSON must be NUL-terminated.
/// Free the result with `htm_free_string`.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn htm_convert_with_metadata(
    input: *const c_char,
    len: usize,
    options_json: *const c_char,
    metadata_config_json: *const c_char,
) -> *mut c_char {
    ffi_string(|| {
        let html = unsafe { input_html(input, len)? };
        let mut options = unsafe { conversion_options(options_json)? };
        options.extract_metadata = true;
        let selection: MetadataSelection = unsafe { json_config(metadata_config_json)? };
        if selection.max_structured_data_size > 1_000_000 {
            return Err(());
        }
        let mut result = convert(html, options).map_err(|_| ())?;
        selection.filter(&mut result.metadata);
        Ok(serde_json::json!({
            "markdown": result.content.unwrap_or_default(),
            "metadata": result.metadata,
        })
        .to_string())
    })
}

/// Convert HTML and extract embedded images into a JSON result.
///
/// # Safety
/// `input` must reference `len` readable bytes; non-null JSON must be NUL-terminated.
/// Free the result with `htm_free_string`.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn htm_convert_with_inline_images(
    input: *const c_char,
    len: usize,
    options_json: *const c_char,
    image_config_json: *const c_char,
) -> *mut c_char {
    ffi_string(|| {
        let html = unsafe { input_html(input, len)? };
        let mut options = unsafe { conversion_options(options_json)? };
        let update: InlineImageConfigUpdate = unsafe { json_config(image_config_json)? };
        let config = InlineImageConfig::from_update(update);
        options.extract_metadata = false;
        options.extract_images = true;
        options.max_image_size = config.max_decoded_size_bytes;
        options.capture_svg = config.capture_svg;
        options.infer_dimensions = config.infer_dimensions;
        let result = convert(html, options).map_err(|_| ())?;
        let prefix = config
            .filename_prefix
            .as_deref()
            .filter(|value| !value.trim().is_empty());
        let images: Vec<_> = result
            .images
            .iter()
            .map(|img| {
                let filename = img.filename.as_ref().map(|name| {
                    match (prefix, name.strip_prefix("embedded_image")) {
                        (Some(prefix), Some(suffix)) => format!("{prefix}{suffix}"),
                        _ => name.clone(),
                    }
                });
                serde_json::json!({
                    "data": STANDARD.encode(&img.data),
                    "format": img.format.to_string(),
                    "filename": filename,
                    "description": img.description,
                    "dimensions": img.dimensions,
                    "source": img.source.to_string(),
                    "attributes": img.attributes,
                })
            })
            .collect();
        let warnings: Vec<_> = result
            .warnings
            .iter()
            .filter(|warning| matches!(warning.kind, WarningKind::ImageExtractionFailed))
            .map(|warning| {
                // 3.x retains the source image index in the warning message.
                let index = warning
                    .message
                    .strip_prefix("Inline image ")
                    .or_else(|| warning.message.strip_prefix("Skipped inline image "))
                    .and_then(|message| message.split_once(':'))
                    .and_then(|(index, _)| index.parse::<usize>().ok());
                serde_json::json!({"index": index, "message": warning.message})
            })
            .collect();
        Ok(serde_json::json!({
            "markdown": result.content.unwrap_or_default(),
            "inline_images": images,
            "warnings": warnings,
        })
        .to_string())
    })
}

/// Release a string allocated by this library; a null pointer is accepted.
///
/// # Safety
/// `s` must be null or a live pointer returned by this library, freed exactly once.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn htm_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            drop(CString::from_raw(s));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_invalid_utf8_is_rejected() {
        let input = [0xffu8, 0];
        let result = unsafe { htm_convert(input.as_ptr().cast(), 1) };
        assert!(result.is_null());
    }

    #[test]
    fn test_invalid_options_are_rejected() {
        let input = CString::new("<p>Content</p>").unwrap();
        let options = CString::new(r#"{"unknown_option":true}"#).unwrap();
        let result = unsafe {
            htm_convert_with_options(input.as_ptr(), input.as_bytes().len(), options.as_ptr())
        };
        assert!(result.is_null());
    }

    #[test]
    fn test_html_to_markdown() {
        let html = "<h1>Hello World</h1><p>This is a test.</p>";
        let c_html = CString::new(html).unwrap();
        let result = unsafe { htm_convert(c_html.as_ptr(), html.len()) };

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
        let result = unsafe { htm_convert(std::ptr::null(), 0) };
        assert!(result.is_null());
    }

    #[test]
    fn test_empty_string() {
        let html = "";
        let c_html = CString::new(html).unwrap();
        let result = unsafe { htm_convert(c_html.as_ptr(), html.len()) };

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
        let result = unsafe { htm_convert(c_html.as_ptr(), html.len()) };

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
        let result =
            unsafe { htm_convert_with_options(c_html.as_ptr(), html.len(), c_options.as_ptr()) };

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
        let result = unsafe {
            htm_convert_with_metadata(
                c_html.as_ptr(),
                html.len(),
                c_options.as_ptr(),
                c_metadata.as_ptr(),
            )
        };

        assert!(!result.is_null());

        unsafe {
            let c_result = CStr::from_ptr(result).to_str().unwrap();
            let parsed: serde_json::Value = serde_json::from_str(c_result).unwrap();
            assert!(parsed["markdown"].as_str().unwrap().contains("# Hello"));
            htm_free_string(result);
        }
    }
}
