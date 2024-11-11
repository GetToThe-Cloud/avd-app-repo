$ApplicationName = "7Zip"
$Archive = $Env:temp + "\7zip.exe"
$installDescription = "Installing the latest version of $($ApplicationName) $($Archive)"


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

#region 7-Zip
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Declares
$7zipWebsite = "https://7-zip.org/"
$architecture = "64"
$webLocation = $7zipWebsite + (Invoke-WebRequest -Uri $7zipWebsite -useBasicParsing | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -like '*Download*') -and ($_.href -like "a/*") -and ($_.href -like "*-x$($architecture).exe")} | Select-Object -ExpandProperty href).Split(' ')[0]


#region Install
try {
  # Download Setup Files
  Invoke-WebRequest $webLocation -OutFile $Archive -useBasicParsing
  Log-Message -file $logFile -Message "$($webLocation) is downloaded"

  # Install 
  Log-Message -File $logFile -Message  "Installing the downloaded 7-Zip version"
  Start-Process $Archive -ArgumentList "/S" -Wait
}
catch { throw }
 finally {
   # Remove Setup Files
   Remove-Item $Archive -Recurse -Force -ErrorAction Ignore
   Log-Message -File $logFile -Message  "Cleaning up the temporary work directory that was used"
 }
#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------" 
