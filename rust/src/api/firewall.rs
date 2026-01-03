#[cfg(target_os = "windows")]
use windows::{
    core::{Result, HRESULT, Error},
    Win32::Foundation::VARIANT_BOOL,
    Win32::{
        NetworkManagement::WindowsFirewall::{
            INetFwPolicy2, NetFwPolicy2, NET_FW_PROFILE2_DOMAIN, NET_FW_PROFILE2_PRIVATE,
            NET_FW_PROFILE2_PUBLIC,
        },
        System::Com::{CoCreateInstance, CoInitializeEx, CLSCTX_INPROC_SERVER, COINIT_APARTMENTTHREADED},
    },
};

#[cfg(target_os = "windows")]
pub fn get_firewall_status(profile_index: u32) -> Result<bool> {
    unsafe {
        CoInitializeEx(None, COINIT_APARTMENTTHREADED)?;

        let policy: INetFwPolicy2 = CoCreateInstance(&NetFwPolicy2, None, CLSCTX_INPROC_SERVER)?;

        let profile_type = match profile_index {
            1 => NET_FW_PROFILE2_DOMAIN,
            2 => NET_FW_PROFILE2_PRIVATE,
            3 => NET_FW_PROFILE2_PUBLIC,
            _ => return Err(Error::new(HRESULT(-1), "Invalid profile index".into())),
        };

        // 正确调用 COM 接口方法
        let enabled = policy.get_FirewallEnabled(profile_type)?;
        Ok(enabled.as_bool())
    }
}
/// 不是window就返回false
#[cfg(not(target_os = "windows"))]
pub fn get_firewall_status(_profile_index: u32) -> Result<bool, std::io::Error> {
    Ok(false)
}
#[cfg(target_os = "windows")]
pub fn set_firewall_status(profile_index: u32, enable: bool) -> Result<()> {
    unsafe {
        CoInitializeEx(None, COINIT_APARTMENTTHREADED)?;

        let policy: INetFwPolicy2 = CoCreateInstance(&NetFwPolicy2, None, CLSCTX_INPROC_SERVER)?;

        let profile_type = match profile_index {
            1 => NET_FW_PROFILE2_DOMAIN,
            2 => NET_FW_PROFILE2_PRIVATE,
            3 => NET_FW_PROFILE2_PUBLIC,
            _ => return Err(Error::new(HRESULT(-1), "Invalid profile index".into())),
        };

        policy.put_FirewallEnabled(profile_type, VARIANT_BOOL::from(enable))?;
        Ok(())
    }
}

/// 不是window就返回false
#[cfg(not(target_os = "windows"))]
pub fn set_firewall_status(_profile_index: u32, _enable: bool) -> Result<(), std::io::Error> {
    Ok(())
}
