$ApplicationName = "Adobe Acrobat Pro"
## $Archive = "$($env:temp)\AcroRdrDC2300820533_nl_NL.exe"
$installDescription = "Installing the latest version of $($ApplicationName) $($Archive)"
$DownloadURL = "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_x64_WWMUI.zip"

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

#Set the download URL
$Archive = 'C:\buildImage\Apps\AdobeAcrobat.zip'
$ArchiveDestination = 'C:\buildImage\Apps\'
$Installer = "$ArchiveDestination\AdobeAcrobat\setup.exe"

if (!(Test-Path $ArchiveDestination)) {
    New-Item -ItemType Directory -Path $ArchiveDestination
}

try {
    Expand-Archive -Path $Archive -DestinationPath $ArchiveDestination -Force

    # Install Adobe Acrobat Pro (including DC)
    Start-Process -Wait -FilePath $Installer -ArgumentList '/sAll'
}
catch { throw }
 finally {
   # Remove Setup Files
   #Remove-Item $Archive -Force -ErrorAction Ignore
   #Remove-Item "$ArchiveDestination\Adobe Acrobat" -Recurse -Force -ErrorAction Ignore
 }
#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"