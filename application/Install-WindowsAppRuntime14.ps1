$ApplicationName = "WindowsAppRuntime1.4"
$DownloadUri = "https://aka.ms/windowsappsdk/1.4/latest/windowsappruntimeinstall-x64.exe"
$installDescription = "Installing the latest version of $($ApplicationName) from $($DownloadUri)"

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

$logfile = "C:\buildImage\Log\Install-$($ApplicationName)-$(Get-Date -Format "ddMMyyyy").txt"

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "$($installDescription)"
Log-Message -file $logfile -Message "Start Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"


#region Installation
Try {
    Invoke-Webrequest -Uri $DownloadUri -OutFile "$env:temp\windowsappruntimeinstall-x64.exe"
    Log-Message -file $Logfile -Message "Windows App Runtime 1.4 installation file is downloaded"
    Log-Message -file $Logfile -Message "File can be found in: $($env:temp)\windowsappruntimeinstall-x64.exe"
    $WindowsAppRuntime = $true
}
catch {
    $ErrorToDisplay = $_
    Log-Message -file $Logfile -Message "$($ErrorToDisplay.Exception.Message)"
    $WindowsAppRuntime = $false
}
if ($WindowsAppRuntime) {
    try {
        $installfile = ((get-ChildItem $env:temp) | Where-Object { $_.Name -eq "windowsappruntimeinstall-x64.exe" }).fullname
        Start-Process $installfile "-q" -Wait
        Log-Message -file $Logfile -Message "Windows App Runtime 1.4 is installed"

    }
    catch {
        $installError = $_
        Log-Message -file $Logfile -Message "Windows App Runtime 1.4 cannot be installed with error: $($Installerror.Exception.Message)"
    }
}

#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"
