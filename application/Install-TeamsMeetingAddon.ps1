# https://techcommunity.microsoft.com/discussions/microsoftteams/teams-standalone-outlook-addin/1291844

$ApplicationName = "Teams Meeting Addon"
$Archive = "$($env:temp)\MSTeams-x64.msix"
$installDescription = "Installing the latest version of $($ApplicationName) $($Archive)"
$DownloadURL = "https://go.microsoft.com/fwlink/?linkid=2196106"


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

try {
  Log-Message -file $logfile -Message "Downloading the installer: $($DownloadURL)"
  Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive -useBasicParsing -ErrorAction Stop
  Log-Message -file $logfile -Message "Installer is downloaded: $($DownloadURL)"
# unzipp MSIX
  set-alias 7z "$env:ProgramFiles\7-Zip\7z.exe"
  7z e $archive -oc:\BuildImage\Apps\TeamsAddin -y
  Log-Message -file $logfile -Message "MSIX is unzipped"

  if (Test-Path "C:\BuildImage\Apps\TeamsAddin\MicrosoftTeamsMeetingAddinInstaller.msi"){
    $toInstall = "C:\BuildImage\Apps\TeamsAddin\MicrosoftTeamsMeetingAddinInstaller.msi"
  }
  else{
    throw "MSIX is not unzipped"
  }
  #install
  Log-Message -file $logfile -Message "Installing $($ApplicationName)"
  $arguments = @(
    "/i"
    ($toInstall)
    "/passive"
    "/norestart"
    TARGETDIR="C:\Program Files (x86)\Microsoft\TeamsMeetingAddin\<versionnumber>\"
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
