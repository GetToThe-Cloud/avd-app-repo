$ApplicationName = "FSLogix Agent"
$Archive = "$($env:temp)\FSLogixSetup.zip"
$installDescription = "Installing the latest version of $($ApplicationName) $($Archive)"
$DownloadURL = "https://aka.ms/fslogix/download"

### Functions ####
function Log-Message([String]$Message, [string]$file) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] " + $message
    $messageLog = "[$(Get-Date -format "HH:mm:ss")] " + $message
    Add-Content -Path $file $MessageLog
   
}
### Tests ####
If (!(Test-Path "C:\Log")) {
  Write-Host "[$(Get-Date -format "HH:mm:ss")] Folder does not exist"
new-item -type Directory -path "C:\" -name Log
#    break
}
$logfile = "C:\Log\Install-$($ApplicationName)-$(Get-Date -Format "ddMMyyyy").txt"

Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "$($installDescription)"
Log-Message -file $logfile -Message "Start Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"

# update fslogix
$FSLogixInstaller = "FSLogixAppsSetup.exe"
$ZipFileToExtract = "x64/Release/FSLogixAppsSetup.exe"
$Zip = $archive
$Installer = "$env:Temp\$FSLogixInstaller"
$downloadAndInstall = $false

$ProductName = "Microsoft FSLogix Apps"

Log-Message -File $Logfile -Message "Checking registry for $ProductName"

# Get FSLogix version number if installed
$fslogixsearch = (get-wmiobject Win32_Product | where-object name -eq "Microsoft FSLogix Apps" | select-object Version)

switch ($fslogixsearch.count) {
    0 {
        # Not found
        $fslogixver = $null
        $downloadAndInstall = $true
    }
    1 {
        # One entry returned
        $fslogixver = [System.Version]$fslogixsearch.Version
        Log-Message -File $Logfile -Message "FSLogix version installed: $fslogixver"
    }
    { $_ -gt 1 } {
        # two or more returned
        $fslogixver = [System.Version]$fslogixsearch[0].Version
        Log-Message -File $Logfile -Message "FSLogix version installed: $fslogixver"
    }

}

# Find current FSLogix version from short URL:
$WebRequest = [System.Net.WebRequest]::create($DownloadURL)
$WebResponse = $WebRequest.GetResponse()
$ActualDownloadURL = $WebResponse.ResponseUri.AbsoluteUri
$WebResponse.Close()

$FSLogixCurrentVersion = [System.Version]((Split-Path $ActualDownloadURL -leaf).Split("_")[2]).Replace(".zip", "")

Log-Message -File $Logfile -Message "Current FSLogix version: $FSLogixCurrentVersion"

# See if the current version is newer than the installed version:
if ($FSLogixCurrentVersion -gt $fslogixver) {
    # Current version greater than installed version, install new version
    Log-Message -File $Logfile -Message "New version will be downloaded and installed. ($FSLogixCurrentVersion > $fslogixver)"
    $downloadAndInstall = $true
}

# If $downloadAndInstall has been toggled true, download and install.
if ($downloadAndInstall) {
    Log-Message -File $Logfile -Message "Not installed... beginning install..."
    # Download installer
    #Import-Module BitsTransfer
    Log-Message -File $Logfile -Message "Downloading from: $FSLogixURL"
    Log-Message -File $Logfile -Message "Saving file to: $Zip"

    #Start-BitsTransfer -Source $FSLogixURL -Destination "$env:temp\$FSLogixDownload" -RetryInterval 60
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zip
    # Extract file from zip: x64\Release\FSLogixAppsSetup.exe to $env:temp\FSLogixAppsSetup.exe
    
    # Open zip
    Add-Type -Assembly System.IO.Compression.FileSystem
    $zipFile = [IO.Compression.ZipFile]::OpenRead($Zip)
    
    # Retrieve the $ZipFileToExtract and extract to $Installer
    $filetoextract = ($zipFile.Entries | Where-Object { $_.FullName -eq $ZipFileToExtract })
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($filetoextract[0], $Installer, $true)
    
    # get policy files
    $filetoextract = ($zipFile.Entries | Where-Object { $_.FullName -eq "fslogix.adml" })
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($filetoextract[0], "$Env:temp\fslogix.adml", $true)
    $filetoextract = ($zipFile.Entries | Where-Object { $_.FullName -eq "fslogix.admx" })
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($filetoextract[0], "$Env:temp\fslogix.admx", $true)

    # copy admx and adml
    copy-item -Path "$Env:temp\fslogix.admx" -Destination "C:\Windows\PolicyDefinitions" -Force
    copy-item -Path "$Env:temp\fslogix.adml" -Destination "C:\Windows\PolicyDefinitions\En-Us" -Force

    # Run installer
    Log-Message -File $Logfile -Message "Running $Installer /install /quiet /norestart"
    Start-Process $Installer -wait -ArgumentList "/install /quiet /norestart"

    # copying adml and admx

    # Wait for 5 minutes so that the files can be deleted because despite -wait being specified, it doesn't actually wait for all processes to finish
    Start-Sleep -Seconds 300

    # Close the zip file so it can be deleted
    $zipFile.Dispose()

    # Clean up
    Log-Message -File $Logfile -Message "Cleaning up, deleting $Installer and $Zip."
    Remove-Item -Path $Installer -Force
    Remove-Item -Path $Zip -Force
}
else {
    Log-Message -File $Logfile -Message "FSLogix already installed and up to date."
    Log-Message -File $Logfile -Message "Downloading from: $downloadUrl"
    Log-Message -File $Logfile -Message "Saving file to: $Zip"

    #Start-BitsTransfer -Source $FSLogixURL -Destination "$env:temp\$FSLogixDownload" -RetryInterval 60
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $zip
    # Extract file from zip: x64\Release\FSLogixAppsSetup.exe to $env:temp\FSLogixAppsSetup.exe
    
    # Open zip
    Add-Type -Assembly System.IO.Compression.FileSystem
    $zipFile = [IO.Compression.ZipFile]::OpenRead($Zip)
    
    # Retrieve the $ZipFileToExtract and extract to $Installer
    $filetoextract = ($zipFile.Entries | Where-Object { $_.FullName -eq $ZipFileToExtract })
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($filetoextract[0], $Installer, $true)
    
    # get policy files
    $filetoextract = ($zipFile.Entries | Where-Object { $_.FullName -eq "fslogix.adml" })
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($filetoextract[0], "$Env:temp\fslogix.adml", $true)
    $filetoextract = ($zipFile.Entries | Where-Object { $_.FullName -eq "fslogix.admx" })
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($filetoextract[0], "$Env:temp\fslogix.admx", $true)

    # copy admx and adml
    copy-item -Path "$Env:temp\fslogix.admx" -Destination "C:\Windows\PolicyDefinitions" -Force
    copy-item -Path "$Env:temp\fslogix.adml" -Destination "C:\Windows\PolicyDefinitions\En-Us" -Force

}


Log-Message -file $logfile -Message "-----------------------------------------------------------"
Log-Message -file $logfile -Message "Finished installation of $($ApplicationName)"
Log-Message -file $logfile -Message "End Time: $(Get-Date)"
Log-Message -file $logfile -Message "-----------------------------------------------------------"