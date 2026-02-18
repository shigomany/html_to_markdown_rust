use html_to_markdown_rs::convert;
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
            // len is the character count from Dart, but we need to handle UTF-8 correctly
            // Use char_indices to find the correct byte position
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
}
