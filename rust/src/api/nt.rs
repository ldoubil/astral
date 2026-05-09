#[cfg(target_os = "windows")]
use std::ffi::OsStr;
#[cfg(target_os = "windows")]
use std::os::windows::ffi::OsStrExt;
#[cfg(target_os = "windows")]
use windows::Win32::Storage::FileSystem::QueryDosDeviceW;
#[cfg(target_os = "windows")]
use windows::core::PCWSTR;

#[cfg(not(target_os = "windows"))]
pub fn get_nt_path(_dos_path: &str) -> Option<String> {
    None
}

#[cfg(target_os = "windows")]
pub fn get_nt_path(dos_path: &str) -> Option<String> {
    // 提取盘符（如 C:）
    let prefix = &dos_path[..2]; // e.g., "C:"
    let prefix_w: Vec<u16> = OsStr::new(prefix)
        .encode_wide()
        .chain(std::iter::once(0))
        .collect();

    let mut buffer = vec![0u16; 1024];
    let len = unsafe {
        QueryDosDeviceW(
            PCWSTR(prefix_w.as_ptr()),
            Some(&mut buffer[..]),
        )
    };

    if len == 0 {
        return None;
    }

    // 移除缓冲区中的 null 终止符
    let actual_len = buffer[..len as usize]
        .iter()
        .position(|&x| x == 0)
        .unwrap_or(len as usize);
    
    let device_path = String::from_utf16_lossy(&buffer[..actual_len]);

    // 拼接完整的 NT 路径
    let remaining_path = &dos_path[2..]; // 跳过 "C:"

    // 清理 device_path，移除可能存在的 \0\0\，并确保路径分隔符正确
    let cleaned_device_path = device_path.trim_end_matches('\\').replace("\\??\\", "");

    // 确保 remaining_path 不以 \ 开头，如果 device_path 已经以 \ 结尾
    let final_path = if cleaned_device_path.ends_with('\\') && remaining_path.starts_with('\\') {
        format!("{}{}", cleaned_device_path, &remaining_path[1..])
    } else {
        format!("{}{}", cleaned_device_path, remaining_path)
    };

    Some(final_path.to_lowercase())
}
