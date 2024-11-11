$ApplicationName = "DWGTrueView"
$Archive = "$($env:temp)\DWGTrueView_2024_English_64bit_dlm.sfx.exe"
$installDescription = "Installing the latest version of $($ApplicationName) $($Archive)"
$DownloadURL = 'http://efulfillment.autodesk.com/NetSWDLD/2024/ACD/9C02048D-D0DB-3E06-B903-89BD24380AAD/SFX/DWGTrueView_2024_English_64bit_dlm.sfx.exe?authparam=b91ba1b191a933c9c10b81c98913132b812b1b811b991b3389b98913a1c933b9&SESSION_ID=123456789;1537854608;1642291895;1;authparam;SESSION_ID'


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


#region Install DWGTrueView

$Installer = "C:\Autodesk\DWGTrueView_2024_English_64bit_dlm\Setup.exe"

try {
  # Download Setup Files
    Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive -useBasicParsing
  
  # Extract Installer
  Log-Message -file $logFile -Message "Extracting Autodesk $($archive)"
  START-PROCESS $Archive -argumentlist '-suppresslaunch -d "C:\Autodesk"' -wait
If (!(Test-Path $installer)){
    Log-Message -file $logfile -Message "Error extracting the $($Archive)"
    break
}
    Log-Message -file $logfile -Message "Autodesk is extracted to C:\Autodesk"

  # Install Acrobat
  Start-Process -Wait -FilePath $Installer -ArgumentList '--silent'
}
catch { throw }
 finally {
   # Remove Setup Files
   Remove-Item $Archive, "$env:temp\Autodesk\" -Recurse -Force -ErrorAction Ignore
   Log-Message -File $logfile -Message "Temporary files are deleted"
 }
#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"