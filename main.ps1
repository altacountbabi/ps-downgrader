# checks if an app is open
function ProcessOpen {
    param (
        [string]$appName
    )        
    
    $processes = Get-Process | Where-Object { $_.ProcessName -eq $appName }
    
    return $processes.Count -gt 0
}

'Getting latest data...'
# Gets data for downgrading
$latestData = (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/altacountbabi/ps-downgrader/main/data.json').Content | ConvertFrom-Json
$rbxAppxPackage = Get-AppxPackage | Where-Object  { $_.Name -like '*ROBLOXCORPORATION.ROBLOX*' }
$rbxVersion = [System.Version]::Parse($rbxAppxPackage.Version).Minor -or 0
$bundleVersion = $latestData.bundleVersion
$bundleDownload = $latestData.bundleDownload

# Check if you are already on the right version
if ($rbxVersion -eq $bundleVersion) {
    Clear-Host
    'Roblox is already on the correct version'    
    Pause

    return
}

# Downloads an older version of roblox to your temporary directory
$bundlePath = "$($env:TEMP)\ROBLOX_OLD_$bundleVersion.Msixbundle"

Clear-Host
'Downloading roblox...'

Start-BitsTransfer -Source $bundleDownload -Destination $bundlePath

Clear-Host
'Installing roblox...'

Add-AppxPackage -Path $bundlePath -ForceUpdateFromAnyVersion

Clear-Host

Remove-Item -Path $bundlePath -Force

Clear-Host

if ([System.Version]::Parse(((Get-AppxPackage | Where-Object { $_.Name -like '*ROBLOXCORPORATION.ROBLOX*' }).Version)).Minor -eq $bundleVersion) {
    "Successfully downgraded to version $bundleVersion"
    Pause
} else {
    "Something went wrong, please try again"
    Pause
}
