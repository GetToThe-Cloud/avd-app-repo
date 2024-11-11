$applicationName = "Microsoft365Language"
$installDescription = "Installing a custom language for M365 Apps"

### Functions ####
function Log-Message([String]$Message, [string]$file) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] " + $message
    $messageLog = "[$(Get-Date -format "HH:mm:ss")] " + $message
    Add-Content -Path $file $MessageLog
   
}

function Get-ODTURL {
    
    [String]$MSWebPage = Invoke-RestMethod 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117'

    $MSWebPage | ForEach-Object {
        if ($_ -match 'url=(https://.*officedeploymenttool.*.exe)') {
            $matches[1]
        }
    }

}
### Tests ####
If (!(Test-Path "C:\BuildImage\Log")) {
    Write-Host "[$(Get-Date -format "HH:mm:ss")] Folder does not exist"
  new-item -type Directory -path "C:\BuildImage" -name Log
  #    break
  }
  
  $logfile = "C:\buildImage\Log\Install-$($ApplicationName)-$(Get-Date -Format "ddMMyyyy").txt"


#### Download ####
$odtLink = Get-ODTURL

try {
    Invoke-WebRequest -uri $odtLink -OutFile "C:\buildImage\ODTSetup.exe" -useBasicParsing
    Log-Message -file $logFile -Message "ODTSetup.exe is downloaded"
}
catch {
    $downloadError = $_
    Log-Message -file $logFile -Message "Cannot download $($odtLink)"
    Log-message -file $logFile -Message "$($downloadError.Exception.Message)"
}

# install dutch office
## unpack ODT

Try{
    Start-Process "C:\buildImage\ODTSetup.exe" -ArgumentList "/quiet /extract:C:\buildImage" -Wait
    Log-Message -File $logfile -Message "ODTSetup.exe is extracted to $path"
}
Catch {
    Log-Message -File $logfile -Message "Cannot extract ODTSetup.exe"
}
    
## running install
try {
    Log-Message -File $logfile -Message "Starting installation custom office"
    $Silent = Start-Process "C:\buildImage\Setup.exe" -ArgumentList "/configure C:\buildImage\Apps\M365Office-EN-NL.xml" -Wait -PassThru
}
catch {
    Log-Message -File $logFile -Message "Something went wrong installing the language pack"
    Log-Message -file $logFile -Message $_
}