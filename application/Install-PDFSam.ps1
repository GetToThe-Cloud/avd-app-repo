$ApplicationName = "PDFSam"
$Archive = "$($env:temp)\PDFSam-Installer.msi"
$installDescription = "Installing the latest version of $($ApplicationName) : $($Archive)"

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

#region PDFSam
$repo = "torakiki/pdfsam"
$releases = "https://api.github.com/repos/$repo/releases"

try {
  $tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name
}
catch {
  $webError = $_
  Log-message -File $logFile -Message "Error getting the latest release from Github $repo"
  Log-message -File $logFile -Message "$($webError.Exception.Message)"
  break
}

$version = $Tag.Split("v")[1]
$filename = "pdfsam-$($version).msi"
$DownloadUrl = "https://github.com/$repo/releases/download/$tag/$filename"

  
try {
  Log-Message -file $logfile -Message "Downloading the installer: $($DownloadURL)"
  Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive -useBasicParsing -ErrorAction Stop
  Log-Message -file $logfile -Message "Installer is downloaded: $($DownloadURL)"
  # Install irfanview
  Log-Message -file $logfile -Message "Installing $($ApplicationName)"
  $arguments = @(
    "/i"
    ($archive)
    "/qb"
    "/norestart"
    "CHECK_FOR_UPDATES=false CHECK_FOR_NEWS=false DONATE_NOTIFICATION=false SKIPTHANKSPAGE=Yes"
    )
    Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
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




