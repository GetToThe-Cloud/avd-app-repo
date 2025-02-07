$ApplicationName = "Power BI Desktop"
$Archive = "$($env:temp)\PBIDesktopSetup_x64.exe"
$installDescription = "Installing the latest version of $($ApplicationName) $($Archive)"
$DownloadURL = "https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe" # nederlands

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


#region Install Power BI Desktop
try {
  Log-Message -file $logfile -Message "Downloading the installer: $($DownloadURL)"
  Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive -useBasicParsing -ErrorAction Stop
  Log-Message -file $logfile -Message "Installer is downloaded: $($DownloadURL)"
  # Install Power BI Desktop
  Log-Message -file $logfile -Message "Installing $($ApplicationName)"
  Start-Process -Wait -FilePath $Archive -ArgumentList '-quiet -norestart ACCEPT_EULA=1'
  Log-Message -file $logFile -Message "Installing of $($ApplicationName) is done"
}
catch { throw }
finally {
  # Remove Setup Files
  Remove-Item $Archive -Force -ErrorAction Ignore
  Log-message -file $logFile -message "Removing $($archive) is done"
}
#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"