# 批量更新import路径的PowerShell脚本

$replacements = @(
    # Settings pages
    @{Pattern = "from 'package:astral/screens/settings/"; Replace = "from 'package:astral/features/settings/pages/"}
    @{Pattern = "from `"package:astral/screens/settings/"; Replace = "from `"package:astral/features/settings/pages/"}
    
    # Other screens  
    @{Pattern = "from 'package:astral/screens/home_page\.dart'"; Replace = "from 'package:astral/features/home/pages/home_page.dart'"}
    @{Pattern = "from `"package:astral/screens/home_page\.dart`""; Replace = "from `"package:astral/features/home/pages/home_page.dart`""}
    @{Pattern = "from 'package:astral/screens/room_page\.dart'"; Replace = "from 'package:astral/features/rooms/pages/room_page.dart'"}
    @{Pattern = "from `"package:astral/screens/room_page\.dart`""; Replace = "from `"package:astral/features/rooms/pages/room_page.dart`""}
    @{Pattern = "from 'package:astral/screens/explore_page\.dart'"; Replace = "from 'package:astral/features/explore/pages/explore_page.dart'"}
    @{Pattern = "from `"package:astral/screens/explore_page\.dart`""; Replace = "from `"package:astral/features/explore/pages/explore_page.dart`""}
    @{Pattern = "from 'package:astral/screens/magic_wall_page\.dart'"; Replace = "from 'package:astral/features/magic_wall/pages/magic_wall_page.dart'"}
    @{Pattern = "from `"package:astral/screens/magic_wall_page\.dart`""; Replace = "from `"package:astral/features/magic_wall/pages/magic_wall_page.dart`""}
    @{Pattern = "from 'package:astral/screens/nat_test_page\.dart'"; Replace = "from 'package:astral/features/nat_test/pages/nat_test_page.dart'"}
    @{Pattern = "from `"package:astral/screens/nat_test_page\.dart`""; Replace = "from `"package:astral/features/nat_test/pages/nat_test_page.dart`""}
    @{Pattern = "from 'package:astral/screens/user_page\.dart'"; Replace = "from 'package:astral/features/home/pages/user_page.dart'"}
    @{Pattern = "from `"package:astral/screens/user_page\.dart`""; Replace = "from `"package:astral/features/home/pages/user_page.dart`""}
    
    # Widgets - specific widgets that moved to subdirectories
    @{Pattern = "from 'package:astral/widgets/home/"; Replace = "from 'package:astral/shared/widgets/common/home/"}
    @{Pattern = "from `"package:astral/widgets/home/"; Replace = "from `"package:astral/shared/widgets/common/home/"}
    @{Pattern = "from 'package:astral/widgets/room_card\.dart'"; Replace = "from 'package:astral/shared/widgets/cards/room_card.dart'"}
    @{Pattern = "from `"package:astral/widgets/room_card\.dart`""; Replace = "from `"package:astral/shared/widgets/cards/room_card.dart`""}
    @{Pattern = "from 'package:astral/widgets/server_card\.dart'"; Replace = "from 'package:astral/shared/widgets/cards/server_card.dart'"}
    @{Pattern = "from `"package:astral/widgets/server_card\.dart`""; Replace = "from `"package:astral/shared/widgets/cards/server_card.dart`""}
    @{Pattern = "from 'package:astral/widgets/all_user_card\.dart'"; Replace = "from 'package:astral/shared/widgets/cards/all_user_card.dart'"}
    @{Pattern = "from `"package:astral/widgets/all_user_card\.dart`""; Replace = "from `"package:astral/shared/widgets/cards/all_user_card.dart`""}
    @{Pattern = "from 'package:astral/widgets/mini_user_card\.dart'"; Replace = "from 'package:astral/shared/widgets/cards/mini_user_card.dart'"}
    @{Pattern = "from `"package:astral/widgets/mini_user_card\.dart`""; Replace = "from `"package:astral/shared/widgets/cards/mini_user_card.dart`""}
    @{Pattern = "from 'package:astral/widgets/minecraft_server_card\.dart'"; Replace = "from 'package:astral/shared/widgets/cards/minecraft_server_card.dart'"}
    @{Pattern = "from `"package:astral/widgets/minecraft_server_card\.dart`""; Replace = "from `"package:astral/shared/widgets/cards/minecraft_server_card.dart`""}
    @{Pattern = "from 'package:astral/widgets/bottom_nav\.dart'"; Replace = "from 'package:astral/shared/widgets/navigation/bottom_nav.dart'"}
    @{Pattern = "from `"package:astral/widgets/bottom_nav\.dart`""; Replace = "from `"package:astral/shared/widgets/navigation/bottom_nav.dart`""}
    @{Pattern = "from 'package:astral/widgets/left_nav\.dart'"; Replace = "from 'package:astral/shared/widgets/navigation/left_nav.dart'"}
    @{Pattern = "from `"package:astral/widgets/left_nav\.dart`""; Replace = "from `"package:astral/shared/widgets/navigation/left_nav.dart`""}
    
    # Remaining widgets go to common/
    @{Pattern = "from 'package:astral/widgets/home_box\.dart'"; Replace = "from 'package:astral/shared/widgets/common/home_box.dart'"}
    @{Pattern = "from `"package:astral/widgets/home_box\.dart`""; Replace = "from `"package:astral/shared/widgets/common/home_box.dart`""}
    @{Pattern = "from 'package:astral/widgets/status_bar\.dart'"; Replace = "from 'package:astral/shared/widgets/common/status_bar.dart'"}
    @{Pattern = "from `"package:astral/widgets/status_bar\.dart`""; Replace = "from `"package:astral/shared/widgets/common/status_bar.dart`""}
    @{Pattern = "from 'package:astral/widgets/theme_selector\.dart'"; Replace = "from 'package:astral/shared/widgets/common/theme_selector.dart'"}
    @{Pattern = "from `"package:astral/widgets/theme_selector\.dart`""; Replace = "from `"package:astral/shared/widgets/common/theme_selector.dart`""}
    @{Pattern = "from 'package:astral/widgets/windows_controls\.dart'"; Replace = "from 'package:astral/shared/widgets/common/windows_controls.dart'"}
    @{Pattern = "from `"package:astral/widgets/windows_controls\.dart`""; Replace = "from `"package:astral/shared/widgets/common/windows_controls.dart`""}
    @{Pattern = "from 'package:astral/widgets/network_topology\.dart'"; Replace = "from 'package:astral/shared/widgets/common/network_topology.dart'"}
    @{Pattern = "from `"package:astral/widgets/network_topology\.dart`""; Replace = "from `"package:astral/shared/widgets/common/network_topology.dart`""}
    @{Pattern = "from 'package:astral/widgets/room_reorder_sheet\.dart'"; Replace = "from 'package:astral/shared/widgets/common/room_reorder_sheet.dart'"}
    @{Pattern = "from `"package:astral/widgets/room_reorder_sheet\.dart`""; Replace = "from `"package:astral/shared/widgets/common/room_reorder_sheet.dart`""}
    @{Pattern = "from 'package:astral/widgets/room_settings_sheet\.dart'"; Replace = "from 'package:astral/shared/widgets/common/room_settings_sheet.dart'"}
    @{Pattern = "from `"package:astral/widgets/room_settings_sheet\.dart`""; Replace = "from `"package:astral/shared/widgets/common/room_settings_sheet.dart`""}
    @{Pattern = "from 'package:astral/widgets/canvas_jump\.dart'"; Replace = "from 'package:astral/shared/widgets/common/canvas_jump.dart'"}
    @{Pattern = "from `"package:astral/widgets/canvas_jump\.dart`""; Replace = "from `"package:astral/shared/widgets/common/canvas_jump.dart`""}
    
    # Utils
    @{Pattern = "from 'package:astral/utils/"; Replace = "from 'package:astral/shared/utils/"}
    @{Pattern = "from `"package:astral/utils/"; Replace = "from `"package:astral/shared/utils/"}
    
    # Models
    @{Pattern = "from 'package:astral/models/"; Replace = "from 'package:astral/shared/models/"}
    @{Pattern = "from `"package:astral/models/"; Replace = "from `"package:astral/shared/models/"}
    
    # Core mod -> constants
    @{Pattern = "from 'package:astral/core/mod/"; Replace = "from 'package:astral/core/constants/"}
    @{Pattern = "from `"package:astral/core/mod/"; Replace = "from `"package:astral/core/constants/"}
)

$files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

$totalFiles = $files.Count
$current = 0
$updatedCount = 0

Write-Host "Found $totalFiles Dart files to process..."

foreach ($file in $files) {
    $current++
    Write-Progress -Activity "Updating imports" -Status "Processing $($file.Name)" -PercentComplete (($current / $totalFiles) * 100)
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    foreach ($replacement in $replacements) {
        $content = $content -replace $replacement.Pattern, $replacement.Replace
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $updatedCount++
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nImport update complete! Updated $updatedCount files."
