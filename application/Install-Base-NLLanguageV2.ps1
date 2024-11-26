$ApplicationName = "Win11 Language Pack NL V2"
$Archive = "C:\BuildImage\Apps\Microsoft-Windows-LanguagePack-nl-NL.zip"
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

#installing language Pack

##Disable Language Pack Cleanup##
Try {
  Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup"
  Disable-ScheduledTask -TaskPath "\Microsoft\Windows\MUI\" -TaskName "LPRemove"
  Disable-ScheduledTask -TaskPath "\Microsoft\Windows\LanguageComponentsInstaller" -TaskName "Uninstallation"
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "BlockCleanupOfUnusedPreinstalledLangPacks" /t REG_DWORD /d 1 /f
  Log-Message -file $logFile -Message "Disabled scheduled tasks and added registry key"
}
catch {
  $SetError = $_
  Log-Message -file $logFile -Message "Cannot disable scheduled tasks and added registry key"
  Log-message -file $logFile -Message "$($setError.Exception.Message)"
}

##Set Language (Target)##
$languagePacks = "en-US", "nl-NL"
$defaultLanguage = "nl-NL"

foreach ($language in $languagePacks) {
  Write-Host "Installing Language Pack for: $language"
  Install-Language $language
  Write-Host "Installing Language Pack for: $language completed."
}

if ($defaultLanguage -eq $null) {
  Write-Host "Default Language not configured."
}
else {
  Write-Host "Setting default Language to: $defaultLanguage"
  Set-SystemPreferredUILanguage $defaultLanguage
  Set-WinUserLanguageList $defaultLanguage -force
}

#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"