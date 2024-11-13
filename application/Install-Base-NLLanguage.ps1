$ApplicationName = "Win11 Language Pack NL"
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

#region Irfanview
$path = "C:\BuildImage\Apps"

Try {
  Expand-Archive -LiteralPath $Archive -DestinationPath "$Env:temp\LanguagePack"
  Log-Message -file $logFile -Message "Language Pack is unzipped and placed $($Env:Temp)\LanguagePack"
  $LipContent = "$Env:temp\LanguagePack"
  $SetLanguage = $true
}
Catch {
  Log-Message -file $logFile -Message "Cannot unpack language pack"
  $SetLanguage = $false
}

if ($SetLanguage) {

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
  $sourceLanguage = "nl-nl"

  ##List of additional features to be installed##
  $additionalFODList = @(
      "$LIPContent\Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~~.cab", 
      "$LIPContent\Microsoft-Windows-MSPaint-FoD-Package~31bf3856ad364e35~amd64~$sourceLanguage~.cab",
      "$LIPContent\Microsoft-Windows-SnippingTool-FoD-Package~31bf3856ad364e35~amd64~$sourceLanguage~.cab"
  )

  $additionalCapabilityList = @(
      "Language.Basic~~~$sourceLanguage~0.0.1.0",
      "Language.Handwriting~~~$sourceLanguage~0.0.1.0",
      "Language.OCR~~~$sourceLanguage~0.0.1.0",
      "Language.TextToSpeech~~~$sourceLanguage~0.0.1.0"
  )

  ##Install all FODs or fonts from the CSV file###
  Dism /Online /Add-Package /PackagePath:$LIPContent\Microsoft-Windows-Client-Language-Pack_x64_$sourceLanguage.cab
  Log-Message -File $logFile -Message "Microsoft-Windows-Client-Language-Pack_x64_$sourceLanguage.cab will be installed"
  # Dism /Online /Add-Package /PackagePath:$LIPContent\Microsoft-Windows-Lip-Language-Pack_x64_$sourceLanguage.cab
  foreach ($capability in $additionalCapabilityList) {
      Dism /Online /Add-Capability /CapabilityName:$capability /Source:$LIPContent
      Log-Message -File $logFile -Message "$($capability) will be installed"
  }

  foreach ($feature in $additionalFODList) {
      Dism /Online /Add-Package /PackagePath:$feature
      Log-Message -File $logFile -Message "$($feature) will be installed"
  }

  ##Add installed language to language list##
  $LanguageList = Get-WinUserLanguageList
  $LanguageList.Add("$sourcelanguage")
  Set-WinUserLanguageList $LanguageList -force
  Log-Message -File $logFile -Message "$Languagelist"
  remove-appxpackage -package "Microsoft.LanguageExperiencePacknl-NL_22621.48.189.0_neutral__8wekyb3d8bbwe"
}
#endregion

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"