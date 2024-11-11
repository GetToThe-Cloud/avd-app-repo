#customer specific variables
$applicationInstallFiles = ""

#general variables
$ApplicationName = "BuildImage"
$installDescription = "Image Build script"

#region ### Functions ####
function Log-Message([String]$Message, [string]$file) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] " + $message
    $messageLog = "[$(Get-Date -format "HH:mm:ss")] " + $message
    Add-Content -Path $file $MessageLog
   
}
#endregion
#region ### Tests ####
If (!(Test-Path "C:\BuildImage")) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] Folder does not exist"
    new-item -type Directory -path "C:\" -name BuildImage
  #    break
}
If (!(Test-Path "C:\BuildImage\Log")) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] Folder does not exist"
  new-item -type Directory -path "C:\BuildImage" -name Log
  #    break
}
If (!(Test-Path "C:\BuildImage\Apps")) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] Folder does not exist"
    new-item -type Directory -path "C:\BuildImage" -name Apps
  #    break
}

# get AZCopy
if (Test-Path -path "C:\BuildImage\azcopy.exe" -ErrorAction SilentlyContinue) {
    #do skip
}
else {
    Start-BitsTransfer -Source 'https://aka.ms/downloadazcopy-v10-windows' -Destination "C:\BuildImage\azcopy.zip"
    Expand-Archive "C:\BuildImage\azcopy.zip" "C:\BuildImage"
    copy-item "C:\BuildImage\azcopy_windows_amd64_*\azcopy.exe" -Destination "C:\BuildImage"
}
#endregion

$logfile = "C:\BuildImage\Log\Install-$($ApplicationName)-$(Get-Date -Format "ddMMyyyy").txt"

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "$($installDescription)"
Log-Message -file $logfile -Message "Start Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"

#region ### downloading application install files

C:\BuildImage\azcopy.exe copy $applicationInstallFiles C:\BuildImage\Apps --recursive

#check 
$files = Get-ChildItem -Path C:\buildImage\Apps -Recurse
if ($null -eq $Files.count){
    Log-Message -File $logfile -Message "No application install files where found"
    $exit = 1
}
else {
    $files = $files | Where-Object {$_.name -like "*.ps1"}
    Log-Message -file $logFile -Message "$($Files.Count) powershell are found for installation of applications"
}
#endregion


if ($Exit -ne 1){
    ForEach ($application in $files){
        Start-Process powershell.exe -verb RunAs $($application.fullname) -wait
        #& $application.fullname
    }
}

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"