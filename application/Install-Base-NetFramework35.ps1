$ApplicationName = ".Net Framework 3.5"
$installDescription = "Installing the latest version of $($ApplicationName)"

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


# .net framework 3.5
If ((Get-WindowsCapability -Online -Name NetFx3).state -eq "NotPresent") {
    Log-message -file $logfile -Message ".NET Framework 3.5 is not present. Installing now..."
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"

}
If ((Get-WindowsCapability -Online -Name NetFx3).state -eq "NotPresent") {
    Log-message -file $logfile -Message ".NET Framework 3.5 still not present. Skipping ..."
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    Log-Message -file $logfile -Message "Failed installation of $($ApplicationName) with code: $($LastExitCode)"
    Log-Message -file $logfile -Message "End Time: $(Get-Date)"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    exit 1
}
else {
    Log-Message -file $Logfile -message ".NET Framework 3.5 is present."
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
    Log-Message -file $logfile -Message "End Time: $(Get-Date)"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
}

