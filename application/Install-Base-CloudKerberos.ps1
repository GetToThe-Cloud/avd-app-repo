$ApplicationName = "CloudKerberos"
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


$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters"
try {
    New-ItemProperty -Path $RegPath -Name "CloudKerberosTicketRetrievalEnabled" -Value 1 -PropertyType DWord | out-Null
    Log-Message -file $Logfile -Message "CloudKerberosTicketRetrievalEnabled is set to registry"
}
catch {
    $errormessage = $_
    Log-message -file $Logfile -Message "CloudKerberosTicketRetrievalEnabled could not be set"
    Log-Message -file $Logfile -Message "$($errormessage.Exception.Message)"
    exit 1
}

try {
    Get-ItemProperty -Path $RegPath -Name "CloudKerberosTicketRetrievalEnabled" -ErrorAction Stop 
    Log-Message -file $Logfile -Message "CloudKerberosTicketRetrievalEnabled is set to registry"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
    Log-Message -file $logfile -Message "End Time: $(Get-Date)"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
}
catch {
    $errormessage = $_
    Log-message -file $Logfile -Message "CloudKerberosTicketRetrievalEnabled was not set"
    Log-Message -file $Logfile -Message "$($errormessage.Exception.Message)"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    Log-Message -file $logfile -Message "Failed installation of $($ApplicationName) with code: $($LastExitCode)"
    Log-Message -file $logfile -Message "End Time: $(Get-Date)"
    Log-Message -file $logfile -Message "-----------------------------------------------------------"
    exit 1
}

