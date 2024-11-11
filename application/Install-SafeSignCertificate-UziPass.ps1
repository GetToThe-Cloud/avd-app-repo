$ApplicationName = "SafeSign UziPass"
$Archive = "$($env:temp)\SafeSign-IC.zip"
$installDescription = "Installing the latest version of $($ApplicationName) : $($Archive)"


### Functions ####
function Log-Message([String]$Message, [string]$file) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] " + $message
    $messageLog = "[$(Get-Date -format "HH:mm:ss")] " + $message
    Add-Content -Path $file $MessageLog
   
}
### Tests ####
If (!(Test-Path "C:\TempInstall")) {
  Write-Host "[$(Get-Date -format "HH:mm:ss")] Folder does not exist"
new-item -type Directory -path "C:\" -name TempInstall
#    break
}

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

#region 
$baselink = "https://www.uziregister.nl"
$firstlink = "/uzi-pas/activeer-en-installeer-uw-uzi-pas/overzicht-safesign-software"
$SelectLink = ((Invoke-WebRequest -Uri $($baselink + $firstlink)).links | Where-Object {$_.outerhtml -like "*windows 64-bits*"} | Select -first 1).href
$DownloadLink = $baselink + $selectLink

$downloadUrl = $baselink + $((Invoke-WebRequest -Uri $DownloadLink).links | where-Object {$_.outerhtml -like "*download-chunk zip*"}).href
try {

    Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive

   #Extract ZIP file and MSI content
   set-alias 7z "$env:ProgramFiles\7-Zip\7z.exe"
   7z e $archive -oc:\TempInstall\Safesign -y
   $file = (Get-ChildItem "C:\TempInstall\Safesign" | Where-Object {$_.name -like "*.msi"}).fullname
   $installMSI = $file
   7z e $file -oc:\TempInstall\Safesign\new -y
   $file = (Get-ChildItem "C:\TempInstall\Safesign\new" | Where-Object {$_.name -like "*.cab"}).fullname
   7z e $file -oc:\TempInstall\Safesign\Cert -y

   #Export certificate
   $driverFile = 'c:\TempInstall\Safesign\Cert\aetrwcm1.cat'
   $outputFile = 'c:\TempInstall\Safesign\Cert\aetrwcm1.cer'
   $exportType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert

   $cert = (Get-AuthenticodeSignature $driverFile).SignerCertificate;
   [System.IO.File]::WriteAllBytes($outputFile, $cert.Export($exportType));

   #Import Certificate
   Import-Certificate -FilePath "C:\TempInstall\Safesign\Cert\aetrwcm1.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' 

   #Install SafeSign
   $arguments = @(
    "/i"
    ($installMSI)
    "/qb"
    "/norestart"
    "ADDLOCAL=TokenAdminFeature,Pkcs11Feature,LocaleFeature,MinidriverFeature,InternalFeature"
    )
    Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow

   If(-Not(test-path "C:\Program Files\A.E.T. Europe B.V")){ 
       Write-Error "The Safesign installation directory doesn't exists." 
   }
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