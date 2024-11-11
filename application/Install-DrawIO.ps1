$ApplicationName = "DrawIO"
$Archive = "$($env:temp)\DrawIO-Installer.exe"
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

#region DrawIO
$repo = "jgraph/drawio-desktop"
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
$filename = "draw.io-$($version)-windows-installer.exe"
$DownloadUrl = "https://github.com/$repo/releases/download/$tag/$filename"

  
try {
  Log-Message -file $logfile -Message "Downloading the installer: $($DownloadURL)"
  Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive -useBasicParsing -ErrorAction Stop
  Log-Message -file $logfile -Message "Installer is downloaded: $($DownloadURL)"
  # Install irfanview
  Log-Message -file $logfile -Message "Installing $($ApplicationName)"
  Start-Process -Wait -FilePath $Archive -ArgumentList '/silent /desktop=1 /group=1 /allusers=1'
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




