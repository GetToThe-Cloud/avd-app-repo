## check if powershell elevated is started
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
    Break
}


## installing WINGET
$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle


$applicationlist = Import-PowerShellDataFile WingetApplications.psd1


### Functions ####
function Log-Message([String]$Message, [string]$file) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] " + $message
    $messageLog = "[$(Get-Date -format "HH:mm:ss")] " + $message
    Add-Content -Path $file $MessageLog
     
}
### Tests ####
If (!(Test-Path "C:\BuildImage\Log")) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] Folder does not exist"
    new-item -type Directory -path "C:\BuildImage" -name Log
    #    break
}


ForEach ($Application in $applicationlist.Applications){
    $logfile = "C:\buildImage\Log\Install-$($Application)-$(Get-Date -Format "ddMMyyyy").txt"
    $installDescription = "Installing the latest version of $($Application)"

    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    Log-Message -file $logfile -Message "$($installDescription)"
    Log-Message -file $logfile -Message "Start Time: $(Get-Date)"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    
    Try {
    winget install -e --disable-interactivity --accept-package-agreements --accept-source-agreements --id $($application)
    }
    catch {
        throw
    }

    # check if it is installed
    $List = winget search $application

    if ($list -like "*No package found matching input criteria."){
        Log-Message -file $logfile -Message "Package $($application) was not installed."
    }
    elseif ($list -like "*$($application)*") {
        Log-Message -file $logfile -Message "Package $($application) is installed."
    }

    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    Log-Message -file $logfile -Message "Installation script for $($application) is finished"
    Log-Message -file $logfile -Message "End Time: $(Get-Date)"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"

}