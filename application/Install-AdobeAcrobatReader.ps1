$ApplicationName = "Adobe Acrobat Reader"
$Archive = "$($env:temp)\AcroRdrDC2300820533_nl_NL.exe"
$installDescription = "Installing the latest version of $($ApplicationName) $($Archive)"
$DownloadURL = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300820533/AcroRdrDC2300820533_nl_NL.exe"

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


#region Download
try {
  Log-Message -file $logfile -Message "Downloading the installer: $($DownloadURL)"
  Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive -useBasicParsing -ErrorAction Stop
  Log-Message -file $logfile -Message "Installer is downloaded: $($DownloadURL)"
  # Install 
  Log-Message -file $logfile -Message "Installing $($ApplicationName)"
  Start-Process -Wait -FilePath $Archive -ArgumentList '/sAll /rs /l /msi /qb-'
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