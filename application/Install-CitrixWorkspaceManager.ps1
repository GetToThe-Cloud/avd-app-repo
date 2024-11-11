$ApplicationName = "Citrix Workspace Manager"
$Archive = "$($env:temp)\CitrixWorkspaceApp.exe"
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

#region Citrix Workspace App
$link = "https://www.citrix.com/downloads/workspace-app/windows/workspace-app-for-windows-latest.html"
$download = ((Invoke-WebRequest -Uri $link -useBasicParsing).links | where-Object {$_.outerHtml -like "*CitrixWorkspaceApp.exe*"}).rel | Select -first 1
$Downloadurl = "https:" + $download
try {

    Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive

  # Install Citrix workspace
  Start-Process -FilePath $Archive -ArgumentList '/silent' -Wait
}
catch { throw }
 finally {
   # Remove Setup Files
   Remove-Item $Archive -Force -ErrorAction Ignore
 }
#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------" 
